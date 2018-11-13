create or replace PROCEDURE  XXPBSA_PROCESS_ITEMS(
         p_Transaction_Type     varchar2,
         p_Segment1             varchar2,
         p_Description          varchar2,
         p_Organization_Code    varchar2,
         p_template_name        varchar2,
         p_attribute10          varchar2
)
AS
        x_item_tbl		     EGO_ITEM_PUB.ITEM_TBL_TYPE;     
        x_message_list     Error_Handler.Error_Tbl_Type;
        x_return_status		 VARCHAR2(2);
        x_msg_count		     NUMBER := 0;
    
        l_user_id		      NUMBER := -1;
        l_resp_id		      NUMBER := -1;
        l_application_id	NUMBER := -1;
        
        l_rowcnt		      NUMBER := 1;
        l_api_version		   NUMBER := 1.0; 
        l_init_msg_list		 VARCHAR2(2) := FND_API.G_TRUE; 
        l_commit	      	 VARCHAR2(2) := FND_API.G_FALSE; 
        l_item_tbl		     EGO_ITEM_PUB.ITEM_TBL_TYPE; 
        l_role_grant_tbl	 EGO_ITEM_PUB.ROLE_GRANT_TBL_TYPE; 
        l_user_name		VARCHAR2(30) := 'SJAYASINGHE1';
        l_resp_name		VARCHAR2(30) := 'Inventory';    
        
        l_item_catalog_group_id NUMBER := 0;

  x_msg_data              Error_Handler.Error_Tbl_Type;
  x_status                varchar2(2);
  x_msg                   varchar2(20000);
       
BEGIN

          -- Get the user_id
          SELECT user_id
          INTO l_user_id
          FROM fnd_user
          WHERE user_name = l_user_name;
        
          -- Get the application_id and responsibility_id
          SELECT application_id, responsibility_id
          INTO l_application_id, l_resp_id
          FROM fnd_responsibility_vl
          WHERE responsibility_name = l_resp_name;
        
          FND_GLOBAL.APPS_INITIALIZE(l_user_id, l_resp_id, l_application_id);  
          dbms_output.put_line('Initialized applications context: '|| l_user_id || ' '|| l_resp_id ||' '|| l_application_id );

          -- Load the item catalog group id
--          SELECT item_catalog_group_id 
--          INTO l_item_catalog_group_id
--          FROM mtl_item_catalog_groups_b 
--          WHERE segment1 = 'SU_CATALOG';  -- Item Catalog Category Name
          
        -- Load l_item_tbl with the data
         l_item_tbl(l_rowcnt).Transaction_Type            := p_Transaction_Type; 
         l_item_tbl(l_rowcnt).Segment1                    := p_Segment1;            -- Item Number
         l_item_tbl(l_rowcnt).Description                 := p_Description;            -- Item Description
         l_item_tbl(l_rowcnt).Organization_Code           := p_Organization_Code;                     -- Organization Code
 --        l_item_tbl(l_rowcnt).Template_Name               := 'Finished Good';          -- Item template  (** should be associated to ICC, Not mandatory) 
         l_item_tbl(l_rowcnt).Inventory_Item_Status_Code  := 'Active';                 -- Item Status
         l_item_tbl(l_rowcnt).template_name               := p_template_name;  -- Item Catalog Group ID
         l_item_tbl(l_rowcnt).attribute10                 := p_attribute10;


          -- call API to load Items
         DBMS_OUTPUT.PUT_LINE('=====================================');
         DBMS_OUTPUT.PUT_LINE('Calling EGO_ITEM_PUB.Process_Items API');        
         EGO_ITEM_PUB.PROCESS_ITEMS( 
                                    p_api_version           => l_api_version
                                   ,p_init_msg_list         => l_init_msg_list
                                   ,p_commit                => l_commit
                                   ,p_item_tbl              => l_item_tbl
                                   ,p_role_grant_tbl        => l_role_grant_tbl
                                   ,x_item_tbl              => x_item_tbl
                                   ,x_return_status         => x_return_status
                                   ,x_msg_count             => x_msg_count);
                                    
         DBMS_OUTPUT.PUT_LINE('=====================================');
         DBMS_OUTPUT.PUT_LINE('Return Status: '||x_return_status);

       IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          FOR i IN 1..x_item_tbl.COUNT LOOP
             DBMS_OUTPUT.PUT_LINE('Inventory Item Id :'||to_char(x_item_tbl(i).inventory_item_id));
             DBMS_OUTPUT.PUT_LINE('Organization Id   :'||to_char(x_item_tbl(i).organization_id));
             
--             SELECT category_set_id INTO l_category_set_id FROM mtl_category_sets 
--             WHERE category_set_name = p_category_set_name;  -- 'Product Family'
--        
--             SELECT category_id INTO l_category_id FROM mtl_categories_b 
--             WHERE segment1||'.'||segment2||'.'||segment3||'.'||segment4 = p_category_name; -- 'Consumer Goods' 
             
             --XXPBSA_AssignItmToCat(p_Segment1, p_category_set_name, p_category_name);
             
          END LOOP;
       ELSE
          DBMS_OUTPUT.PUT_LINE('Error Messages :');
          Error_Handler.GET_MESSAGE_LIST(x_message_list=>x_message_list);
          FOR i IN 1..x_message_list.COUNT LOOP
             DBMS_OUTPUT.PUT_LINE(x_message_list(i).message_text);
          END LOOP;
       END IF;
       DBMS_OUTPUT.PUT_LINE('=====================================');       
   DBMS_OUTPUT.PUT_LINE('==========================================='); 
DBMS_OUTPUT.PUT_LINE('Calling EGO_ITEM_PUB.Assign_Item_To_Org API');                      
      DBMS_OUTPUT.put_line ('Organization Id   : ' ||x_item_tbl(l_rowcnt).inventory_item_id);
      DBMS_OUTPUT.put_line ('Inventory Item Id : ' ||x_item_tbl(l_rowcnt).inventory_item_id);
     EGO_ITEM_PUB.ASSIGN_ITEM_TO_ORG(p_api_version       => 1.0,
                                     p_init_msg_list     => fnd_api.g_true,
                                     p_commit            => fnd_api.g_true,
                                     p_inventory_item_id => x_item_tbl(l_rowcnt).inventory_item_id,
                                     p_item_number       => null,
                                     p_organization_id   => 102,
                                     p_organization_code => NULL,
                                     --p_primary_uom_code  => x_item_tbl(l_rowcnt).primary_uom,
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
          DBMS_OUTPUT.PUT_LINE('Exception Occured :');
          DBMS_OUTPUT.PUT_LINE(SQLCODE ||':'||SQLERRM);
          DBMS_OUTPUT.PUT_LINE('=====================================');
        RAISE;
END XXPBSA_PROCESS_ITEMS;
/