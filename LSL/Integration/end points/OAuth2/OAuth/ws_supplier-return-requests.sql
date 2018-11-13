-- Create Module
BEGIN          
  ords.define_module(p_module_name    => 'lslmodule.v1',
                     p_base_path      => 'lslmodule/v1/',
                     p_items_per_page => 0,
                     p_status         => 'PUBLISHED',
                     p_comments       => 'supllier return module');             
  COMMIT;
END;
/

-- Create Template 
BEGIN
  ords.define_template(p_module_name => 'lslmodule.v1',
                       p_pattern     => 'supplierreturn/',
                       p_comments    => 'supplier return');

  COMMIT;
END;
/
-- Create Handler 
BEGIN
  ords.define_handler(p_module_name    => 'lslmodule.v1',
                      p_pattern        => 'supplierreturn/',
                      p_method         => 'GET',
                      p_source_type    => ords.source_type_collection_feed,
                      p_source         => ' SELECT srh.SUPPLIERRETURNREQUESTID,
                                                   srh.STOREID,
                                            CURSOR (select  srh_inner.STREET,
                                                            srh_inner.CITY,
                                                            srh_inner.STATE,
                                                            srh_inner.POSTCODE,
                                                            srh_inner.COUNTRY,
                                                            srh_inner.CONTACTNAME,
                                                            srh_inner.PHONE,
                                                            srh_inner.EMAIL
                                            from SUPPLIER_RET_REQUESTS_HEADER srh_inner) as ADDRESS,
                                            CURSOR(SELECT srl.*
                                            FROM SUPPLIER_RET_REQUESTS_LINES srl
                                            WHERE srh.SUPPLIERRETURNREQUESTID = srl.SUPPLIERRETURNREQUESTID) as SupplierReturnLines
                                            FROM SUPPLIER_RET_REQUESTS_HEADER srh',
                      p_items_per_page => 0,
                      p_comments       => 'get supplier return');
  COMMIT;
  exception
    when others then
      dbms_output.put_line(''||sqlerrm);
END;
/

-- Create Module
BEGIN          
  ords.define_module(p_module_name    => 'lslmodule5.v1',
                     p_base_path      => 'lslmodule5/v1/',
                     p_items_per_page => 0,
                     p_status         => 'PUBLISHED',
                     p_comments       => 'Supplier Return Module');             
  COMMIT;
END;


-- Create Template 
BEGIN
  ords.define_template(p_module_name => 'lslmodule5.v1',
                       p_pattern     => '/supplierreturns',
                       p_comments    => 'supplier return');

  COMMIT;
END;

-- Create Handler 
BEGIN
  ords.define_handler(p_module_name    => 'lslmodule5.v1',
                      p_pattern        => 'supplierreturns/',
                      p_method         => 'GET',
                      p_source_type    => ords.source_type_collection_feed,
                      p_source         => ' SELECT srh.SUPPLIERRETURNREQUESTID,
                                                   srh.STOREID,
                                            CURSOR (select  srh_inner.STREET,
                                                            srh_inner.CITY,
                                                            srh_inner.STATE,
                                                            srh_inner.POSTCODE,
                                                            srh_inner.COUNTRY,
                                                            srh_inner.CONTACTNAME,
                                                            srh_inner.PHONE,
                                                            srh_inner.EMAIL
                                            from SUPPLIER_RET_REQUESTS_HEADER srh_inner) as ADDRESS,
                                            CURSOR(SELECT srl.*
                                            FROM SUPPLIER_RET_REQUESTS_LINES srl
                                            WHERE srh.SUPPLIERRETURNREQUESTID = srl.SUPPLIERRETURNREQUESTID) as SupplierReturnLines
                                            FROM SUPPLIER_RET_REQUESTS_HEADER srh',
                      p_items_per_page => 0,
                      p_comments       => 'supplier return');
  COMMIT;
  exception
    when others then
      dbms_output.put_line(''||sqlerrm);
END;

-------end new-------

BEGIN
       
  ords.define_module(p_module_name    => 'lslmodule2.v1',
                     p_base_path      => 'lslmodule2/v1/',
                     p_items_per_page => 5,
                     p_status         => 'PUBLISHED',
                     p_comments       => 'testmodule2 Module');             
  COMMIT;
END;
  

BEGIN
  ords.define_template(p_module_name => 'lslmodule2.v1',
                       p_pattern     => 'supplierreturns/',
                       p_comments    => 'supplier return request ');

  COMMIT;
END;

begin
  ORDS.define_handler(
    p_module_name    => 'lslmodule2.v1',
      p_pattern        => 'supplierreturns/',
    p_method         => 'POST',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => 'BEGIN
                           create_supplier_return(p_data => :body);
                         END;',
    p_items_per_page => 0);

  COMMIT;
END;


https://13.67.34.43:8443/ords/api/lslmodule2/v1/supplierreturns/


SELECT * FROM SUPPLIER_RET_REQUESTS_HEADER

SELECT * FROM SUPPLIER_RET_REQUESTS_LINES


{
  "SupplierReturnRequestId": "123",
  "StoreId": 0,
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

create table SUPPLIER_RET_REQUESTS_HEADER
as
SELECT  ' test ' SupplierReturnRequestId
      , ' test ' StoreId
      , ' test ' Street
      , ' test ' City
      , ' test ' State
      , ' test ' PostCode
      , ' test ' Country
      , ' test ' ContactName
      , ' test ' Phone
      , ' test ' Email        
FROM dual;

  drop table SUPPLIER_RET_REQUESTS_LINES;

  CREATE TABLE SUPPLIER_RET_REQUESTS_LINES
   (
   SUPPLIERRETURNREQUESTID  VARCHAR2(100), 
	 PRODUCTID                VARCHAR2(100), 
	 QUANTITY                 VARCHAR2(100), 
	 UNIT                     VARCHAR2(100), 
	 SUPPLIERID               VARCHAR2(100), 
	 PURCHASEORDERID          VARCHAR2(100)
   );

create table SUPPLIER_RET_REQUESTS_LINES
as
   SELECT ' test ' SupplierReturnRequestId, ' test ' ProductId, ' test ' Quantity, ' test ' Unit, ' test ' SupplierId, ' test ' PurchaseOrderId
   FROM dual;
   
  drop table SUPPLIER_RET_REQUESTS_HEADER;
  
  CREATE TABLE SUPPLIER_RET_REQUESTS_HEADER 
   (	
   SUPPLIERRETURNREQUESTID  VARCHAR2(100), 
	 STOREID                  VARCHAR2(100), 
	 STREET                   VARCHAR2(100), 
	 CITY                     VARCHAR2(100), 
	 STATE                    VARCHAR2(100), 
	 POSTCODE                 VARCHAR2(100), 
	 COUNTRY                  VARCHAR2(100), 
	 CONTACTNAME              VARCHAR2(100), 
	 PHONE                    VARCHAR2(100), 
	 EMAIL                    VARCHAR2(100)
   );