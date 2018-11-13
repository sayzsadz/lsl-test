create or replace PROCEDURE XXPBSA_item_load(p_item_number IN  VARCHAR2,
                    p_org_id      IN  NUMBER,
                    p_batch_id    IN  NUMBER,
                    x_ret_status  OUT VARCHAR2) IS
           
  -- local variables
  l_proc_name    CONSTANT VARCHAR2(50) := 'item_load';
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
  
  -- cursor declarations
  CURSOR get_stg_item(c_item VARCHAR2,
                                       c_batch_id NUMBER) IS
  SELECT *
     FROM xxpbsa_item_load_v cmis
   WHERE cmis.batch_id = 2
        AND cmis.segment1 = 'TEST_ITEM_PBSA2'
        AND cmis.process_code = 'V';
  
  CURSOR get_hier_orgs IS
  SELECT p.organization_id
  FROM mtl_parameters p
  WHERE 1 = 1
        and p.organization_id != p_org_id; 
      
BEGIN


    --Setting FND global variables.
    fnd_global.apps_initialize (user_id      => 0, -- Thomas Chandler
                                resp_id      => 20634,  -- Inventory
                                resp_appl_id => 401); -- INV
                             
   FOR cr_itm IN get_stg_item('TEST_ITEM_PBSA2', 12) LOOP
     -- Set local PC to current value
     l_process_code := cr_itm.process_code;
       
      -- Running style Create or Update only.                          
      IF cr_itm.action_code = 'I' THEN 
        l_item_tt(1).transaction_type  := 'CREATE';   -- Replace this with 'UPDATE' for update transaction.
      ELSE -- 'U' update
        l_item_tt(1).transaction_type  := 'UPDATE';
      END IF;  
        l_item_tt(1).segment1                   := p_item_number;
        l_item_tt(1).organization_id            := p_org_id;
        l_item_tt(1).description                := cr_itm.description;
        l_item_tt(1).long_description           := cr_itm.long_description;
        l_item_tt(1).primary_uom_code           := cr_itm.primary_uom_code;
        l_item_tt(1).inventory_item_status_code := cr_itm.inventory_item_status_code;
        l_item_tt(1).template_name              := cr_itm.template_name;
        -- General Planning Tab
        l_item_tt(1).min_minmax_quantity        := cr_itm.min_minmax_quantity;
        l_item_tt(1).max_minmax_quantity        := cr_itm.max_minmax_quantity;
        l_item_tt(1).minimum_order_quantity     := cr_itm.minimum_order_quantity;
        l_item_tt(1).maximum_order_quantity     := cr_itm.maximum_order_quantity;
        l_item_tt(1).fixed_lot_multiplier       := cr_itm.fixed_lot_multiplier;
        l_item_tt(1).source_type                := cr_itm.source_type;
        l_item_tt(1).source_organization_id     := cr_itm.source_organization_code;
        l_item_tt(1).source_subinventory        := cr_itm.source_subinventory;
        -- Lead Times Tab
        l_item_tt(1).full_lead_time             := cr_itm.full_lead_time;
        -- physical attributes tab
        l_item_tt(1).weight_uom_code            := cr_itm.weight_uom_code;
        l_item_tt(1).unit_weight                := cr_itm.unit_weight;
        l_item_tt(1).volume_uom_code            := cr_itm.volume_uom_code;
        l_item_tt(1).unit_volume                := cr_itm.unit_volume;
        l_item_tt(1).dimension_uom_code         := cr_itm.dimension_uom_code;
        l_item_tt(1).unit_length                := cr_itm.unit_length;
        l_item_tt(1).unit_width                 := cr_itm.unit_width;
        l_item_tt(1).unit_height                := cr_itm.unit_height;
        -- purchasing tab
        l_item_tt(1).buyer_id                   := cr_itm.buyer_name;
        l_item_tt(1).list_price_per_unit        := cr_itm.list_price_per_unit;
        l_item_tt(1).expense_account            := cr_itm.expense_account;
        --l_item_tt(1).hazard_class               := cr_itm.hazard_class;
        -- Order Management Tab
        l_item_tt(1).sales_account              := cr_itm.sales_account;
        -- Costing Tab
        l_item_tt(1).cost_of_sales_account      := cr_itm.cost_of_sales_account;
        -- attributes
        l_item_tt(1).attribute10                := cr_itm.attribute10;
        
        ego_item_pub.process_items (p_api_version        => 1.0,
                                    p_init_msg_list      => fnd_api.g_true,
                                    p_commit             => fnd_api.g_true,
                                    p_item_tbl           => l_item_tt,
                                                                      x_item_tbl           => x_items_tt,
  x_return_status      => x_return_status,
                                    x_msg_count          => x_msg_count);
        
        IF (x_return_status = fnd_api.g_ret_sts_success) THEN
          x_ret_status := x_return_status;
           l_process_code := 'I'; 
          FOR i IN 1 .. x_items_tt.COUNT LOOP
              dbms_output.put_line ('Inventory Item Id :' || x_items_tt(i).inventory_item_id);
              x_inventory_item_id :=  x_items_tt(i).inventory_item_id;
              dbms_output.put_line ('  Organization Id :' || x_items_tt(i).organization_id);
              x_organization_id := x_items_tt(i).organization_id;
          END LOOP;
        
           -- Call the Organization Assignments depending on Insert or Update.
           IF cr_itm.action_code = 'I' THEN 
                             
               IF cr_itm.all_orgs_flag = 'Y' THEN
                 -- Loop through all the orgs in the hierarchy and assign.
                 FOR cr_orgs IN get_hier_orgs LOOP
                   
                   XXPBSA_ASSIGN_ORGS(x_inventory_item_id, 
                               cr_orgs.organization_id,
                               cr_itm.primary_uom_code,
                               x_return_status,
                               x_msg);
                          
                       COMMIT;
                 END LOOP; 
               ELSE 
                 -- Call the org assignment for the one org.
                 XXPBSA_ASSIGN_ORGS(x_inventory_item_id,
                             101,
                             cr_itm.primary_uom_code,
                             x_return_status,
                             x_msg);
                       COMMIT;  
               END IF;
               
               
               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 l_process_code := 'IE';
                 -- append message
                 IF x_msg IS NOT NULL THEN
                   l_msg := x_msg||'; '||l_msg;
                 END IF;
               END IF;
    
           END IF;

        ELSE -- ITEM MASTER FAILED Process out the messages
          l_process_code := 'IE';
          error_handler.get_message_list (x_message_list => x_msg_data);
     
          FOR i IN 1 .. x_msg_data.COUNT LOOP
              l_msg := l_msg ||'; '|| x_msg_data(i).message_text;
          END LOOP;
        END IF;
     
     -- Call the update to the process code and messages
     update xxpbsa_item_load_v
     set PROCESS_CODE = 'P'
     where segment1 = p_item_number
           and batch_id = p_batch_id;
     
   END LOOP; -- Main Item loop
EXCEPTION
  WHEN OTHERS THEN 
    dbms_output.put_line(SQLERRM);
END;
/

update xxpbsa_item_load_v
set PROCESS_CODE = 'V'
    ,SEGMENT1 = 'TEST_ITEM_PBSA2'
    ,batch_id = 2;

select *
from xxpbsa_item_load_v;

select *
from mtl_system_items_b;

set serveroutput on
declare
p_ret_status  varchar2(100);
begin
XXPBSA_item_load(
                 p_item_number => 'TEST_ITEM_PBSA2',
                 p_org_id      => 102,
                 p_batch_id    => 2,
                 x_ret_status  => p_ret_status
                 );
DBMS_OUTPUT.PUT_LINE(SQLERRM||'-'||p_ret_status);                                                     
end;