create or replace procedure XXPBSA_RETURN_TO_VENDOR(p_errbuf OUT VARCHAR2, p_retcode OUT VARCHAR2)
AS
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

SELECT 
 PO_HEADER_ID 
INTO 
 X_PO_HEADER_ID 
FROM PO_HEADERS_ALL
WHERE SEGMENT1 = '100030'
AND ORG_ID = 81;

DECLARE
CURSOR RT_DETAIL IS
SELECT 
ret_req.QUANTITY--RT.QUANTITY            -- RTI.QUANTITY
,RT.UNIT_OF_MEASURE    -- RTI.UNIT_OF_MEASURE
,RT.TRANSACTION_ID     -- RTI.PARENT_TRANSACTION_ID
,RT.SHIPMENT_HEADER_ID -- RTI.SHIPMENT_HEADER_ID
,RT.SHIPMENT_LINE_ID   -- RTI.SHIPMENT_LINE_ID
,RT.PO_HEADER_ID       -- RT.PO_HEADER_ID
,RSH.RECEIPT_NUM
,RSL.LINE_NUM
FROM RCV_TRANSACTIONS RT
,RCV_SHIPMENT_LINES RSL
,RCV_SHIPMENT_HEADERS RSH
,po_headers_all ph
,po_lines_all pl
,(
        select distinct QUANTITY
             , PURCHASEORDERID
             , msi.inventory_item_id
             , aps.vendor_id
             , apss.vendor_site_id
             , srl.PRODUCTID
             , srl.SUPPLIERID
        from SUPPLIER_RET_REQUESTS_HEADER@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG srh
            ,SUPPLIER_RET_REQUESTS_LINES@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG srl
            ,mtl_system_items_b msi
            ,ap_suppliers aps
            ,ap_supplier_sites_all apss
        where 1 = 1
              and srh.SupplierReturnRequestId = srl.SupplierReturnRequestId
              and srl.PRODUCTID = msi.attribute10
              and msi.organization_id in (select organization_id
                                          from org_organization_definitions
                                          where organization_code = 'OIN')
              and aps.vendor_id = apss.vendor_id
              and aps.attribute10 = srl.SUPPLIERID
              and srh.STATUS_FLAG is NULL
      ) ret_req
WHERE RT.PO_HEADER_ID =  X_PO_HEADER_ID
and RT.TRANSACTION_TYPE = X_TRANS_TYPE
AND RT.SHIPMENT_LINE_ID = RSL.SHIPMENT_LINE_ID
AND RSL.SHIPMENT_HEADER_ID = RSH.SHIPMENT_HEADER_ID
and RT.TRANSACTION_ID not in (select rt.parent_transaction_id from RCV_TRANSACTIONS RT where rt.po_header_id = X_PO_HEADER_ID)
    --AND rsh.receipt_num     = '100009'
    --AND ph.segment1           = '100003'
    AND ph.po_header_id       = pl.po_header_id
    AND rt.po_header_id       = ph.po_header_id
    --AND rt.shipment_header_id = rsh.shipment_header_id
    AND rt.po_line_id         = pl.po_line_id
    --AND rt.destination_type_code in ('INVENTORY', 'EXPENSE')
    --AND rt.transaction_type='DELIVER'
--    and ret_req.vendor_id = ph.vendor_id
--    and ret_req.vendor_site_id = ph.vendor_site_id(+)
--    and ret_req.inventory_item_id = pl.item_id
    and ret_req.PURCHASEORDERID = ph.INTERFACE_SOURCE_CODE(+)
;

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
,ATTRIBUTE15)
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
FROM DUAL;

DBMS_OUTPUT.PUT_LINE('Receipt: '||RTICURSOR.RECEIPT_NUM||' Line: '||RTICURSOR.LINE_NUM||' has been inserted into ROI for '||X_TRANS_TYPE||' with GROUP_ID '||RCV_INTERFACE_GROUPS_S.CURRVAL);

END LOOP;

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