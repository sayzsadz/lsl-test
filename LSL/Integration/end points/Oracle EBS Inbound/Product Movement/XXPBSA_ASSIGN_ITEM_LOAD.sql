*********************************************************************************************
* Procedure : item_load
* Description: This procedure will be the Import of Items either Update or Insert for the validated  
*              data loaded into the Item Staging Table.
*********************************************************************************************/
PROCEDURE item_load(p_item_number IN  VARCHAR2,
                    p_org_id      IN  NUMBER,
                    p_batch_id    IN  NUMBER,
                    x_ret_status  OUT VARCHAR2) IS
           
  — local variables
  l_proc_name    CONSTANT VARCHAR2(50) := ‘item_load’;
  l_process_code          VARCHAR2(3);
  l_msg                   VARCHAR2(4000);
  l_item_tt               ego_item_pub.item_tbl_type;
  x_items_tt              ego_item_pub.item_tbl_type;
  x_inventory_item_id     mtl_system_items_b.inventory_item_id%TYPE;
  x_organization_id       mtl_system_items_b.organization_id%TYPE;
  x_return_status         VARCHAR2(1);
  x_msg_count             NUMBER;
  x_msg_data              error_handler.error_tbl_type;
  x_msg                   VARCHAR2(4000);
  
  — cursor declarations
  CURSOR get_stg_item(c_item VARCHAR2,
                                       c_batch_id NUMBER) IS
  SELECT *
     FROM xxabc_item_load_v cmis
   WHERE cmis.batch_id = c_batch_id
        AND cmis.segment1 = c_item
        AND cmis.process_code = ‘V’;
  
  CURSOR get_hier_orgs(c_hier_name VARCHAR2) IS
  SELECT pose.organization_id_child
    FROM per_organization_structures pos,
               per_org_structure_elements pose,
               mtl_parameters p
   WHERE pos.organization_structure_id = pose.org_structure_version_id
        AND pose.organization_id_child = p.organization_id
        AND p.organization_id != p.master_organization_id
        AND pos.name = c_hier_name; 
      
BEGIN
      –Setting FND global variables.
    fnd_global.apps_initialize (user_id      => fnd_global.user_id, — Thomas Chandler
                                resp_id      => 20634,  — Inventory
                                resp_appl_id => 401); — INV
                             
   FOR cr_itm IN get_stg_item(p_item_number, p_batch_id) LOOP
     — Set local PC to current value
     l_process_code := cr_itm.process_code;
       
      — Running style Create or Update only.                          
      IF cr_itm.action_code = ‘I’ THEN 
        l_item_tt(1).transaction_type  := ‘CREATE’;   — Replace this with ‘UPDATE’ for update transaction.
      ELSE — ‘U’ update
        l_item_tt(1).transaction_type  := ‘UPDATE’;
      END IF;  
        l_item_tt(1).segment1                   := p_item_number;
        l_item_tt(1).organization_id            := p_org_id;
        l_item_tt(1).description                := cr_itm.description;
        l_item_tt(1).long_description           := cr_itm.long_description;
        l_item_tt(1).primary_uom_code           := cr_itm.primary_uom_code;
        l_item_tt(1).inventory_item_status_code := cr_itm.inventory_item_status_code;
        l_item_tt(1).template_name              := cr_itm.template_name;
        — General Planning Tab
        l_item_tt(1).min_minmax_quantity        := cr_itm.min_minmax_quantity;
        l_item_tt(1).max_minmax_quantity        := cr_itm.max_minmax_quantity;
        l_item_tt(1).minimum_order_quantity     := cr_itm.minimum_order_quantity;
        l_item_tt(1).maximum_order_quantity     := cr_itm.maximum_order_quantity;
        l_item_tt(1).fixed_lot_multiplier       := cr_itm.fixed_lot_multiplier;
        l_item_tt(1).source_type                := cr_itm.source_type;
        l_item_tt(1).source_organization_id     := get_org_id(cr_itm.source_organization_code);
        l_item_tt(1).source_subinventory        := cr_itm.source_subinventory;
        — Lead Times Tab
        l_item_tt(1).full_lead_time             := cr_itm.full_lead_time;
        — physical attributes tab
        l_item_tt(1).weight_uom_code            := cr_itm.weight_uom_code;
        l_item_tt(1).unit_weight                := cr_itm.unit_weight;
        l_item_tt(1).volume_uom_code            := cr_itm.volume_uom_code;
        l_item_tt(1).unit_volume                := cr_itm.unit_volume;
        l_item_tt(1).dimension_uom_code         := cr_itm.dimension_uom_code;
        l_item_tt(1).unit_length                := cr_itm.unit_length;
        l_item_tt(1).unit_width                 := cr_itm.unit_width;
        l_item_tt(1).unit_height                := cr_itm.unit_height;
        — purchasing tab
        l_item_tt(1).buyer_id                   := get_buyer_id(cr_itm.buyer_name);
        l_item_tt(1).list_price_per_unit        := cr_itm.list_price_per_unit;
        l_item_tt(1).expense_account            := get_gl_ccid(cr_itm.expense_account);
        l_item_tt(1).hazard_class_id            := get_hzrd_class_id(cr_itm.hazard_class);
        — Order Management Tab
        l_item_tt(1).sales_account              := get_gl_ccid(cr_itm.sales_account);
        — Costing Tab
        l_item_tt(1).cost_of_sales_account      := get_gl_ccid(cr_itm.cost_of_sales_account);
        — attributes
        l_item_tt(1).attribute1                 := cr_itm.attribute1;
        l_item_tt(1).attribute2                 := cr_itm.map_price;  
        l_item_tt(1).attribute3                 := cr_itm.attribute3;
        l_item_tt(1).attribute4                 := cr_itm.attribute4;
        l_item_tt(1).attribute5                 := cr_itm.attribute5;
        l_item_tt(1).attribute6                 := cr_itm.attribute6;
        l_item_tt(1).attribute7                 := cr_itm.attribute7;
        l_item_tt(1).attribute8                 := cr_itm.attribute8;
        l_item_tt(1).attribute13                := cr_itm.attribute13;
        l_item_tt(1).attribute14                := cr_itm.attribute14;
        
        ego_item_pub.process_items (p_api_version        => 1.0,
                                    p_init_msg_list      => fnd_api.g_true,
                                    p_commit             => fnd_api.g_true,
                                    p_item_tbl           => l_item_tt,
                                                                      x_item_tbl           => x_items_tt,
  x_return_status      => x_return_status,
                                    x_msg_count          => x_msg_count);
        
        IF (x_return_status = fnd_api.g_ret_sts_success) THEN
          x_ret_status := x_return_status;
           l_process_code := ‘I’; 
          FOR i IN 1 .. x_items_tt.COUNT LOOP
              dbms_output.put_line (‘Inventory Item Id :’ || x_items_tt(i).inventory_item_id);
              x_inventory_item_id :=  x_items_tt(i).inventory_item_id;
              dbms_output.put_line (‘  Organization Id :’ || x_items_tt(i).organization_id);
              x_organization_id := x_items_tt(i).organization_id;
          END LOOP;
        
           — Call the Organization Assignments depending on Insert or Update.
           IF cr_itm.action_code = ‘I’ THEN 
                             
               IF cr_itm.all_orgs_flag = ‘Y’ THEN
                 — Loop through all the orgs in the hierarchy and assign.
                 FOR cr_orgs IN get_hier_orgs(cr_itm.organization_hierarchy) LOOP
                   
                   assign_orgs(x_inventory_item_id, 
                               cr_orgs.organization_id_child,
                               cr_itm.primary_uom_code,
                               x_return_status,
                               x_msg);
                          
                       COMMIT;
                 END LOOP; 
               ELSE 
                 — Call the org assignment for the one org.
                 assign_orgs(x_inventory_item_id,
                             get_org_id(cr_itm.organization_code),
                             cr_itm.primary_uom_code,
                             x_return_status,
                             x_msg);
                       COMMIT;  
               END IF;
               
               
               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 l_process_code := ‘IE’;
                 — append message
                 IF x_msg IS NOT NULL THEN
                   l_msg := x_msg||’; ‘||l_msg;
                 END IF;
               END IF;
    
           END IF;

        ELSE — ITEM MASTER FAILED Process out the messages
          l_process_code := ‘IE’;
          error_handler.get_message_list (x_message_list => x_msg_data);
     
          FOR i IN 1 .. x_msg_data.COUNT LOOP
              l_msg := l_msg ||’; ‘|| x_msg_data(i).message_text;
          END LOOP;
        END IF;
     
     — Call the update to the process code and messages
     updt_process_code(p_item_number, p_batch_id, l_process_code, l_msg);
     
   END LOOP; — Main Item loop
EXCEPTION
  WHEN OTHERS THEN 
    xxtdc_msg_handler.msg(g_pkg_name||’.’||l_proc_name||’: Others Error in Item Load: ‘||SQLERRM, g_msg_lvl, 8);
END;

/*********************************************************************************************
* Procedure : assign_orgs
* Description: This procedure will be called from the item_load if the load is in Insert Mode 
*              and if all_Orgs_flag = ‘Y’.
*********************************************************************************************/
PROCEDURE assign_orgs(p_item_id     IN  NUMBER,
                      p_org_id      IN  NUMBER,
                      p_primary_uom IN  VARCHAR2,
                      x_status      OUT VARCHAR2,
                      x_msg         OUT VARCHAR2) IS 
            PRAGMA AUTONOMOUS_TRANSACTION;
    — local variables
  l_proc_name    CONSTANT VARCHAR2(50) := ‘assign_orgs’;  
  x_msg_count             NUMBER;
  x_msg_data          Error_Handler.Error_Tbl_Type;
  
BEGIN 
    — call API to assign Items 
DBMS_OUTPUT.PUT_LINE(‘===========================================’); 
DBMS_OUTPUT.PUT_LINE(‘Calling EGO_ITEM_PUB.Assign_Item_To_Org API’);                      
      DBMS_OUTPUT.put_line (‘Organization Id   : ‘ ||p_org_id);
      DBMS_OUTPUT.put_line (‘Inventory Item Id : ‘ ||p_item_id);
     EGO_ITEM_PUB.ASSIGN_ITEM_TO_ORG(p_api_version       => 1.0,
                                     p_init_msg_list     => fnd_api.g_true,
                                     p_commit            => fnd_api.g_true,
                                     p_inventory_item_id => p_item_id,
                                     p_item_number       => null,
                                     p_organization_id   => p_org_id,
                                     p_organization_code => NULL,
                                     p_primary_uom_code  => p_primary_uom,
                                     x_return_status     => x_status,
                                     x_msg_count         => x_msg_count);
                                         
DBMS_OUTPUT.PUT_LINE(‘Return Status: ‘||x_status);
  IF (x_status <> FND_API.G_RET_STS_SUCCESS) THEN  
     — Set the process code and error messages to the table.
     DBMS_OUTPUT.PUT_LINE(‘Error Messages :’); 
     Error_Handler.GET_MESSAGE_LIST(x_message_list => x_msg_data); 
     
     FOR i IN 1..x_msg_data.COUNT LOOP  
       DBMS_OUTPUT.PUT_LINE(x_msg_data(i).message_text);
       IF x_msg IS NULL THEN
         x_msg := x_msg_data(i).message_text;
       ELSE
         x_msg := x_msg ||’; ‘|| x_msg_data(i).message_text;
       END IF;
     END LOOP; 
     
  END IF;
  DBMS_OUTPUT.PUT_LINE(‘=========================================’);                                    
     COMMIT;                                                  
EXCEPTION
  WHEN OTHERS THEN 
    xxtdc_msg_handler.msg(g_pkg_name||’.’||l_proc_name||’: status: ‘|| x_status||’ Count: ‘||x_msg_count, g_msg_lvl, 8);
    xxtdc_msg_handler.msg(g_pkg_name||’.’||l_proc_name||’: Others Error in Org Assignment: ‘||SQLERRM, g_msg_lvl, 8);
END;     