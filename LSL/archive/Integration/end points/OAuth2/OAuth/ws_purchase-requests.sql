-- Create Module
BEGIN          
  ords.define_module(p_module_name    => 'lslmodule.v1',
                     p_base_path      => 'lslmodule/v1/',
                     p_items_per_page => 0,
                     p_status         => 'PUBLISHED',
                     p_comments       => 'PR module');             
  COMMIT;
END;
/

-- Create Template 
BEGIN
  ords.define_template(p_module_name => 'lslmodule.v1',
                       p_pattern     => 'getpr/',
                       p_comments    => 'PR');

  COMMIT;
END;
/
-- Create Handler 
BEGIN
  ords.define_handler(p_module_name    => 'lslmodule.v1',
                      p_pattern        => 'getpr/',
                      p_method         => 'GET',
                      p_source_type    => ORDS.source_type_collection_feed,
                      p_source         => ' SELECT prh.*,
                                            CURSOR(SELECT prl.*
                                            FROM PURCHASE_REQUESTS_LINES prl
                                            WHERE prh.PurchaseRequestId = prl.PURCHASEORDERID) as PurchaseRequestLines
                                            FROM PURCHASE_REQUESTS_HEADER prh',
                      p_items_per_page => 0,
                      p_comments       => 'get PR');
  COMMIT;
  exception
    when others then
      dbms_output.put_line(''||sqlerrm);
END;
/

CREATE OR REPLACE PROCEDURE create_purchase_request (p_data  IN  BLOB)
AS
BEGIN
   INSERT INTO PURCHASE_REQUESTS_HEADER (PurchaseRequestId, DateRequired, StoreId, Street, City, State, PostCode, Country, ContactName, Phone, Email)
   SELECT PurchaseRequestId, DateRequired, StoreId, Street, City, State, PostCode, Country, ContactName, Phone, Email        
   FROM json_table(p_data format JSON , '$' COLUMNS 
   ( PurchaseRequestId VARCHAR2 PATH '$.PurchaseRequestId',    
     DateRequired VARCHAR2 PATH '$.DateRequired', 
     StoreId VARCHAR2 PATH '$.StoreId',
     Street VARCHAR2 PATH '$.Address.Street', 
     City VARCHAR2 PATH '$.Address.City', 
     State VARCHAR2 PATH '$.Address.State', 
     PostCode VARCHAR2 PATH '$.Address.PostCode', 
     Country VARCHAR2 PATH '$.Address.Country', 
     ContactName VARCHAR2 PATH '$.Address.ContactName', 
     Phone VARCHAR2 PATH '$.Address.Phone', 
     Email VARCHAR2 PATH '$.Address.Email'));
             
   INSERT INTO PURCHASE_REQUESTS_LINES (PurchaseRequestLineId, ProductId, Quantity, Unit, SupplierId, PerUnitCost, 
          PerUnitCostTax, LineTotalCost, LineTotalCostTax, PerUnitPrice, PerUnitPriceTax, PurchaseOrderId)
   SELECT  PurchaseRequestLineId, ProductId, Quantity, Unit, SupplierId, PerUnitCost, 
          PerUnitCostTax, LineTotalCost, LineTotalCostTax, PerUnitPrice, PerUnitPriceTax, PurchaseOrderId     
         FROM json_table(p_data format JSON , '$' COLUMNS 
         ( PurchaseRequestId VARCHAR2 PATH '$.PurchaseRequestId',    
           DateRequired VARCHAR2 PATH '$.DateRequired', 
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
         COLUMNS ( PurchaseRequestLineId VARCHAR2 PATH '$.PurchaseRequestLineId', 
                   ProductId VARCHAR2 PATH '$.ProductId',
                   Quantity VARCHAR2 PATH '$.Quantity',
                   Unit VARCHAR2 PATH '$.Unit',
                   SupplierId VARCHAR2 PATH '$.SupplierId',
                   PerUnitCost VARCHAR2 PATH '$.PerUnitCost',
                   PerUnitCostTax VARCHAR2 PATH '$.PerUnitCostTax',
                   LineTotalCost VARCHAR2 PATH '$.LineTotalCost',
                   LineTotalCostTax VARCHAR2 PATH '$.LineTotalCostTax',
                   PerUnitPrice VARCHAR2 PATH '$.PerUnitPrice',
                   PerUnitPriceTax VARCHAR2 PATH '$.PerUnitPriceTax',
                   PurchaseOrderId VARCHAR2 PATH '$.PurchaseOrderId' )));
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    HTP.print(SQLERRM);
END;

CREATE OR REPLACE PROCEDURE create_purchase_request (p_data  IN  BLOB)
AS
BEGIN
   INSERT INTO PURCHASE_REQUESTS_HEADER (PurchaseRequestId, DateRequired, StoreId, Street, City, State, PostCode, Country, ContactName, Phone, Email)
   SELECT PurchaseRequestId, DateRequired, StoreId, Street, City, State, PostCode, Country, ContactName, Phone, Email        
   FROM json_table(p_data format JSON , '$' COLUMNS 
   ( PurchaseRequestId VARCHAR2 PATH '$.PurchaseRequestId',    
     DateRequired VARCHAR2 PATH '$.DateRequired', 
     StoreId VARCHAR2 PATH '$.StoreId',
     Street VARCHAR2 PATH '$.Address.Street', 
     City VARCHAR2 PATH '$.Address.City', 
     State VARCHAR2 PATH '$.Address.State', 
     PostCode VARCHAR2 PATH '$.Address.PostCode', 
     Country VARCHAR2 PATH '$.Address.Country', 
     ContactName VARCHAR2 PATH '$.Address.ContactName', 
     Phone VARCHAR2 PATH '$.Address.Phone', 
     Email VARCHAR2 PATH '$.Address.Email'));
             

   SELECT  PurchaseRequestLineId, ProductId, Quantity, Unit, SupplierId, PerUnitCost, 
          PerUnitCostTax, LineTotalCost, LineTotalCostTax, PerUnitPrice, PerUnitPriceTax, PurchaseOrderId     
         FROM json_table(p_data format JSON , '$' COLUMNS 
         ( PurchaseRequestId VARCHAR2 PATH '$.PurchaseRequestId',    
           DateRequired VARCHAR2 PATH '$.DateRequired', 
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
         COLUMNS ( PurchaseRequestLineId VARCHAR2 PATH '$.PurchaseRequestLineId', 
                   ProductId VARCHAR2 PATH '$.ProductId',
                   Quantity VARCHAR2 PATH '$.Quantity',
                   Unit VARCHAR2 PATH '$.Unit',
                   SupplierId VARCHAR2 PATH '$.SupplierId',
                   PerUnitCost VARCHAR2 PATH '$.PerUnitCost',
                   PerUnitCostTax VARCHAR2 PATH '$.PerUnitCostTax',
                   LineTotalCost VARCHAR2 PATH '$.LineTotalCost',
                   LineTotalCostTax VARCHAR2 PATH '$.LineTotalCostTax',
                   PerUnitPrice VARCHAR2 PATH '$.PerUnitPrice',
                   PerUnitPriceTax VARCHAR2 PATH '$.PerUnitPriceTax',
                   PurchaseOrderId VARCHAR2 PATH '$.PurchaseOrderId' )));
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    HTP.print(SQLERRM);
END;



BEGIN
       
  ords.define_module(p_module_name    => 'lslmodule3.v1',
                     p_base_path      => 'lslmodule3/v1/',
                     p_items_per_page => 5,
                     p_status         => 'PUBLISHED',
                     p_comments       => 'purchase request Module');             
  COMMIT;
END;
  
;
BEGIN
  ords.define_template(p_module_name => 'lslmodule3.v1',
                       p_pattern     => 'purchaserequest/',
                       p_comments    => 'purchase request template ');

  COMMIT;
END;

begin
  ORDS.define_handler(
    p_module_name    => 'lslmodule3.v1',
    p_pattern        => 'purchaserequest/',
    p_method         => 'POST',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => 'BEGIN
                           create_purchase_request(p_data => :body);
                         END;',
    p_items_per_page => 0);

  COMMIT;
END;


https://13.67.34.43:8443/ords/api/lslmodule3/v1/purchaserequest/


SELECT * FROM PURCHASE_REQUESTS_HEADER 

SELECT * FROM PURCHASE_REQUESTS_LINES

{
  "PurchaseRequestId": "123",
  "DateRequired": "string",
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

create table PURCHASE_REQUESTS_HEADER
as
SELECT 'TEST' PurchaseRequestId, 'TEST' DateRequired, 'TEST' StoreId, 'TEST' Street, 'TEST' City, 'TEST' State, 'TEST' PostCode, 'TEST' Country, 'TEST' ContactName, 'TEST' Phone, 'TEST' Email 
from dual;
create table PURCHASE_REQUESTS_LINES
as
SELECT  'TEST' PurchaseRequestLineId, 'TEST' ProductId, 'TEST' Quantity, 'TEST' Unit, 'TEST' SupplierId, 'TEST' PerUnitCost, 
          'TEST' PerUnitCostTax, 'TEST' LineTotalCost, 'TEST' LineTotalCostTax, 'TEST' PerUnitPrice, 'TEST' PerUnitPriceTax, 'TEST' PurchaseOrderId     
          from dual;
          
          
          select *
          from PURCHASE_REQUESTS_LINES;
          
          drop table PURCHASE_REQUESTS_LINES;
          
  CREATE TABLE "PURCHASE_REQUESTS_LINES" 
   (	"PURCHASEREQUESTLINEID" VARCHAR2(100), 
	"PRODUCTID" VARCHAR2(100), 
	"QUANTITY" VARCHAR2(100), 
	"UNIT" VARCHAR2(100), 
	"SUPPLIERID" VARCHAR2(100), 
	"PERUNITCOST" VARCHAR2(100), 
	"PERUNITCOSTTAX" VARCHAR2(100), 
	"LINETOTALCOST" VARCHAR2(100), 
	"LINETOTALCOSTTAX" VARCHAR2(100), 
	"PERUNITPRICE" VARCHAR2(100), 
	"PERUNITPRICETAX" VARCHAR2(100), 
	"PURCHASEORDERID" VARCHAR2(100)
   )