
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
  ords.define_template(p_module_name => 'dev.v1',
                       p_pattern     => 'purchase-orders/',
                       p_comments    => 'purchase order');

  COMMIT;
END;
/
-- Create Handler 
BEGIN
  ords.define_handler(p_module_name    => 'dev.v1',
                      p_pattern        => 'purchase-orders/',
                      p_method         => 'POST',
                      p_source_type    => ords.source_type_collection_feed,
                      p_source         => ' SELECT distinct NVL(pl_outer.PurchaseOrderId, NULL) AS "PurchaseOrderId",
                                            pl_outer.SupplierId AS "SupplierId",
                                            CURSOR(SELECT distinct pl.PurchaseRequestLineId AS "PurchaseRequestLineId",
                                            PRLA.NEED_BY_DATE AS "DateRequired",
                                            pl.ProductId AS "ProductId",--
                                            pl.Quantity AS "Quantity",--
                                            pl.Unit AS "Unit",
                                            pl.PerUnitCost AS "PerUnitCost",                         
                                            pl.PerUnitCostTax AS "PerUnitCostTax",
                                            pl.LineTotalCost AS "LineTotalCost",
                                            pl.LineTotalCostTax AS "LineTotalCostTax",
                                            NULL AS "MrpIncTax",--pl.MrpIncTax AS "MrpIncTax",
                                            NULL AS "TaxCode",--pl.TaxCode AS "TaxCode",
                                            pha.AUTHORIZATION_STATUS AS "Status"
                                            FROM   PURCHASE_REQUESTS_LINES pl
                                                  ,PURCHASE_REQUESTS_HEADER ph
                                                  ,PO_HEADERS_ALL@DATABASE_LINK_APEX_EBS pha
                                                  ,PO_LINES_ALL@DATABASE_LINK_APEX_EBS pla
                                                  ,PO_DISTRIBUTIONS_ALL@DATABASE_LINK_APEX_EBS PDA
                                                  ,PO_REQ_DISTRIBUTIONS_ALL@DATABASE_LINK_APEX_EBS PRDA
                                                  ,PO_REQUISITION_LINES_ALL@DATABASE_LINK_APEX_EBS PRLA
                                                  ,PO_REQUISITION_HEADERS_ALL@DATABASE_LINK_APEX_EBS PRHA
                                            WHERE  ph.PurchaseRequestId = pl.PurchaseRequestId
                                                   and ph_outer.PurchaseRequestId = ph.PurchaseRequestId
                                                   and PRHA.INTERFACE_SOURCE_CODE = NVL(pl.PurchaseOrderId, ph.PurchaseRequestId)
                                                   AND PDA.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID
                                                   AND PRDA.REQUISITION_LINE_ID = PRLA.REQUISITION_LINE_ID
                                                   AND PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID
                                                   AND pda.po_line_id = pla.po_line_id
                                                   AND PDA.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID
                                                   AND pha.po_header_id = pla.po_header_id
                                                   order by pl.PurchaseRequestLineId desc) AS "Lines"
                                            FROM   PURCHASE_REQUESTS_LINES pl_outer
                                                  ,PURCHASE_REQUESTS_HEADER ph_outer
                                                  ,PO_HEADERS_ALL@DATABASE_LINK_APEX_EBS pha_outer
                                                  ,PO_LINES_ALL@DATABASE_LINK_APEX_EBS pla_outer
                                                  ,PO_DISTRIBUTIONS_ALL@DATABASE_LINK_APEX_EBS PDA_outer
                                                  ,PO_REQ_DISTRIBUTIONS_ALL@DATABASE_LINK_APEX_EBS PRDA_outer
                                                  ,PO_REQUISITION_LINES_ALL@DATABASE_LINK_APEX_EBS PRLA_outer
                                                  ,PO_REQUISITION_HEADERS_ALL@DATABASE_LINK_APEX_EBS PRHA_outer
                                            WHERE  1 = 1
                                                   AND ph_outer.PurchaseRequestId = pl_outer.PurchaseRequestId
                                                   and NVL(PRHA_outer.INTERFACE_SOURCE_CODE, 0) = NVL(pl_outer.PurchaseOrderId, ph_outer.PurchaseRequestId)
                                                   AND PDA_outer.REQ_DISTRIBUTION_ID = PRDA_outer.DISTRIBUTION_ID
                                                   AND PRDA_outer.REQUISITION_LINE_ID = PRLA_outer.REQUISITION_LINE_ID
                                                   AND PRLA_outer.REQUISITION_HEADER_ID = PRHA_outer.REQUISITION_HEADER_ID
                                                   AND pda_outer.po_line_id = pla_outer.po_line_id
                                                   AND PDA_outer.REQ_DISTRIBUTION_ID = PRDA_outer.DISTRIBUTION_ID
                                                   AND pha_outer.po_header_id = pla_outer.po_header_id
                                                   AND rownum = 1
                                             order by pha_outer.last_update_date desc',
                      p_items_per_page => 0,
                      p_comments       => 'purchse-order');
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
   
   update PO_REQUISITION_HEADERS_ALL@DATABASE_LINK_APEX_EBS
   set INTERFACE_SOURCE_CODE = null
   where INTERFACE_SOURCE_CODE = '7'