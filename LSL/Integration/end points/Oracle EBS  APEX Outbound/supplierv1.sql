
BEGIN
  ords.enable_schema(p_enabled             => TRUE,
                     p_schema              => 'APEX',
                     p_url_mapping_type    => 'BASE_PATH',
                     p_url_mapping_pattern => 'api',
                     p_auto_rest_auth      => FALSE);
  COMMIT;
END;
/
BEGIN          
  ords.define_module(p_module_name    => 'oracle.v1',
                     p_base_path      => 'oracle/',
                     p_items_per_page => 10,
                     p_status         => 'PUBLISHED',
                     p_comments       => 'Oracle EBS outbounds');             
  COMMIT;
END;
/
BEGIN
  ords.define_template(p_module_name => 'oracle.v1',
                       p_pattern     => 'v1',
                       p_comments    => 'supplier creations and updates');
                       
  COMMIT;
END;
/
BEGIN
  ords.define_handler(p_module_name => 'oracle.v1',
                      p_pattern     => 'suppliers/',
                      p_method      => 'POST',
                      p_source_type => ords.source_type_plsql,
                      p_source      => q'['
                                        DECLARE
                                            l_response  VARCHAR2(32767);
                                        BEGIN
                                        
                                        IF :body is not null
                                        
                                            XXPBSA_UPDATE_SUP_GUID(UTL_RAW.cast_to_varchar2(:body));
                                        
                                        END;
                                            
                                            l_response := :body;
                                            
                                            HTP.p(l_response);
                                            
                                        EXCEPTION
                                          WHEN OTHERS THEN
                                            HTP.p('405 Invalid Input');
                                        END;]',
                      p_comments    => 'Send supplier data and update Oracle EBS accordingly');

END;


select *
from USER_ORDS_HANDLERS;