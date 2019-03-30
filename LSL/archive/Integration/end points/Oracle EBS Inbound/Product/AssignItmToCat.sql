CREATE OR REPLACE PROCEDURE XXPBSA_AssignItmToCat(p_segment1 IN VARCHAR2, p_category_set_name IN VARCHAR2, p_category_name IN VARCHAR2)
AS 
        l_api_version		     NUMBER := 1.0; 
        l_init_msg_list		     VARCHAR2(2) := FND_API.G_TRUE; 
        l_commit		         VARCHAR2(2) := FND_API.G_FALSE; 
        
        l_category_id            NUMBER;
        l_category_set_id        NUMBER;
        l_transaction_type       VARCHAR2(20) := EGO_ITEM_PUB.G_TTYPE_CREATE;

        x_message_list           Error_Handler.Error_Tbl_Type;
        x_return_status		     VARCHAR2(2);
        x_msg_count		         NUMBER := 0;
        x_msg_data               VARCHAR2(255);
        x_error_code             NUMBER;
    
        l_user_id		         NUMBER := -1;
        l_resp_id		         NUMBER := -1;
        l_application_id	     NUMBER := -1;
        l_rowcnt		         NUMBER := 1;
        l_user_name		         VARCHAR2(30) := 'SJAYASINGHE1';
        l_resp_name		         VARCHAR2(30) := 'EGO_DEVELOPMENT_MANAGER';    

        CURSOR csr_org_items IS
        SELECT inventory_item_id, organization_id
        FROM mtl_system_items_b 
        WHERE segment1 like p_segment1;

BEGIN
 
	-- Get the user_id
	SELECT user_id
	INTO l_user_id
	FROM fnd_user
	WHERE user_name = l_user_name;

	-- Get the application_id and responsibility_id
	SELECT application_id, responsibility_id
	INTO l_application_id, l_resp_id
	FROM fnd_responsibility
	WHERE responsibility_key = l_resp_name;

	FND_GLOBAL.APPS_INITIALIZE(l_user_id, l_resp_id, l_application_id);  -- MGRPLM / Development Manager / EGO
	dbms_output.put_line('Initialized applications context: '|| l_user_id || ' '|| l_resp_id ||' '|| l_application_id );
  
        SELECT category_set_id INTO l_category_set_id FROM mtl_category_sets 
        WHERE category_set_name = p_category_set_name;  -- 'Product Family'
        
        SELECT category_id INTO l_category_id FROM mtl_categories_b 
        WHERE segment1||'.'||segment2||'.'||segment3||'.'||segment4 = p_category_name
              and category_id = 2125; -- 'Consumer Goods'      
        
        -- call API to load Items
       DBMS_OUTPUT.PUT_LINE('====================================================');
       DBMS_OUTPUT.PUT_LINE('Calling EGO_ITEM_PUB.Process_Item_Cat_Assignment API');        
  
      FOR itm IN csr_org_items
      LOOP
              EGO_ITEM_PUB.Process_Item_Cat_Assignment        (
                                                                    l_api_version
                                                                  , l_init_msg_list
                                                                  , l_commit
                                                                  , l_category_id
                                                                  , l_category_set_id
                                                                  , NULL
                                                                  , itm.inventory_item_id
                                                                  , itm.organization_id
                                                                  , l_transaction_type
                                                                  , x_return_status
                                                                  , x_error_code
                                                                  , x_msg_count
                                                                  , x_msg_data
                                                             );
     
      END LOOP;
      
       DBMS_OUTPUT.PUT_LINE('==================================================');
       DBMS_OUTPUT.PUT_LINE('Return Status: '||x_return_status);

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          DBMS_OUTPUT.PUT_LINE('Error Message Count :'||x_msg_count);
          DBMS_OUTPUT.PUT_LINE('Error Message :'||x_msg_data);
       END IF;
       DBMS_OUTPUT.PUT_LINE('=========================================');       
        
EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Exception Occured :');
          DBMS_OUTPUT.PUT_LINE(SQLCODE ||':'||SQLERRM);
          DBMS_OUTPUT.PUT_LINE('========================================');
END;
/