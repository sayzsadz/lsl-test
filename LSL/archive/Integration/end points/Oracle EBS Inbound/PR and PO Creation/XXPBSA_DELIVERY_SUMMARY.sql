create or replace procedure XXPBSA_DELIVERY_SUMMARY(p_errbuf OUT VARCHAR2, p_retcode OUT VARCHAR2)
AS
      ln_user_id      NUMBER;
      ln_po_header_id NUMBER;
      ln_vendor_id    NUMBER;
      lv_segment1     VARCHAR2(20);
      ln_org_id       NUMBER;
      ln_line_num     NUMBER;
      ln_parent_txn_id NUMBER;
      ln_INTERFACE_SOURCE_CODE NUMBER;
  
         v_request_id         number;
     
         lv_status     VARCHAR2(10);
         lv_dev_status VARCHAR2(10);
         lv_message    VARCHAR2(100);
         ln_interval   NUMBER;
         lv_dev_phase  VARCHAR2(10);
         lv_phase      VARCHAR2(10);
         callv_status  BOOLEAN ;
         wait_status   BOOLEAN ;
         
  CURSOR po_header IS
    
    SELECT  distinct ph.PO_HEADER_ID
            ,ph.vendor_id
            ,ph.segment1
            ,ph.org_id
            ,PRHA.INTERFACE_SOURCE_CODE
    FROM po_headers_all ph
        ,po_lines_all pl
        ,PO_DISTRIBUTIONS_ALL PD
        ,PO_REQ_DISTRIBUTIONS_ALL PRDA
        ,PO_REQUISITION_LINES_ALL PRLA
        ,PO_REQUISITION_HEADERS_ALL PRHA
        ,deliverysummary@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ds
        ,deliverysummaryline@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG dsl
        ,PURCHASE_REQUESTS_HEADER@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG prh
        ,PURCHASE_REQUESTS_LINES@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG prl
        ,mtl_system_items_b msi
    WHERE   1 = 1
           AND ph.po_header_id = pl.po_header_id
           AND pd.po_line_id = pl.po_line_id
           AND ds.DeliveryId = dsl.DeliveryId
           AND ds.status_flag is null
           AND prh.PURCHASEREQUESTID = PRHA.INTERFACE_SOURCE_CODE
           AND msi.inventory_item_id = pl.item_id
           AND msi.segment1 = dsl.PARTNUMBER
           AND ds.EXTERNALREFERENCENUMBER = ph.SEGMENT1
           AND pd.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID
           AND PRDA.REQUISITION_LINE_ID = PRLA.REQUISITION_LINE_ID
           AND PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID
           and ph.AUTHORIZATION_STATUS = 'APPROVED'
           --AND NVL(ds.PurchaseOrderID, 0) = NVL(prl.PurchaseOrderID, 0)
           --and rownum = 1
    order by PRHA.INTERFACE_SOURCE_CODE desc;
 
  CURSOR po_line IS
    SELECT distinct pl.item_id,
           pl.po_line_id,
           pl.line_num,
           dsl.quantity quantity,
           pd.po_distribution_id,
           pl.unit_meas_lookup_code,
           mp.organization_code,
           pll.line_location_id,
           pll.closed_code,
           (pd.quantity_ordered - pll.quantity_received) quantity_received,
           pll.cancel_flag,
           pll.shipment_num,
           PRHA.INTERFACE_SOURCE_CODE
      FROM po_headers_all        ph,
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
           PURCHASE_REQUESTS_LINES@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG prl
     WHERE 1 = 1
           --AND pl.po_header_id in (select max(po_header_id) from po_headers_all ph)--use a BLANKET PO
           AND pl.po_line_id = pll.po_line_id
           AND ph.po_header_id = pd.po_header_id
           AND pd.line_location_id = pll.line_location_id
           AND pd.po_line_id = pl.po_line_id
           AND pll.ship_to_organization_id = mp.organization_id
           AND ds.DeliveryId = dsl.DeliveryId
           --AND NVL(ds.PurchaseOrderID, 0) = NVL(prl.PurchaseOrderID, 0)
           AND ds.EXTERNALREFERENCENUMBER = ph.SEGMENT1
           AND ds.status_flag is null
           AND prh.PURCHASEREQUESTID = PRHA.INTERFACE_SOURCE_CODE
           AND msi.inventory_item_id = pl.item_id
           AND msi.segment1 = dsl.PARTNUMBER
           AND pd.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID
           AND PRDA.REQUISITION_LINE_ID = PRLA.REQUISITION_LINE_ID
           AND PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID
           and ph.AUTHORIZATION_STATUS = 'APPROVED'
           --and rownum = 1
           order by PRHA.INTERFACE_SOURCE_CODE desc
           ;
      
BEGIN
  dbms_output.put_line('***ezroi rcv api insert script***');

  for cur_headers in po_header
  loop

         ln_po_header_id            := cur_headers.PO_HEADER_ID;
         ln_vendor_id               := cur_headers.vendor_id;
         lv_segment1                := cur_headers.segment1;
         ln_org_id                  := cur_headers.org_id;
         ln_INTERFACE_SOURCE_CODE   := cur_headers.INTERFACE_SOURCE_CODE;

  SELECT user_id
    INTO ln_user_id
    FROM fnd_user
   WHERE user_name = upper('SJAYASINGHE1');
  
  INSERT INTO rcv_headers_interface
    (header_interface_id,
     group_id,
     processing_status_code,
     receipt_source_code,
     transaction_type,
     last_update_date,
     last_updated_by,
     last_update_login,
     vendor_id,
     expected_receipt_date,
     validation_flag,
     org_id)
    SELECT rcv_headers_interface_s.nextval,
           rcv_interface_groups_s.nextval,
           'PENDING',
           'VENDOR',
           'NEW',
           sysdate,
           ln_user_id,
           0,
           ln_vendor_id,
           sysdate,
           'y',
           ln_org_id
      FROM dual;
     
  FOR cur_po_line IN po_line
  LOOP
    IF cur_po_line.closed_code IN ('APPROVED', 'OPEN')
       AND cur_po_line.quantity_received >= cur_po_line.quantity
       AND NVL(cur_po_line.cancel_flag,'N') = 'N'
    THEN
      INSERT INTO rcv_transactions_interface
        (interface_transaction_id,
         group_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         transaction_type,
         transaction_date,
         processing_status_code,
         processing_mode_code,
         transaction_status_code,
         po_header_id,
         po_line_id,
         item_id,
         quantity,
         unit_of_measure,
         po_line_location_id,
         po_distribution_id,
         auto_transact_code,
         receipt_source_code,
         to_organization_code,
         source_document_code,
         header_interface_id,
         validation_flag,
         org_id)
        SELECT rcv_transactions_interface_s.nextval,
               rcv_interface_groups_s.currval,
               sysdate,
               ln_user_id,
               sysdate,
               ln_user_id,
               0,
               'RECEIVE',
               SYSDATE,
               'PENDING',
               'BATCH',
               'PENDING',
               ln_po_header_id,
               cur_po_line.po_line_id,
               cur_po_line.item_id,
               cur_po_line.quantity,
               cur_po_line.unit_meas_lookup_code,
               cur_po_line.line_location_id,
               cur_po_line.po_distribution_id,
               'RECEIVE',
               'VENDOR',
               cur_po_line.organization_code,
               'PO',
               rcv_headers_interface_s.currval,
               'Y',
               ln_org_id
          FROM dual;
         
      ln_parent_txn_id := rcv_transactions_interface_s.currval;  
         
      INSERT INTO rcv_transactions_interface
        (
         parent_interface_txn_id,
         interface_transaction_id,
         group_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         transaction_type,
         transaction_date,
         processing_status_code,
         processing_mode_code,
         transaction_status_code,
         po_header_id,
         po_line_id,
         item_id,
         quantity,
         unit_of_measure,
         po_line_location_id,
         po_distribution_id,
         auto_transact_code,
         receipt_source_code,
         to_organization_code,
         source_document_code,
         header_interface_id,
         validation_flag,
         org_id)
        SELECT ln_parent_txn_id,
               rcv_transactions_interface_s.nextval,
               rcv_interface_groups_s.currval,            
               sysdate,
               ln_user_id,
               sysdate,
               ln_user_id,
               0,
               'DELIVER',
               SYSDATE,
               'PENDING',
               'BATCH',
               'PENDING',
               ln_po_header_id,
               cur_po_line.po_line_id,
               cur_po_line.item_id,
               cur_po_line.quantity,
               cur_po_line.unit_meas_lookup_code,
               cur_po_line.line_location_id,
               cur_po_line.po_distribution_id,
               NULL,--'RECEIVE',
               'VENDOR',
               cur_po_line.organization_code,
               'PO',
               rcv_headers_interface_s.currval,
               'Y',
               ln_org_id
          FROM dual;         
      dbms_output.put_line('po line: ' || cur_po_line.line_num || ' shipment: ' || cur_po_line.shipment_num ||
                           ' has been inserted into roi.');
                           
                           update deliverysummary@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG
                           set status_flag = 'P'
                           where EXTERNALREFERENCENUMBER = lv_segment1;
    ELSE
      dbms_output.put_line('po line ' || cur_po_line.line_num || ' is either closed, cancelled, received.');
    END IF;
  END LOOP;

 
 dbms_output.put_line('*** ezroi complete - end ***');
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
      dbms_output.put_line ('GRN program completed successfully');
      fnd_file.put_line(fnd_file.log,'GRN program completed successfully');
    END IF;
END;
 END LOOP;
END;
/