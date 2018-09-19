CREATE OR REPLACE PROCEDURE check_product (p_data  IN  varchar2, p_msg OUT varchar2)
AS
  lv_PRODUCTID    number;
  v_msg         varchar2(100);
BEGIN
    BEGIN
        SELECT count(PRODUCTID) cnt
        INTO lv_PRODUCTID
        FROM PRODUCT
        WHERE PRODUCTID = (
        SELECT PRODUCTID
        FROM 
             JSON_TABLE(
                p_data
             , '$[*]' COLUMNS (
              ProductId VARCHAR2(100) PATH '$.ProductId'
        
        ))
        );
        
        IF lv_PRODUCTID > 0
          THEN
            
            select 'successful operation'
            into v_msg
            from dual;
            
            p_msg :=  v_msg;
            
        ELSE
            
            select 'unsuccessful operation'
            into v_msg
            from dual;
              
            p_msg :=  v_msg;
            
        END IF;
        
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
  ords.define_template(p_module_name => 'lslmodule5.v1',
                       p_pattern     => 'products/',
                       p_comments    => 'check products');

  COMMIT;
END;
/
begin
  ORDS.define_handler(
    p_module_name    => 'lslmodule5.v1',
    p_pattern        => 'products/',
    p_method         => 'POST',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => q'[DECLARE                            
                            v_msg VARCHAR2(1000);
                            l_response  VARCHAR2(32767);                      
                           BEGIN                             
                             -- Build response.
                             check_product(UTL_RAW.cast_to_varchar2(:body), v_msg);
                             l_response := v_msg;
 
                             -- Output response text.
                             HTP.p(l_response);
                             
                         END;]',
    p_items_per_page => 1);

  COMMIT;
END;
/