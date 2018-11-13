
-- Create Module
BEGIN          
  ords.define_module(p_module_name    => 'lslmodule.v1',
                     p_base_path      => 'lslmodule/v1/',
                     p_items_per_page => 0,
                     p_status         => 'PUBLISHED',
                     p_comments       => 'supplier return Module');             
  COMMIT;
END;
/

-- Create Template 
BEGIN
  ords.define_template(p_module_name => 'dev.v1',
                       p_pattern     => 'supplier-returns/',
                       p_comments    => 'supplier return');

  COMMIT;
END;
/

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
-- Create Handler 
BEGIN
  ords.define_handler(p_module_name    => 'dev.v1',
                      p_pattern        => 'supplier-returns/',
                      p_method         => 'POST',
                      p_source_type    => ords.source_type_collection_feed,
                      p_source         => '     SELECT  sup_ret_header.SupplierReturnId AS "SupplierReturnId"
                                                       ,sup_ret_header.PurchaseRequestId AS "PurchaseRequestId"
                                                       ,sup_ret_header.SupplierId AS "SupplierId"
                                                       ,sup_ret_header."Date" AS "Date"
                                                
                                                ,CURSOR(
                                                          select apss.ADDRESS_LINE1 as "Street"
                                                          ,apss.ADDRESS_LINE2 as  "City"
                                                          ,apss.STATE as "State"
                                                          ,apss.zip "PostCode"
                                                          ,ftl.NLS_TERRITORY AS "Country"
                                                          ,NVL(apsc.first_name || apsc.last_name, aps.vendor_name) as "ContactName"
                                                          ,apsc.phone as "Phone"
                                                          ,apsc.email_address as "Email"
                                                    from ap_suppliers aps
                                                        ,ap_supplier_sites_all apss
                                                        ,ap_supplier_contacts apsc        
                                                        ,hr_locations hla
                                                        ,apps.fnd_territories_vl ftl
                                                    where 1 = 1 
                                                          AND aps.vendor_id = apss.vendor_id
                                                          AND apss.bill_to_location_id = hla.location_id
                                                          AND apss.vendor_site_id = apsc.vendor_site_id(+)
                                                          AND hla.COUNTRY = ftl.TERRITORY_CODE
                                                          AND aps.vendor_id = sup_ret_header.vendor_id
                                                          AND apss.vendor_site_id = sup_ret_header.vendor_site_id
                                                           ) AS "Address"
                                                ,CURSOR(
                                                select  ret_req.SupplierReturnRequestLineId
                                                       ,ret_req.PRODUCTID
                                                       ,por.QUANTITY
                                                       ,por."Status"         
                                                           from
                                                           (
                                                           select RT.QUANTITY
                                                                 ,DECODE(RT.TRANSACTION_TYPE, q'[select 'RETURN TO VENDOR' frrom dual]', q'[select 'APPROVED' from dual]') AS "Status"
                                                                 ,PRHA.INTERFACE_SOURCE_CODE
                                                                 ,pl.item_id
                                                                 ,ph.vendor_id
                                                           FROM RCV_TRANSACTIONS RT
                                                ,RCV_SHIPMENT_LINES RSL
                                                ,RCV_SHIPMENT_HEADERS RSH
                                                ,po_headers_all ph
                                                ,po_lines_all pl
                                                ,PO_DISTRIBUTIONS_ALL PDA
                                                ,PO_REQ_DISTRIBUTIONS_ALL PRDA
                                                ,PO_REQUISITION_LINES_ALL PRLA
                                                ,PO_REQUISITION_HEADERS_ALL PRHA
                                                WHERE 1 = 1
                                                and RT.TRANSACTION_TYPE = q'[select 'RETURN TO VENDOR' from dual]'
                                                AND RT.SHIPMENT_LINE_ID = RSL.SHIPMENT_LINE_ID
                                                AND RSL.SHIPMENT_HEADER_ID = RSH.SHIPMENT_HEADER_ID
                                                AND ph.po_header_id       = pl.po_header_id
                                                AND rt.po_header_id       = ph.po_header_id
                                                AND rt.shipment_header_id = rsh.shipment_header_id
                                                AND rt.po_line_id         = pl.po_line_id
                                                AND PDA.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID
                                                AND PRDA.REQUISITION_LINE_ID = PRLA.REQUISITION_LINE_ID
                                                AND PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID
                                                AND pda.po_line_id = pl.po_line_id
                                                AND PDA.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID
                                                ) por
                                                ,(
                                                        select distinct (QUANTITY * -1) QUANTITY
                                                             , PURCHASEORDERID
                                                             , srl.PRODUCTID
                                                             , srl.SUPPLIERID
                                                             , srh.SupplierReturnRequestId
                                                             , srl.SupplierReturnRequestLineId
                                                             ,msi.inventory_item_id
                                                             ,aps.vendor_id
                                                        from SUPPLIER_RET_REQUESTS_HEADER@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG srh
                                                            ,SUPPLIER_RET_REQUESTS_LINES@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG srl
                                                            ,mtl_system_items_b msi
                                                            ,ap_suppliers aps
                                                            --,ap_supplier_sites_all apss
                                                        where 1 = 1
                                                              and srh.SupplierReturnRequestId = srl.SupplierReturnRequestId
                                                              and srl.PRODUCTID = msi.attribute10(+)
                                                --              and aps.vendor_id = apss.vendor_id
                                                              and srl.SUPPLIERID = aps.attribute10(+)
                                                              and srh.STATUS_FLAG is NULL
                                                      ) ret_req
                                                WHERE  1 = 1
                                                and ret_req.vendor_id = por.vendor_id(+)--BLANKET PO can be used
                                                --and ret_req.vendor_site_id = por.vendor_site_id(+)--BLANKET PO can be used
                                                and ret_req.inventory_item_id = por.item_id(+)--BLANKET PO can be used
                                                and NVL(ret_req.PURCHASEORDERID, 0) = NVL(por.INTERFACE_SOURCE_CODE,0)--BLANKET PO can be used
                                                --and por.PO_HEADER_ID =  X_PO_HEADER_ID--BLANKET PO can be used
                                                --and RT.TRANSACTION_ID in (select rt.parent_transaction_id from RCV_TRANSACTIONS RT where rt.po_header_id = X_PO_HEADER_ID)
                                                and NVL(por.INTERFACE_SOURCE_CODE, 0) = NVL(ret_req.PurchaseOrderId,0)
                                                and sup_ret_header.SupplierReturnId = ret_req.SupplierReturnRequestId
                                                and rownum = 1
                                                      ) AS "Lines"           
                                                from
                                                (select  ret_req.SupplierReturnId
                                                       ,ret_req.PurchaseRequestId
                                                       ,ret_req.SupplierId
                                                       ,por."Date" AS "Date"
                                                       ,por.vendor_id
                                                       ,por.vendor_site_id
                                                           from
                                                           (
                                                           select RT.QUANTITY
                                                                 ,RT.CREATION_DATE AS "Date"
                                                                 ,PRHA.INTERFACE_SOURCE_CODE
                                                                 ,pl.item_id
                                                                 ,ph.vendor_id
                                                                 ,ph.vendor_site_id
                                                                 ,RT.TRANSACTION_ID
                                                           FROM RCV_TRANSACTIONS RT
                                                ,RCV_SHIPMENT_LINES RSL
                                                ,RCV_SHIPMENT_HEADERS RSH
                                                ,po_headers_all ph
                                                ,po_lines_all pl
                                                ,PO_DISTRIBUTIONS_ALL PDA
                                                ,PO_REQ_DISTRIBUTIONS_ALL PRDA
                                                ,PO_REQUISITION_LINES_ALL PRLA
                                                ,PO_REQUISITION_HEADERS_ALL PRHA
                                                WHERE 1 = 1
                                                and RT.TRANSACTION_TYPE = q'[select 'RETURN TO VENDOR' from dual]'
                                                AND RT.SHIPMENT_LINE_ID = RSL.SHIPMENT_LINE_ID
                                                AND RSL.SHIPMENT_HEADER_ID = RSH.SHIPMENT_HEADER_ID
                                                AND PDA.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID
                                                AND PRDA.REQUISITION_LINE_ID = PRLA.REQUISITION_LINE_ID
                                                AND PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID
                                                AND rt.po_line_id         = pl.po_line_id
                                                AND ph.po_header_id       = pl.po_header_id
                                                AND rt.po_header_id       = ph.po_header_id
                                                AND rt.shipment_header_id = rsh.shipment_header_id
                                                AND rt.po_line_id         = pl.po_line_id
                                                ) por
                                                ,(
                                                        select distinct (srl.QUANTITY * -1) QUANTITY
                                                             , srl.PURCHASEORDERID
                                                             , srl.PRODUCTID
                                                             , srl.SUPPLIERID
                                                             , srh.SupplierReturnRequestId SupplierReturnId
                                                             , srl.SupplierReturnRequestLineId
                                                             , msi.INVENTORY_ITEM_ID
                                                             , aps.vendor_id
                                                             , apss.vendor_site_id
                                                             , prh.PURCHASEREQUESTID
                                                        from SUPPLIER_RET_REQUESTS_HEADER@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG srh
                                                            ,SUPPLIER_RET_REQUESTS_LINES@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG srl
                                                            ,PURCHASE_REQUESTS_HEADER@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG prh
                                                            ,PURCHASE_REQUESTS_LINES@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG prl
                                                            ,mtl_system_items_b msi
                                                            ,ap_suppliers aps
                                                            ,ap_supplier_sites_all apss
                                                        where 1 = 1
                                                              and srh.SupplierReturnRequestId = srl.SupplierReturnRequestId
                                                              and srl.PRODUCTID = msi.attribute10(+)
                                                              and aps.vendor_id = apss.vendor_id
                                                              and srl.SUPPLIERID = aps.attribute10(+)
                                                              and prh.PURCHASEREQUESTID = prl.PURCHASEREQUESTID
                                                              and prl.PURCHASEORDERID = srl.PURCHASEORDERID
                                                              and srh.STATUS_FLAG is NULL
                                                      ) ret_req
                                                WHERE  1 = 1
                                                and ret_req.vendor_id = por.vendor_id(+)--BLANKET PO can be used
                                                --and ret_req.vendor_site_id = por.vendor_site_id(+)--BLANKET PO can be used
                                                and ret_req.inventory_item_id = por.item_id(+)--BLANKET PO can be used
                                                and NVL(ret_req.PURCHASEORDERID, 0) = NVL(por.INTERFACE_SOURCE_CODE,0)--BLANKET PO can be used
                                                --and por.PO_HEADER_ID =  X_PO_HEADER_ID--BLANKET PO can be used
                                                --and RT.TRANSACTION_ID in (select rt.parent_transaction_id from RCV_TRANSACTIONS RT where rt.po_header_id = X_PO_HEADER_ID)
                                                and rownum = 1
                                                order by por.TRANSACTION_ID desc
                                                ) sup_ret_header;',
                      p_items_per_page => 0,
                      p_comments       => 'supplier return');
  COMMIT;
  exception
    when others then
      dbms_output.put_line(''||sqlerrm);
END;
/

--https://13.67.34.43:8443/ords/api/lslmodule5/v1/supplier-return/

 CREATE TABLE SUPPLIER_RETURN_HEADER
   (	
       PurchaseOrderId VARCHAR2(100), 
       SupplierId VARCHAR2(100), 
       CreationDate VARCHAR2(100)
    );
  
  CREATE TABLE SUPPLIER_RETURN_LINES
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