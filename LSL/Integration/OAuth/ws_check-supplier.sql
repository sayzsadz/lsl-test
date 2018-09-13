CREATE OR REPLACE PROCEDURE check_supplier (p_data  IN  BLOB)
AS
lv_SupplierId varchar2(100);
BEGIN

SELECT SupplierId into lv_SupplierId  FROM json_table(p_data format JSON , '$'
         COLUMNS (
           ProductId  varchar2 PATH '$.ProductId',
           NESTED                      PATH '$.Suppliers[*]'
             COLUMNS (
              
               SupplierId  VARCHAR2    PATH '$.SupplierId',
               SupplierName      VARCHAR2     PATH '$.SupplierName')));
  
  IF lv_SupplierId IS NULL OR NVL(lv_SupplierId,'*') = '*' Then 
     null;         
     
  ELSE 
  
  INSERT
  INTO PRODUCT
    (
      SupplierId
    )
    VALUES
    (
      lv_SupplierId
    );

  
  END IF;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    HTP.print(SQLERRM);
END;




BEGIN
       
  ords.define_module(p_module_name    => 'lslmodule4.v1',
                     p_base_path      => 'lslmodule4/v1/',
                     p_items_per_page => 5,
                     p_status         => 'PUBLISHED',
                     p_comments       => 'check supplier Module');             
  COMMIT;
END;
  

BEGIN
  ords.define_template(p_module_name => 'lslmodule4.v1',
                       p_pattern     => 'checksupplier/',
                       p_comments    => 'check supplier  ');

  COMMIT;
END;

begin
  ORDS.define_handler(
    p_module_name    => 'lslmodule4.v1',
    p_pattern        => 'checksupplier/',
    p_method         => 'POST',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => 'BEGIN
                           check_supplier(p_data => :body);
                         END;',
    p_items_per_page => 0);

  COMMIT;
END;


https://13.67.34.43:8443/ords/api/lslmodule4/v1/checksupplier/


SELECT * FROM product

{
  "PurchaseRequestId": "123",
  "Date": "string",
  "DateRequired": "string",
  "StoreId": 0,
  "Address": {
    "Street": "123 Example St nLevel 2",
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
      "PurchaseRequestLineId": "123",
      "ProductId": "d94c2221-4f48-4e3f-8153-89c42794ba6a",
      "Quantity": "5.4",
      "Unit": "ea",
      "SupplierId": "d94c2221-4f48-4e3f-8153-89c42794ba6a",
      "PerUnitCost": 4.55,
      "PerUnitCostTax": 0.45,
      "LineTotalCost": 4.55,
      "LineTotalCostTax": 0.45,
      "PerUnitPrice": 4.55,
      "PerUnitPriceTax": 0.45,
      "PurchaseOrderId": "321"
    }
  ]
}


