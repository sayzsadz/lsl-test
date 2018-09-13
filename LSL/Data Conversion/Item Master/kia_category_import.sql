SET SERVEROUTPUT ON;
DECLARE
  v_return_status  VARCHAR2(1)   := NULL;
  v_msg_count      NUMBER        := 0;
  v_msg_data       VARCHAR2(2000);
  v_errorcode      VARCHAR2(1000);
  v_category_rec   INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE;
  v_category_id    NUMBER;
 
  v_context         VARCHAR2 (2);

 /* FUNCTION set_context( i_user_name    IN  VARCHAR2
                     ,i_resp_name    IN  VARCHAR2
                     ,i_org_id       IN  NUMBER)
  RETURN VARCHAR2
  IS
  BEGIN
  NULL;
  -- Inorder to reduce the content of the post I moved the implementation part of this function to another post and it is available here 
  END set_context;*/
  
  cursor  c_categories is
  select  rowid, segment1,segment2,segment3, segment4, segment5,segment6
  from    XXX_kia_INV_CATEGORIES_STAGING
  --where   processed_flag='N';
  where (segment1,segment2,segment3, segment4, segment5,segment6)  not in (select   segment1,segment2,segment3, segment4, segment5,segment6
  from    mtl_categories_b where segment1='SPAPA');
  
 /* select * from mtl_categories_b where  (segment1,segment2,segment3, segment4, segment5,segment6)
    not in (select   segment1,segment2,segment3, segment4, segment5,segment6
  from    XXX_kia_INV_CATEGORIES_STAGING where segment1='SPAPA'
  )
  
   select * from XXX_kia_INV_CATEGORIES_STAGING where (segment1,segment2,segment3, segment4, segment5,segment6)
   not in (select   segment1,segment2,segment3, segment4, segment5,segment6
  from    mtl_categories_b where segment1='SPAPA')
  */
 
BEGIN

-- Setting the context ----
--v_context := set_context ('&user', '&responsibility', 2038);
--v_context := kia_set_context (1110, 50649, 2038);
v_context := kia_set_context ('SAKAF','KIA_Inventory Super User', 2038);
IF v_context = 'F'
   THEN
   DBMS_OUTPUT.put_line ('Error while setting the context');
END IF;

--- context done ------------

for crec_cat in c_categories loop

v_category_rec              := NULL;
v_category_rec.structure_id := 101;
v_category_rec.summary_flag := 'N';
v_category_rec.enabled_flag := 'Y';
v_category_rec.segment1     := crec_cat.segment1;
v_category_rec.segment2     := crec_cat.segment2;
v_category_rec.segment3     := crec_cat.segment3;
v_category_rec.segment4     := crec_cat.segment4;
v_category_rec.segment5     := crec_cat.segment5;
v_category_rec.segment6     := crec_cat.segment6;

-- Calling the api to create category --

INV_ITEM_CATEGORY_PUB.CREATE_CATEGORY
  (
  p_api_version   => 1.0,
  p_init_msg_list => fnd_api.g_true,
  p_commit        => fnd_api.g_false,
  x_return_status => v_return_status,
  x_errorcode     => v_errorcode,
  x_msg_count     => v_msg_count,
  x_msg_data      => v_msg_data,
  p_category_rec  => v_category_rec,
  x_category_id   => v_category_id --returns category id
);

 IF v_return_status = fnd_api.g_ret_sts_success THEN
    COMMIT;
    DBMS_OUTPUT.put_line ('Creation of Item Category is Successful : '||v_CATEGORY_ID);
 ELSE
    DBMS_OUTPUT.put_line ('Creation of Item Category Failed with the error :'||v_ERRORCODE||v_msg_data);
    ROLLBACK;
    FOR i IN 1 .. v_msg_count
     LOOP
        v_msg_data := oe_msg_pub.get( p_msg_index => i, p_encoded => 'F');
        dbms_output.put_line( i|| ') '|| v_msg_data);
      
      update  XXX_kia_INV_CATEGORIES_STAGING
      set     processed_flag = 'E', Error_Mesg='Error Insert '||crec_cat.segment1||'.'||crec_cat.segment2||'.'||crec_cat.segment3||'.'||crec_cat.segment4||'.'||crec_cat.segment5||'.'||crec_cat.segment6
      WHERE   rowid=crec_cat.rowid;
      commit;

     END LOOP;
 END IF;
 
 end loop;
END;



