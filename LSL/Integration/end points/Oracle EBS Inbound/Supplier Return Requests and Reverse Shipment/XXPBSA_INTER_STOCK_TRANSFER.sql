--GRNs from Outlets
CREATE OR REPLACE PROCEDURE XXPBSA_INTER_STOCK_TRANSFER(
    p_errbuf OUT VARCHAR2,
    p_retcode OUT VARCHAR2,
    v_rec_no IN VARCHAR2,
    v_org_id IN NUMBER )
AS
  CURSOR c_receive
  IS
    SELECT rcv.ORGANIZATION_ID ,
      rsl.ITEM_ID rcv_item,
      pol.iTEM_ID po_item,
      poh.ORG_ID,
      to_number(rcv.ATTRIBUTE1) rcv_qty,
      pol.QUANTITY,
      --pol.QUANTITY qty_diff,
      ret_req.quantity qty_diff,
      item.PRIMARY_UOM_CODE,
      rcv.TRANSACTION_DATE,
      rcv.SUBINVENTORY,
      rsh.RECEIPT_NUM,
      rsh.SHIPMENT_HEADER_ID,
      rcv.SHIPMENT_LINE_ID,
      NVL(rsl.ATTRIBUTE15,'.') update_status,
      rcv.TRANSACTION_TYPE,
      pol.PO_HEADER_ID,
      pol.PO_LINE_ID
      --    rsl.*
    FROM RCV_SHIPMENT_headers rsh,
      RCV_SHIPMENT_LINES rsl,
      rcv_transactions rcv,
      po_headers_all poh,
      po_lines_all pol,
      mtl_system_items_b item,
      (
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
              and rownum = 1
      ) ret_req
    WHERE rsh.SHIPMENT_HEADER_ID=rsl.SHIPMENT_HEADER_ID
    AND rsh.SHIPMENT_HEADER_ID  =rcv.SHIPMENT_HEADER_ID
    AND rsl.SHIPMENT_LINE_ID    =rcv.SHIPMENT_LINE_ID
    AND rcv.TRANSACTION_TYPE    ='DELIVER'
    AND rsh.RECEIPT_NUM         = 100007
    AND poh.PO_HEADER_ID        =pol.PO_HEADER_ID
    AND poh.ORG_ID              =pol.ORG_ID
    AND poh.PO_HEADER_ID        =rcv.PO_HEADER_ID
    AND pol.PO_LINE_ID          =rcv.PO_LINE_ID
    AND item.inventory_item_id  =rsl.ITEM_ID
    AND item.organization_id    = 102
    AND rcv.ORGANIZATION_ID    IN
      (SELECT ORGANIZATION_ID
      FROM mtl_system_items_b
      WHERE inventory_item_id= item.inventory_item_id
      )
    --and ret_req.vendor_id = poh.vendor_id(+)
    --and ret_req.vendor_site_id = poh.vendor_site_id(+)
    --and ret_req.inventory_item_id = pol.item_id(+)
    --and ret_req.PURCHASEORDERID = poh.INTERFACE_SOURCE_CODE(+)
    ;

    val NUMBER;
  
BEGIN
  val := mo_global.get_current_org_id; -- fnd_profile.value('ORG_ID');
  DBMS_OUTPUT.put_line ('AA '||val);
  DBMS_OUTPUT.put_line ('BB '||v_org_id);
  FOR crec_receive IN c_receive
  LOOP
    IF crec_receive.qty_diff>0 THEN
      BEGIN
        -- DBMS_OUTPUT.put_line ('Before Inserted MTL_TRANSACTIONS_INTERFACE');
        INSERT
        INTO apps.mtl_transactions_interface
          (
            source_code,
            source_line_id,
            source_header_id,
            process_flag,
            transaction_mode,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            inventory_item_id,
            organization_id,
            transaction_quantity,
            transaction_uom,
            transaction_date,
            subinventory_code,
            locator_id,
            transaction_type_id,
            LOCK_FLAG,
            distribution_account_id
            --transaction_cost,
            --transfer_lpn_id
          )
          VALUES
          (
            'Inventory',                   --source_code
            XXPBSA_SUP_RET_LINE_ID_SEQ.NEXTVAL,                             --OOMCO_SRC_LINE_ID_INT_SEQ.NEXTVAL,--source_line_id
            XXPBSA_SUP_RET_HEADER_ID_SEQ.NEXTVAL,                             --xxmtl_src_hdr_id_int_seq.NEXTVAL, --source_header_id
            1,                             --process_flag
            3,                             --transaction_mode
            SYSDATE,                       --last_update_date
            fnd_global.user_id,            --last_updated_by
            SYSDATE,                       --creation_date
            fnd_global.user_id,            --created_by
            crec_receive.rcv_item,         --l_inventory_item_id, --inventory_item_id
            crec_receive.ORGANIZATION_ID,  --organization_id
            crec_receive.qty_diff,         --i_onhand_qty.quantity, --transaction_quantity
            crec_receive.PRIMARY_UOM_CODE, --i_onhand_qty.transaction_uom,--transaction_uom
            crec_receive.TRANSACTION_DATE, --i_onhand_qty.transaction_date,--transaction_date
            crec_receive.SUBINVENTORY,     --i_onhand_qty.subinventory_code,--subinventory_code
            NULL,                          --locator_id
            18,
            /*18PO Receipt*/
            /*32 Miscellaneous issue*/
            --transaction_type_id
            2,   --LOCK_FLAG
            2008 -- null,--l_code_combination_id --distribution_account_id
            --i_onhand_qty.unit_cost, --CRecOnhand.TRANSACTION_COST--
            --NULL --
          );
        --FND_FILE.PUT_LINE(FND_FILE.LOG,'After Inserted MTL_TRANSACTIONS_INTERFACE');
        DBMS_OUTPUT.put_line ('After Inserted MTL_TRANSACTIONS_INTERFACE');
        BEGIN
          UPDATE RCV_SHIPMENT_LINES
          SET ATTRIBUTE15         ='On Hand Updated'
          WHERE SHIPMENT_HEADER_ID=crec_receive.SHIPMENT_HEADER_ID
          AND SHIPMENT_LINE_ID    =crec_receive.SHIPMENT_LINE_ID
          AND item_id             =crec_receive.rcv_item;
        END;
        COMMIT;
      EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line ('Error '||SQLERRM);
      END;
    ELSE
      BEGIN
        -- DBMS_OUTPUT.put_line ('Before Inserted MTL_TRANSACTIONS_INTERFACE');
        INSERT
        INTO mtl_transactions_interface
          (
            source_code,
            source_line_id,
            source_header_id,
            process_flag,
            transaction_mode,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            inventory_item_id,
            organization_id,
            transaction_quantity,
            transaction_uom,
            transaction_date,
            subinventory_code,
            locator_id,
            transaction_type_id,
            LOCK_FLAG,
            distribution_account_id
            --transaction_cost,
            --transfer_lpn_id
          )
          VALUES
          (
            'Inventory',                   --source_code
            XXPBSA_SUP_RET_LINE_ID_SEQ.NEXTVAL,                             --XXPBSA_SUP_RET_LINE_ID_SEQ.NEXTVAL,--source_line_id
            XXPBSA_SUP_RET_HEADER_ID_SEQ.NEXTVAL,                             --XXPBSA_SUP_RET_HEADER_ID_SEQ.NEXTVAL, --source_header_id
            1,                             --process_flag
            3,                             --transaction_mode
            SYSDATE,                       --last_update_date
            fnd_global.user_id,            --last_updated_by
            SYSDATE,                       --creation_date
            fnd_global.user_id,            --created_by
            crec_receive.rcv_item,         --l_inventory_item_id, --inventory_item_id
            crec_receive.ORGANIZATION_ID,  --organization_id
            crec_receive.qty_diff,         --i_onhand_qty.quantity, --transaction_quantity
            crec_receive.PRIMARY_UOM_CODE, --i_onhand_qty.transaction_uom,--transaction_uom
            crec_receive.TRANSACTION_DATE, --i_onhand_qty.transaction_date,--transaction_date
            crec_receive.SUBINVENTORY,     --i_onhand_qty.subinventory_code,--subinventory_code
            NULL,                          --locator_id
            32,
            /*18PO Receipt*/
            /*32 Miscellaneous issue*/
            --transaction_type_id
            2,   --LOCK_FLAG
            2008 -- null,--l_code_combination_id --distribution_account_id
            --i_onhand_qty.unit_cost, --CRecOnhand.TRANSACTION_COST--
            --NULL --
          );
        --FND_FILE.PUT_LINE(FND_FILE.LOG,'After Inserted MTL_TRANSACTIONS_INTERFACE');
        BEGIN
          UPDATE RCV_SHIPMENT_LINES
          SET ATTRIBUTE15         ='On Hand Updated'
          WHERE SHIPMENT_HEADER_ID=crec_receive.SHIPMENT_HEADER_ID
          AND SHIPMENT_LINE_ID    =crec_receive.SHIPMENT_LINE_ID
          AND item_id             =crec_receive.rcv_item;
        END;
        DBMS_OUTPUT.put_line ('After Inserted MTL_TRANSACTIONS_INTERFACE');
        COMMIT;
      EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line ('Error '||SQLERRM);
      END;
    END IF;
  END LOOP;
END XXPBSA_SUPPLIER_RET_PRC;
/
declare
    p_errbuf  VARCHAR2(100);
    p_retcode VARCHAR2(1000);
    v_rec_no  VARCHAR2(500);
    v_org_id  NUMBER;

begin
XXPBSA_SUPPLIER_RET_PRC(
               p_errbuf,
               p_retcode,
               null,
               null
      );
end;
/
