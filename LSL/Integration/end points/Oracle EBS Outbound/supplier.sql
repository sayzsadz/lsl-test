BEGIN
  ords.define_handler(p_module_name    => 'lslmodule.v1',
                      p_pattern        => 'supplier',
                      p_method         => 'POST',
                      p_source_type    => ords.source_type_plsql,
                      p_source         => 'BEGIN
                                          
                                          :pn_status := 200;
                                          :pv_result := ''Department Added'';
                                        EXCEPTION
                                          WHEN OTHERS THEN
                                            :pn_status := 400;
                                            :pv_result := ''Unable to add department: '' 
                                                          || SQLERRM;
                                        END;',
                      p_items_per_page => 0,
                      p_comments       => 'check supplier');
  COMMIT;
  exception
    when others then
      dbms_output.put_line(''||sqlerrm);
END;
/

BEGIN
       
  ords.define_module(p_module_name    => 'lslmodule.v1',
                     p_base_path      => 'lslmodule/v1/',
                     p_items_per_page => 5,
                     p_status         => 'PUBLISHED',
                     p_comments       => 'check supplier');             
  COMMIT;
END;
/ 

BEGIN
  ords.define_template(p_module_name => 'lslmodule.v1',
                       p_pattern     => 'supplier',
                       p_comments    => 'check supplier');

  COMMIT;
END;
/

select *
from USER_ORDS_HANDLERS;

BEGIN
  ords.enable_schema(p_enabled             => TRUE,
                     p_schema              => 'APEX',
                     p_url_mapping_type    => 'BASE_PATH',
                     p_url_mapping_pattern => 'api',
                     p_auto_rest_auth      => FALSE);
  COMMIT;
END;

BEGIN          
  ords.define_module(p_module_name    => 'oracle.v1',
                     p_base_path      => 'oracle/',
                     p_items_per_page => 10,
                     p_status         => 'PUBLISHED',
                     p_comments       => 'Sample HR Module');             
  COMMIT;
END;

BEGIN
  ords.define_template(p_module_name => 'oracle.v1',
                       p_pattern     => 'v1',
                       p_comments    => 'Departments Resource');
                       
  COMMIT;
END;

BEGIN
  ords.define_handler(p_module_name => 'oracle.v1',
                      p_pattern     => 'v1',
                      p_method      => 'POST',
                      p_source_type => ords.source_type_plsql,
                      p_source      => 'SELECT sup.*,
                                            CURSOR (select  *
                                            from ADDRESS ad
                                            where ad.SUPPLIERID = sup.SUPPLIERID) as ADDRESS
                                            FROM SUPPLIER sup',
                      p_comments    => 'Create a Department');

END;
BEGIN
  ords.define_template(p_module_name => 'oracle.v1',
                       p_pattern     => 'employee',
                       p_comments    => 'Departments Resource');

  COMMIT;
END;
BEGIN
  ords.define_handler(p_module_name => 'oracle.v1',
                      p_pattern     => 'employee',
                      p_method      => 'POST',
                      p_source_type => ords.source_type_plsql,
                      p_source      => 'BEGIN
                                          
                                          :pn_status := 200;
                                          :pv_result := ''Department Added'';
                                        EXCEPTION
                                          WHEN OTHERS THEN
                                            :pn_status := 400;
                                            :pv_result := ''Unable to add department: '' 
                                                          || SQLERRM;
                                        END;',
                      p_comments    => 'Create a Department');

END;


select *
from USER_ORDS_HANDLERS;
