create or replace PROCEDURE XXPBSA_RETURN_VENDOR_PRC (p_receipt_num in varchar2, p_po_number in varchar2)
as
        v_request_id NUMBER;
        cursor cur 
        is
        SELECT  rsh.receipt_num ,
                    ph.segment1 po_number,
                    rt.transaction_id ,
                    rt.transaction_type ,
                    rt.transaction_date ,
                    rt.quantity ,
                    rt.unit_of_measure ,
                    rt.shipment_header_id ,
                    rt.shipment_line_id ,
                    rt.source_document_code ,
                    rt.destination_type_code ,
                    rt.employee_id ,
                    rt.parent_transaction_id ,
                    rt.po_header_id ,
                    rt.po_line_id ,
                    pl.line_num ,
                    pl.item_id ,
                    pl.unit_price ,
                    rt.po_line_location_id ,
                    rt.po_distribution_id ,
                    rt.routing_header_id,
                    rt.routing_step_id ,
                    rt.deliver_to_person_id ,
                    rt.deliver_to_location_id ,
                    rt.vendor_id ,
                    rt.vendor_site_id ,
                    rt.organization_id ,
                    rt.subinventory ,
                    rt.locator_id ,
                    rt.location_id,
                    rsh.ship_to_org_id
            FROM apps.rcv_transactions rt,
              apps.rcv_shipment_headers rsh,
              apps.po_headers_all ph,
              apps.po_lines_all pl
            WHERE 1 = 1
            --AND rsh.receipt_num     = p_receipt_num
            --AND ph.segment1           = p_po_number
            AND ph.po_header_id       = pl.po_header_id
            AND rt.po_header_id       = ph.po_header_id
            AND rt.shipment_header_id = rsh.shipment_header_id
            AND rt.po_line_id         =pl.po_line_id
            AND rt.destination_type_code='INVENTORY'
            --AND rt.transaction_type='DELIVER'
            AND rt.TRANSACTION_TYPE = 'RETURN TO RECEIVING';
begin
for cur_rec in cur
loop
  INSERT INTO apps.rcv_transactions_interface
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
                                 quantity,
                                 unit_of_measure,
                                 item_id,
                                 employee_id,
                                 shipment_header_id,
                                 shipment_line_id,
                                 receipt_source_code,
                                 vendor_id,
                                 from_organization_id,
                                 from_subinventory,
                                 from_locator_id,
                                 source_document_code,
                                 parent_transaction_id,
                                 po_header_id,
                                 po_line_id,
                                 po_line_location_id,
                                 po_distribution_id,
                                 destination_type_code,
                                 deliver_to_person_id,
                                 location_id,
                                 deliver_to_location_id,
                                 validation_flag
                                )
                                values
                                (apps.rcv_transactions_interface_s.nextval,     --INTERFACE_TRANSACTION_ID
                                 apps.rcv_interface_groups_s.nextval,              --GROUP_ID
                                 sysdate,                                                                  --LAST_UPDATE_DATE
                                 0,                                                                        --LAST_UPDATE_BY
                                 sysdate,                                                                  --CREATION_DATE
                                 0,                                                                        --CREATED_BY
                                 0,                                                                              --LAST_UPDATE_LOGIN
                                 'RETURN TO VENDOR',                                    --TRANSACTION_TYPE
                                 sysdate,                                                                  --TRANSACTION_DATE
                                 'PENDING',                                                             --PROCESSING_STATUS_CODE
                                 'BATCH',                                                                --PROCESSING_MODE_CODE
                                 'PENDING',                                                             --TRANSACTION_STATUS_CODE
                                 cur_rec.QUANTITY,                                                                            --QUANTITY
                                 cur_rec.UNIT_OF_MEASURE,                                                      --UNIT_OF_MEASURE
                                 cur_rec.ITEM_ID,                                                                    --ITEM_ID
                                 cur_rec.EMPLOYEE_ID,                                                                            --EMPLOYEE_ID
                                 cur_rec.SHIPMENT_HEADER_ID,                                                                 --SHIPMENT_HEADER_ID
                                 cur_rec.SHIPMENT_LINE_ID,                                                                 --SHIPMENT_LINE_ID
                                 'VENDOR',                                                             --RECEIPT_SOURCE_CODE
                                 cur_rec.VENDOR_ID,                                                                          --VENDOR_ID
                                 cur_rec.ORGANIZATION_ID,                                                                         --FROM_ORGANIZATION_ID
                                 cur_rec.SUBINVENTORY,                                                                    --FROM_SUBINVENTORY
                                 null,                                                                        --FROM_LOCATOR_ID
                                 'PO',                                                                        --SOURCE_DOCUMENT_CODE
                                 cur_rec.PARENT_TRANSACTION_ID,                                                                 --PARENT_TRANSACTION_ID
                                 cur_rec.PO_HEADER_ID,                                                                   --PO_HEADER_ID
                                 cur_rec.PO_LINE_ID,                                                                   --PO_LINE_ID
                                 cur_rec.PO_LINE_LOCATION_ID,                                                                    --PO_LINE_LOCATION_ID
                                 cur_rec.PO_DISTRIBUTION_ID,                                                                   --PO_DISTRIBUTION_ID
                                 'RECEIVING',                                                        --DESTINATION_TYPE_CODE
                                 null,                                                                        --DELIVER_TO_PERSON_ID
                                 null,                                                                       --LOCATION_ID
                                 null,                                                                       --DELIVER_TO_LOCATION_ID
                                 'Y'                                                                           --Validation_flag
                                ); 
commit;
end loop;
        
        BEGIN
        apps.mo_global.init ('PO');
        apps.mo_global.set_policy_context ('S',204);
        apps.fnd_global.apps_initialize ( user_id => 1318, resp_id => 20707, resp_appl_id => 201 );
        --------CALLING STANDARD RECEIVING TRANSACTION PROCESSOR ---------------------------------
        
          v_request_id   := apps.fnd_request.submit_request ( application => 'PO', 
                                                              PROGRAM => 'RVCTP', 
                                                              argument1 => 'BATCH', 
                                                              argument2 => apps.rcv_interface_groups_s.currval, 
                                                              argument3 => 204);
                                                              commit;
        dbms_output.put_line('Request Id'||v_request_id);                                                 
        END;
END;