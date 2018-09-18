CREATE OR REPLACE PROCEDURE XXPBSA_SUPPLIER_RET_PRC(
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
      pol.QUANTITY qty_diff,
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
      mtl_system_items_b item
    WHERE rsh.SHIPMENT_HEADER_ID=rsl.SHIPMENT_HEADER_ID
    AND rsh.SHIPMENT_HEADER_ID  =rcv.SHIPMENT_HEADER_ID
    AND rsl.SHIPMENT_LINE_ID    =rcv.SHIPMENT_LINE_ID
    AND rcv.TRANSACTION_TYPE    ='DELIVER'
    AND rsh.RECEIPT_NUM         = 100003
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
        /*Only for this item attached orgs*/
      );
--  AND item.inventory_item_id=33113
--    /*Only for this item*/
--    --and     poh.org_id in ( )
--  AND to_number(rcv.ATTRIBUTE1)<>pol.QUANTITY
--  AND NVL(rsl.ATTRIBUTE15,'.') <>'On Hand Updated'

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
            1,                             --OOMCO_SRC_LINE_ID_INT_SEQ.NEXTVAL,--source_line_id
            1,                             --xxmtl_src_hdr_id_int_seq.NEXTVAL, --source_header_id
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
            1008 -- null,--l_code_combination_id --distribution_account_id
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
            1008 -- null,--l_code_combination_id --distribution_account_id
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