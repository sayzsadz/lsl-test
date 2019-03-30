create or replace procedure XXPBSA_RETURN_TO_VENDOR(p_errbuf OUT VARCHAR2, p_retcode OUT VARCHAR2)
AS

--declare
 X_USER_ID            NUMBER;
 X_PO_HEADER_ID       NUMBER;
 X_VAL                NUMBER;

 X_TRANS_TYPE         VARCHAR2 (20);
 X_ATTRIBUTE_15       VARCHAR (200) := 'Rel 12 ezROI Script for Standard Purchase Orders Return (Doc ID 1340331.1)';
 V_CREATE_RTV         BOOLEAN := TRUE;  -- If TRUE 'RETURN TO VENDOR' will be attempted. If FALSE 'RETURN TO RECEIVING' will be attempted.
 V_RT_DELIVER         BOOLEAN := TRUE;  -- If TRUE Return performed on RT DELIVER. If FALSE Return performed on RT RECEIVE

 v_request_id         number;
 
 lv_status     VARCHAR2(10);
 lv_dev_status VARCHAR2(10);
 lv_message    VARCHAR2(100);
 ln_interval   NUMBER;
 lv_dev_phase  VARCHAR2(10);
 lv_phase             VARCHAR2(10);
     callv_status         BOOLEAN ;
     wait_status          BOOLEAN ;
     X_INTERFACE_SOURCE_CODE NUMBER;
 
 BEGIN
DBMS_OUTPUT.PUT_LINE('*** ezROI for Standard Purchase Orders Returns ***');

IF V_CREATE_RTV
THEN 
   DBMS_OUTPUT.PUT_LINE('V_CREATE_RTV = TRUE = RETURN TO VENDOR');
ELSE
   DBMS_OUTPUT.PUT_LINE('V_CREATE_RTV = FALSE = RETURN TO RECEIEVING');
end if;

IF V_RT_DELIVER
THEN 
  SELECT 'DELIVER'
  INTO X_TRANS_TYPE
  FROM DUAL;
ELSE
  SELECT 'RECEIVE'
  INTO X_TRANS_TYPE
  FROM DUAL;
end if;

DBMS_OUTPUT.PUT_LINE('V_RT_DELIVER = Returning '||X_TRANS_TYPE||' Transactions');
 
SELECT USER_ID INTO X_USER_ID
FROM FND_USER
WHERE USER_NAME = UPPER('SJAYASINGHE1');


      select distinct ph.po_header_id, PRHA.INTERFACE_SOURCE_CODE
      INTO 
            X_PO_HEADER_ID , X_INTERFACE_SOURCE_CODE
      FROM po_headers_all          ph,
           po_lines_all          pl,
           po_line_locations_all pll,
           po_distributions_all  pd,
           mtl_parameters        mp,
           mtl_system_items_b    msi,
           PO_REQ_DISTRIBUTIONS_ALL PRDA,
           PO_REQUISITION_LINES_ALL PRLA,
           PO_REQUISITION_HEADERS_ALL PRHA,
           deliverysummary@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ds,
           deliverysummaryline@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG dsl,
           PURCHASE_REQUESTS_HEADER@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG prh,
           PURCHASE_REQUESTS_LINES@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG prl,
           SUPPLIER_RET_REQUESTS_HEADER@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG srh,
           SUPPLIER_RET_REQUESTS_LINES@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG srl,
           ap_suppliers aps,
           (
            SELECT inv.invoice_id, pda.po_distribution_id, pl.item_id, inv.invoice_id
            FROM ap_invoice_distributions_all inv,
                 po_distributions_all         pda,
                 po_lines_all                 pl
            WHERE 1=1
                  and rownum = 1
                  AND pda.po_line_id = pl.po_line_id
                  and inv.po_distribution_id = pda.po_distribution_id 
            order by inv.invoice_id desc
            ) inv
     WHERE 1 = 1
           and pl.po_header_id = ph.po_header_id
           and pd.po_distribution_id = inv.po_distribution_id
           and msi.inventory_item_id = inv.item_id
           and srh.SupplierReturnRequestId = srl.SupplierReturnRequestId
           and srl.PRODUCTID = msi.attribute10(+)
           and srl.SUPPLIERID = aps.attribute10(+)
           and srh.STATUS_FLAG is NULL
           AND pl.po_line_id = pll.po_line_id
           AND pd.line_location_id = pll.line_location_id
           AND pd.po_line_id = pl.po_line_id
           AND pll.ship_to_organization_id = mp.organization_id
           AND ds.DeliveryId = dsl.DeliveryId
           AND srh.status_flag is null
           AND ds.EXTERNALREFERENCENUMBER = ph.SEGMENT1
           AND msi.inventory_item_id = pl.item_id
           AND msi.segment1 = dsl.PARTNUMBER
           AND pd.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID
           AND PRDA.REQUISITION_LINE_ID = PRLA.REQUISITION_LINE_ID
           AND PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID;

--SELECT PO_HEADER_ID
--INTO 
-- X_PO_HEADER_ID 
--FROM PO_HEADERS_ALL
--WHERE 1 = 1
--AND SEGMENT1 = '100067'
--AND ORG_ID = 81
--AND PO_HEADER_ID = 4023
--AND AUTHORIZATION_STATUS = 'APPROVED'
--order by po_header_id desc;

DECLARE
CURSOR RT_DETAIL IS

select *
from 
(
SELECT 
 ret_req.QUANTITY   --RT.QUANTITY            -- RTI.QUANTITY         
,UNIT_OF_MEASURE    -- RTI.UNIT_OF_MEASURE
,TRANSACTION_ID     -- RTI.PARENT_TRANSACTION_ID
,SHIPMENT_HEADER_ID -- RTI.SHIPMENT_HEADER_ID
,SHIPMENT_LINE_ID   -- RTI.SHIPMENT_LINE_ID
,PO_HEADER_ID       -- RT.PO_HEADER_ID
,RECEIPT_NUM
,LINE_NUM
from
(
  SELECT RT.QUANTITY            -- RTI.QUANTITY
        ,RT.UNIT_OF_MEASURE    -- RTI.UNIT_OF_MEASURE
        ,RT.TRANSACTION_ID     -- RTI.PARENT_TRANSACTION_ID
        ,RT.SHIPMENT_HEADER_ID -- RTI.SHIPMENT_HEADER_ID
        ,RT.SHIPMENT_LINE_ID   -- RTI.SHIPMENT_LINE_ID
        ,RT.PO_HEADER_ID       -- RT.PO_HEADER_ID
        ,RSH.RECEIPT_NUM
        ,RSL.LINE_NUM
        ,ph.vendor_id
        ,ph.vendor_site_id
        ,pl.item_id
        ,NVL(PRHA.INTERFACE_SOURCE_CODE,0) INTERFACE_SOURCE_CODE
    FROM RCV_TRANSACTIONS RT
        ,RCV_SHIPMENT_LINES RSL
        ,RCV_SHIPMENT_HEADERS RSH
        ,po_headers_all ph
        ,po_lines_all pl
        ,po_distributions_all  pd
        ,PO_REQ_DISTRIBUTIONS_ALL PRDA
        ,PO_REQUISITION_LINES_ALL PRLA
        ,PO_REQUISITION_HEADERS_ALL PRHA
  WHERE 1 = 1
        and RT.TRANSACTION_TYPE = X_TRANS_TYPE
        AND RT.SHIPMENT_LINE_ID = RSL.SHIPMENT_LINE_ID
        AND RSL.SHIPMENT_HEADER_ID = RSH.SHIPMENT_HEADER_ID
        AND pd.po_line_id         = pl.po_line_id
        AND ph.po_header_id       = pl.po_header_id
        AND rt.po_header_id       = ph.po_header_id
        AND rt.shipment_header_id = rsh.shipment_header_id
        AND rt.po_line_id         = pl.po_line_id
        AND pd.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID
        AND PRDA.REQUISITION_LINE_ID = PRLA.REQUISITION_LINE_ID
        AND PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID
) por
,(
       select distinct (srl.QUANTITY * -1) QUANTITY
             , prh.PURCHASEREQUESTID
             , msi.inventory_item_id
             , aps.vendor_id
             --, apss.vendor_site_id
             , srl.PRODUCTID
             , srl.SUPPLIERID
             , NVL(PRHA.INTERFACE_SOURCE_CODE, 0) INTERFACE_SOURCE_CODE
      FROM po_lines_all          pl,
           po_line_locations_all pll,
           po_distributions_all  pd,
           mtl_parameters        mp,
           mtl_system_items_b    msi,
           PO_REQ_DISTRIBUTIONS_ALL PRDA,
           PO_REQUISITION_LINES_ALL PRLA,
           PO_REQUISITION_HEADERS_ALL PRHA,
           deliverysummary@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ds,
           deliverysummaryline@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG dsl,
           PURCHASE_REQUESTS_HEADER@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG prh,
           PURCHASE_REQUESTS_LINES@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG prl,
           SUPPLIER_RET_REQUESTS_HEADER@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG srh,
           SUPPLIER_RET_REQUESTS_LINES@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG srl,
           ap_suppliers aps
     WHERE 1 = 1
           and srh.SupplierReturnRequestId = srl.SupplierReturnRequestId
           and srl.PRODUCTID = msi.attribute10(+)
           and srl.SUPPLIERID = aps.attribute10(+)
           and srh.STATUS_FLAG is NULL
           AND pl.po_line_id = pll.po_line_id
           AND pd.line_location_id = pll.line_location_id
           AND pd.po_line_id = pl.po_line_id
           AND pll.ship_to_organization_id = mp.organization_id
           AND ds.DeliveryId = dsl.DeliveryId
           AND srh.status_flag is null
           AND msi.inventory_item_id = pl.item_id
           AND msi.segment1 = dsl.PARTNUMBER
           AND pd.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID
           AND PRDA.REQUISITION_LINE_ID = PRLA.REQUISITION_LINE_ID
           AND PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID
           AND rownum = 1
        order by INTERFACE_SOURCE_CODE desc     
 ) ret_req
WHERE  1 = 1
and ret_req.vendor_id = por.vendor_id(+)
and ret_req.inventory_item_id = por.item_id(+)
order by TRANSACTION_ID desc
)
where 1=1
      and rownum = 1;

BEGIN

select RCV_INTERFACE_GROUPS_S.NEXTVAL into X_VAL from dual;

FOR RTICURSOR IN RT_DETAIL LOOP



IF V_CREATE_RTV
THEN 
  SELECT 'RETURN TO VENDOR'
  INTO X_TRANS_TYPE
  FROM DUAL;
ELSE
  SELECT 'RETURN TO RECEIVING'
  INTO X_TRANS_TYPE
  FROM DUAL;
END IF;

INSERT INTO RCV_TRANSACTIONS_INTERFACE
(INTERFACE_TRANSACTION_ID
,GROUP_ID

,LAST_UPDATE_DATE
,LAST_UPDATED_BY
,CREATION_DATE
,CREATED_BY
,LAST_UPDATE_LOGIN

,TRANSACTION_TYPE  -- X_TRANS_TYPE
,TRANSACTION_DATE
,PROCESSING_STATUS_CODE
,PROCESSING_MODE_CODE
,TRANSACTION_STATUS_CODE

,QUANTITY               -- RT.QUANTITY
,UNIT_OF_MEASURE        -- RT.UNIT_OF_MEASURE 
,PARENT_TRANSACTION_ID  -- RT.TRANSACTION_ID
,SHIPMENT_HEADER_ID     -- RT.SHIPMENT_HEADER_ID
,SHIPMENT_LINE_ID       -- RT.SHIPMENT_LINE_ID
,PO_HEADER_ID           -- RT.PO_HEADER_ID - required for RTI to show in RDA Report

,VALIDATION_FLAG
,ORG_ID
,ATTRIBUTE15
,CREATE_DEBIT_MEMO_FLAG)
select
 RCV_TRANSACTIONS_INTERFACE_S.NEXTVAL  -- INTERFACE_TRANSACTION_ID
,RCV_INTERFACE_GROUPS_S.CURRVAL        -- GROUP_ID

,SYSDATE   -- LAST_UPDATE_DATE
,X_USER_ID -- LAST_UPDATED_BY
,SYSDATE   -- CREATION_DATE
,X_USER_ID -- CREATED_BY
,0         -- LAST_UPDATE_LOGIN

,X_TRANS_TYPE   -- TRANSACTION_TYPE
,SYSDATE        -- TRANSACTION_DATE
,'PENDING'      -- PROCESSING_STATUS_CODE
,'BATCH'        -- PROCESSING_MODE_CODE
,'PENDING'      -- TRANSACTION_STATUS_CODE

,RTICURSOR.QUANTITY         -- QUANTITY  -- RT.QUANTITY
,RTICURSOR.UNIT_OF_MEASURE  -- UNIT_OF_MEASURE  -- RT.UNIT_OF_MEASURE
,RTICURSOR.TRANSACTION_ID   -- PARENT_TRANSACTION_ID  -- RT.TRANSACTION_ID

,RTICURSOR.SHIPMENT_HEADER_ID  -- SHIPMENT_HEADER_ID  -- RT.SHIPMENT_HEADER_ID
,RTICURSOR.SHIPMENT_LINE_ID    -- SHIPMENT_LINE_ID  -- RT.SHIPMENT_LINE_ID
,RTICURSOR.PO_HEADER_ID        -- PO_HEADER_ID  -- RT.PO_HEADER_ID

,'Y'
,81
,X_ATTRIBUTE_15
,'Y'
FROM DUAL;

DBMS_OUTPUT.PUT_LINE('Receipt: '||RTICURSOR.RECEIPT_NUM||' Line: '||RTICURSOR.LINE_NUM||' has been inserted into ROI for '||X_TRANS_TYPE||' with GROUP_ID '||RCV_INTERFACE_GROUPS_S.CURRVAL);

END LOOP;

update SUPPLIER_RET_REQUESTS_HEADER@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG
set STATUS_FLAG = 'P'
where STATUS_FLAG is null;

DBMS_OUTPUT.PUT_LINE('*** ezROI COMPLETE - End ***');

END; 
COMMIT;



BEGIN
apps.mo_global.init ('PO');
apps.mo_global.set_policy_context ('S',204);
apps.fnd_global.apps_initialize ( user_id => 0, resp_id => 20707, resp_appl_id => 201 );
--------CALLING STANDARD RECEIVING TRANSACTION PROCESSOR ---------------------------------

  v_request_id   := apps.fnd_request.submit_request ( application => 'PO', 
                                                      PROGRAM => 'RVCTP', 
                                                      argument1 => 'BATCH', 
                                                      argument2 => apps.rcv_interface_groups_s.currval, 
                                                      argument3 => 81);
                                                      commit;
    dbms_output.put_line('Request Id '||v_request_id);                                                 

   wait_status := fnd_concurrent.wait_for_request (v_request_id, 60 , 0, lv_phase , lv_status , lv_dev_phase, lv_dev_status, lv_message);
    -- callv_status :=fnd_concurrent.get_request_status(ln_request_id, '', '',
    --          rphase,rstatus,dphase,dstatus, message);
    fnd_file.put_line(fnd_file.log,'dphase = '||lv_dev_phase||'and '||'dstatus ='||lv_dev_status) ;
    IF UPPER(lv_dev_phase)='COMPLETE' AND UPPER(lv_dev_status)= 'NORMAL' THEN
      dbms_output.put_line ('Return to Vendor program completed successfully');
      fnd_file.put_line(fnd_file.log,'Return to Vendor program completed successfully');
    END IF;


END;
    
END;
/