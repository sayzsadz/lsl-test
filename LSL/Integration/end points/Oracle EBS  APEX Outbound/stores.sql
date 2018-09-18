CREATE OR REPLACE PROCEDURE check_store (p_data  IN  varchar2, p_msg OUT varchar2)
AS
  lv_StoreId    number;
  v_msg         varchar2(100);
BEGIN
    BEGIN
        SELECT STOREID
        INTO lv_StoreId
        FROM STORE
        WHERE STOREID = (
        SELECT StoreId
        FROM 
             JSON_TABLE(
          p_data
             , '$[*]' COLUMNS (
              StoreId NUMBER PATH '$.StoreId'
        
        ))
        );
            select 'successful operation'
            into v_msg
            from dual;
            
            p_msg :=  v_msg;
            
        EXCEPTION
          WHEN OTHERS THEN
            select 'unsuccessful operation'
            into v_msg
            from dual;
              
            p_msg :=  v_msg;
      END;
END;     
/

  
BEGIN
  ords.define_template(p_module_name => 'lslmodule7.v1',
                       p_pattern     => 'stores/',
                       p_comments    => 'check store');

  COMMIT;
END;
/
begin
  ORDS.define_handler(
    p_module_name    => 'lslmodule7.v1',
    p_pattern        => 'stores/',
    p_method         => 'POST',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => q'[DECLARE                            
                            v_msg VARCHAR2(1000);
                            l_response  VARCHAR2(32767);                      
                           BEGIN                             
                             -- Build response.
                             check_store(UTL_RAW.cast_to_varchar2(:body), v_msg);
                             l_response := v_msg;
 
                             -- Output response text.
                             HTP.p(l_response);
                             
                         END;]',
    p_items_per_page => 1);

  COMMIT;
END;
/