DECLARE

    X_RETURN_STATUS     VARCHAR2(1000);
    X_ERRORCODE         NUMBER;
    X_MSG_COUNT         NUMBER;
    X_MSG_DATA          VARCHAR2(1000);
    l_error_message     VARCHAR2 (1000) := NULL;
    x_msg_index_out     NUMBER;
    L_CATEGORY_ID       NUMBER;
    L_INVENTORY_ITEM_ID NUMBER;

    v_old_category  number;

      cursor  c_off_items is
      select  * 
      from XXPBSA_ITEM_CATEGORIES_STG;
 

BEGIN
  --Apps Initialization is available in another section. Use the below link to know in detail
        Apps_Initialize;
        
  for crec_off_items in c_off_items loop 
  
    select mic.CATEGORY_ID
    into L_CATEGORY_ID
        ,L_INVENTORY_ITEM_ID
    from  mtl_item_categories mic
         ,mtl_system_items_b msi
    where 1= 1
          and mic.INVENTORY_ITEM_ID = msi.INVENTORY_ITEM_ID
          and msi.organization_id = 102
          and mic.organization_id = 102
          and msi.segment1 = crec_off_items.item_number;

   INV_ITEM_CATEGORY_PUB.UPDATE_CATEGORY_ASSIGNMENT
                                                (  P_API_VERSION        => 1.0,  
                                                   P_INIT_MSG_LIST      => FND_API.G_FALSE,  
                                                   P_COMMIT             => FND_API.G_FALSE,
                                                   P_CATEGORY_ID        => L_CATEGORY_ID,
                                                   P_OLD_CATEGORY_ID    => NULL,
                                                   P_CATEGORY_SET_ID    => 1,  
                                                   P_INVENTORY_ITEM_ID  => L_INVENTORY_ITEM_ID,
                                                   P_ORGANIZATION_ID    => 102,
                                                   X_RETURN_STATUS      => X_RETURN_STATUS,  
                                                   X_ERRORCODE          => X_ERRORCODE,  
                                                   X_MSG_COUNT          => X_MSG_COUNT,  
                                                   X_MSG_DATA           => X_MSG_DATA);

    IF x_return_status = fnd_api.g_ret_sts_success
   THEN
      COMMIT;
      DBMS_OUTPUT.put_line ('Item Category Assignment using API is Successful');
   ELSE
      BEGIN
         IF (fnd_msg_pub.count_msg > 1)
         THEN
            FOR k IN 1 .. fnd_msg_pub.count_msg
            LOOP
               fnd_msg_pub.get ( p_msg_index            => k,
                                 p_encoded              => 'F',
                                 p_data                 => x_msg_data,
                                 p_msg_index_out        => x_msg_index_out
                                );

               DBMS_OUTPUT.PUT_LINE('x_msg_data:= ' || x_msg_data);
               IF x_msg_data IS NOT NULL
               THEN
                  l_error_message := l_error_message || '-' || x_msg_data;
               END IF;
            END LOOP;
         ELSE
            --Only one error
            fnd_msg_pub.get (  p_msg_index       => 1,
                               p_encoded         => 'F',
                               p_data            => x_msg_data,
                               p_msg_index_out   => x_msg_index_out
                            );
            l_error_message := x_msg_data;
         END IF;

         DBMS_OUTPUT.put_line (   'Error encountered by the API is '|| l_error_message
                              );
         ROLLBACK;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_error_message := SQLERRM;
            DBMS_OUTPUT.put_line (   'Error encountered by the API is '|| l_error_message
                                 );
      END;
   END IF;
   
    end loop;
  EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line
                   (   'Error in Assigning Category to an Item and error is '
                    || SUBSTR (SQLERRM, 1, 200)
                   );
 
 END;
 
 