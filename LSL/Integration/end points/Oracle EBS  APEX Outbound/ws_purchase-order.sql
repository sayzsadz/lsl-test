
-- Create Module
BEGIN          
  ords.define_module(p_module_name    => 'lslmodule.v1',
                     p_base_path      => 'lslmodule/v1/',
                     p_items_per_page => 0,
                     p_status         => 'PUBLISHED',
                     p_comments       => 'purchase order module');             
  COMMIT;
END;
/

-- Create Template 
BEGIN
  ords.define_template(p_module_name => 'lslmodule.v1',
                       p_pattern     => 'purchase-orders/',
                       p_comments    => 'purchase order');

  COMMIT;
END;
/
-- Create Handler 
BEGIN
  ords.define_handler(p_module_name    => 'lslmodule.v1',
                      p_pattern        => 'purchase-orders/',
                      p_method         => 'POST',
                      p_source_type    => ords.source_type_collection_feed,
                      p_source         => ' SELECT ph.PurchaseOrderId AS "PurchaseOrderId",
                                            ph.SupplierId AS "SupplierId",
                                            ph.CreationDate AS "CreationDate",
                                            CURSOR(SELECT pl.PurchaseRequestLineId AS "PurchaseRequestLineId",
                                            pl.DateRequired AS "DateRequired",
                                            pha.ProductId AS "ProductId",--
                                            pha.Quantity AS "Quantity",--
                                            pl.Unit AS "Unit",
                                            pl.PerUnitCost AS "PerUnitCost",                         
                                            pl.PerUnitCostTax AS "PerUnitCostTax",
                                            pl.LineTotalCost AS "LineTotalCost",
                                            pl.LineTotalCostTax AS "LineTotalCostTax",
                                            NULL AS "MrpIncTax",--pl.MrpIncTax AS "MrpIncTax",
                                            NULL AS "TaxCode",--pl.TaxCode AS "TaxCode",
                                            pha.AUTHORIZATION_STATUS AS "Status"
                                            FROM   PURCHASE_REQUESTS_LINES pl
                                            WHERE  ph.PurchaseOrderId = pl.PurchaseOrderId
                                            ORDER BY pl.PurchaseRequestLineId) AS "purchaseorders"
                                            FROM   PURCHASE_REQUESTS_HEADER ph
                                                  ,PO_HEADERS_ALL@DATABASE_LINK_APEX_EBS pha
                                            WHERE   1 = 1
                                                    and pha.INTERFACE_SOURCE_CODE = ph.PurchaseOrderId
                                                    and ph.PurchaseOrderId = :ph.PurchaseOrderId --from the event based call form Oracle Alert
                                            ORDER BY trunc(ph.CreationDate) , ph.PurchaseOrderId',
                      p_items_per_page => 0,
                      p_comments       => 'purchse order');
  COMMIT;
  exception
    when others then
      dbms_output.put_line(''||sqlerrm);
END;
/

--https://13.67.34.43:8443/ords/api/lslmodule5/v1/purchase-order/

 CREATE TABLE PO_HEADER
   (	
       PurchaseOrderId VARCHAR2(100), 
       SupplierId VARCHAR2(100), 
       CreationDate VARCHAR2(100)
    );
  
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
   );