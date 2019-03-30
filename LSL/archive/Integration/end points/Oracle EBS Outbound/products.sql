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
    p_source         => 
                         q'[
                                        DECLARE
                                            l_response  VARCHAR2(32767);
                                            v_msg       VARCHAR2(50);
                                        BEGIN
                                        
                                            l_response := UTL_RAW.cast_to_varchar2(:body);
                                            check_product(l_response, v_msg);
                                            
                                            HTP.p(v_msg);
                                            
                                        EXCEPTION
                                          WHEN OTHERS THEN
                                            HTP.p('405 Invalid Input');
                                        END;]'
                         
                         ,
    p_items_per_page => 1);

  COMMIT;
END;
/