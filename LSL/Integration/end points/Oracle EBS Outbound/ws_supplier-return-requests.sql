CREATE OR REPLACE PROCEDURE  create_supplier_return (p_data IN varchar2, p_msg OUT varchar2) 
AS
l_msg         varchar2(1000);
--l_code        l_msg.v_code%type;         
--l_desc        l_msg.v_desc%type;
--var_code l_code;
--var_desc l_desc;

ex_custom       EXCEPTION;
BEGIN
BEGIN

INSERT INTO SUPPLIER_RET_REQUESTS_HEADER(SupplierReturnRequestId, StoreId, Street, City, State, PostCode, Country, ContactName, Phone, Email)
   SELECT SupplierReturnRequestId, StoreId, Street, City, State, PostCode, Country, ContactName, Phone, Email        
   FROM json_table(p_data format JSON , '$' COLUMNS 
   ( SupplierReturnRequestId VARCHAR2 PATH '$.SupplierReturnRequestId',
     StoreId VARCHAR2 PATH '$.StoreId', 
     Street VARCHAR2 PATH '$.Address.Street', 
     City VARCHAR2 PATH '$.Address.City', 
     State VARCHAR2 PATH '$.Address.State', 
     PostCode VARCHAR2 PATH '$.Address.PostCode', 
     Country VARCHAR2 PATH '$.Address.Country', 
     ContactName VARCHAR2 PATH '$.Address.ContactName', 
     Phone VARCHAR2 PATH '$.Address.Phone', 
     Email VARCHAR2 PATH '$.Address.Email'));
             
             --RAISE ex_custom;
             
   INSERT INTO SUPPLIER_RET_REQUESTS_LINES (SupplierReturnRequestId, ProductId, Quantity, Unit, SupplierId, PurchaseOrderId  )
   SELECT SupplierReturnRequestId, ProductId, Quantity, Unit, SupplierId, PurchaseOrderId          
   FROM json_table(p_data format JSON , '$' COLUMNS 
   (
     SupplierReturnRequestId VARCHAR2 PATH '$.SupplierReturnRequestId',
     StoreId VARCHAR2 PATH '$.StoreId', 
     Street VARCHAR2 PATH '$.Address.Street', 
     City VARCHAR2 PATH '$.Address.City', 
     State VARCHAR2 PATH '$.Address.State', 
     PostCode VARCHAR2 PATH '$.Address.PostCode', 
     Country VARCHAR2 PATH '$.Address.Country', 
     ContactName VARCHAR2 PATH '$.Address.ContactName', 
     Phone VARCHAR2 PATH '$.Address.Phone', 
     Email VARCHAR2 PATH '$.Address.Email',  
   NESTED PATH '$.Lines[*]' 
   COLUMNS ( --SupplierReturnRequestId VARCHAR2 PATH '$.SupplierReturnRequestId', 
             ProductId VARCHAR2 PATH '$.ProductId',
             Quantity VARCHAR2 PATH '$.Quantity',
             Unit VARCHAR2 PATH '$.Unit',
             SupplierId VARCHAR2 PATH '$.SupplierId',
             PurchaseOrderId VARCHAR2 PATH '$.PurchaseOrderId' )));  
  COMMIT;
  
    select 'successful operation'
    into l_msg
    from dual;

    p_msg := l_msg;    
    
EXCEPTION
  WHEN OTHERS THEN
    select 'Invalid input (e.g. if the StoreId, SupplierId, or ProductId could not be found.'
    into l_msg
    from dual;
    
    p_msg := l_msg;
    
    END;    

END;
/

BEGIN
       
  ords.define_module(p_module_name    => 'lslmodule2.v1',
                     p_base_path      => 'lslmodule2/v1/',
                     p_items_per_page => 5,
                     p_status         => 'PUBLISHED',
                     p_comments       => 'supplier return request module');             
  COMMIT;
END;
/

BEGIN
  ords.define_template(p_module_name => 'lslmodule2.v1',
                       p_pattern     => 'supplier-return-requests/',
                       p_comments    => 'supplier return request ');

  COMMIT;
END;
/
begin
  ORDS.define_handler(
    p_module_name    => 'lslmodule2.v1',
    p_pattern        => 'supplier-return-requests/',
    p_method         => 'POST',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => q'[DECLARE                            
                            v_msg VARCHAR2(1000);
                            l_response  VARCHAR2(32767);                      
                           BEGIN                             
                             -- Build response.
                             create_supplier_return(UTL_RAW.cast_to_varchar2(:body), v_msg);
                             l_response := v_msg;
 
                             -- Output response text.
                             HTP.p(l_response);
                             
                         END;]',
    p_items_per_page => 1);

  COMMIT;
END;
/



--https://13.67.34.43:8443/ords/api/lslmodule2/v1/supplier-return-requests/


SELECT * FROM SUPPLIER_RET_REQUESTS_HEADER;
delete from SUPPLIER_RET_REQUESTS_HEADER;

SELECT * FROM SUPPLIER_RET_REQUESTS_LINES;
delete from SUPPLIER_RET_REQUESTS_LINES;
{
  "SupplierReturnRequestId": "123",
  "Date": "string",
  "StoreId": 0,k
  "Address": {
    "Street": "123 Example St\nLevel 2",
    "City": "Melbourne",
    "State": "VIC",
    "PostCode": "3000",
    "Country": "Australia",
    "ContactName": "John",
    "Phone": "+613 9876 4321",
    "Email": "john@example.com"
  },
  "Lines": [
    {
      "SupplierReturnRequestId": "123",
      "ProductId": "d94c2221-4f48-4e3f-8153-89c42794ba6a",
      "Quantity": "5.4",
      "Unit": "ea",
      "SupplierId": "d94c2221-4f48-4e3f-8153-89c42794ba6a",
      "PurchaseOrderId": "321"
    }
  ]
}


