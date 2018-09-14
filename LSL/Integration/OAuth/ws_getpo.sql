
-- Create Module
BEGIN          
  ords.define_module(p_module_name    => 'lslmodule.v1',
                     p_base_path      => 'lslmodule/v1/',
                     p_items_per_page => 0,
                     p_status         => 'PUBLISHED',
                     p_comments       => 'get po Module');             
  COMMIT;
END;
/

-- Create Template 
BEGIN
  ords.define_template(p_module_name => 'lslmodule.v1',
                       p_pattern     => 'purchase-orders/',
                       p_comments    => 'get po ');

  COMMIT;
END;
/
-- Create Handler 
BEGIN
  ords.define_handler(p_module_name    => 'lslmodule.v1',
                      p_pattern        => 'purchase-orders/',
                      p_method         => 'GET',
                      p_source_type    => ords.source_type_collection_feed,
                      p_source         => ' SELECT ph.PurchaseOrderId AS "PurchaseOrderId",
                                            ph.SupplierId AS "SupplierId",
                                            ph.CreationDate AS "CreationDate",
                                            CURSOR(SELECT pl.PurchaseRequestLineId AS "PurchaseRequestLineId",
                                            pl.DateRequired AS "DateRequired",
                                            pl.ProductId AS "ProductId",
                                            pl.Quantity AS "Quantity",
                                            pl.Unit AS "Unit",
                                            pl.PerUnitCost AS "PerUnitCost",                         
                                            pl.PerUnitCostTax AS "PerUnitCostTax",
                                            pl.LineTotalCost AS "LineTotalCost",
                                            pl.LineTotalCostTax AS "LineTotalCostTax",
                                            pl.MrpIncTax AS "MrpIncTax",
                                            pl.TaxCode AS "TaxCode",
                                            pl.Status AS "Status"
                                            FROM   PO_LINES pl
                                            WHERE  ph.PurchaseOrderId = pl.PurchaseOrderId
                                            ORDER BY pl.PurchaseRequestLineId) AS "purchaseorders"
                                            FROM   PO_HEADER ph
                                            ORDER BY trunc(ph.CreationDate) , ph.PurchaseOrderId',
                      p_items_per_page => 0,
                      p_comments       => 'get po ');
  COMMIT;
  exception
    when others then
      dbms_output.put_line(''||sqlerrm);
END;
/

alter table PO_LINES add PurchaseOrderId varchar2(200);

SELECT deptno, dname, loc 
FROM dept ORDER BY deptno;
select *
from PO_HEADER;
create table PO_LINES
as
SELECT  'test' AS "PurchaseRequestLineId",
        'test' AS "DateRequired",
        'test' AS "ProductId",
        'test' AS "Quantity",
        'test' AS "Unit",
        'test' AS "PerUnitCost",                         
        'test' AS "PerUnitCostTax",
        'test' AS "LineTotalCost",
        'test' AS "LineTotalCostTax",
        'test' AS "MrpIncTax",
        'test' AS "TaxCode",
        'test' AS "Status"
from dual;

https://13.67.34.43:8443/ords/api/lslmodule5/v1/getpo/

drop table PO_HEADER;
 CREATE TABLE PO_HEADER
   (	
     PurchaseOrderId VARCHAR2(100), 
	   SupplierId VARCHAR2(100), 
	   CreationDate VARCHAR2(100)
   );
   select *
   from PO_LINES;
   drop table PO_LINES;
  CREATE TABLE PO_LINES
   (	
    PurchaseRequestLineId VARCHAR2(100), 
    DateRequired VARCHAR2(100), 
    ProductId VARCHAR2(100), 
    Quantity VARCHAR2(100), 
    Unit VARCHAR2(100), 
    PerUnitCost VARCHAR2(100), 
    PerUnitCostTax VARCHAR2(100), 
    LineTotalCost VARCHAR2(100), 
    LineTotalCostTax VARCHAR2(100), 
    MrpIncTax VARCHAR2(100), 
    TaxCode VARCHAR2(100), 
    Status VARCHAR2(100)
   )