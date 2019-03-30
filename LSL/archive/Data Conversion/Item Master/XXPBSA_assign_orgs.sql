create or replace PROCEDURE XXPBSA_assign_orgs(p_item_id     IN  NUMBER,
                      p_org_id      IN  NUMBER,
                      p_primary_uom IN  VARCHAR2,
                      x_status      OUT VARCHAR2,
                      x_msg         OUT VARCHAR2) IS 
            PRAGMA AUTONOMOUS_TRANSACTION;
    -- local variables
  l_proc_name    CONSTANT VARCHAR2(50) := 'assign_orgs';  
  x_msg_count             NUMBER;
  x_msg_data          Error_Handler.Error_Tbl_Type;
  
  
  
BEGIN 
    -- call API to assign Items 
DBMS_OUTPUT.PUT_LINE('==========================================='); 
DBMS_OUTPUT.PUT_LINE('Calling EGO_ITEM_PUB.Assign_Item_To_Org API');                      
      DBMS_OUTPUT.put_line ('Organization Id   : ' ||p_org_id);
      DBMS_OUTPUT.put_line ('Inventory Item Id : ' ||p_item_id);
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
                                         
DBMS_OUTPUT.PUT_LINE('Return Status: '||x_status);
  IF (x_status <> FND_API.G_RET_STS_SUCCESS) THEN  
     -- Set the process code and error messages to the table.
     DBMS_OUTPUT.PUT_LINE('Error Messages :'); 
     Error_Handler.GET_MESSAGE_LIST(x_message_list => x_msg_data); 
     
     FOR i IN 1..x_msg_data.COUNT LOOP  
       DBMS_OUTPUT.PUT_LINE(x_msg_data(i).message_text);
       IF x_msg IS NULL THEN
         x_msg := x_msg_data(i).message_text;
       ELSE
         x_msg := x_msg ||'; '|| x_msg_data(i).message_text;
       END IF;
     END LOOP; 
     
  END IF;
  DBMS_OUTPUT.PUT_LINE('=========================================');                                    
     COMMIT;                                                  
EXCEPTION
  WHEN OTHERS THEN 
   DBMS_OUTPUT.PUT_LINE(SQLERRM);   
END;
/