BEGIN
  ords.define_handler(p_module_name    => 'lslmodule3.v1',
                      p_pattern        => 'supplier/',
                      p_method         => 'POST',
                      p_source_type    => ords.source_type_collection_feed,
                      p_source         => ' SELECT sup.*,
                                            CURSOR (select  *
                                            from ADDRESS ad
                                            where ad.SUPPLIERID = sup.SUPPLIERID) as ADDRESS
                                            FROM SUPPLIER sup;',
                      p_items_per_page => 0,
                      p_comments       => 'get supplier');
  COMMIT;
  exception
    when others then
      dbms_output.put_line(''||sqlerrm);
END;
/

BEGIN
       
  ords.define_module(p_module_name    => 'lslmodule3.v1',
                     p_base_path      => 'lslmodule3/v1/',
                     p_items_per_page => 5,
                     p_status         => 'PUBLISHED',
                     p_comments       => 'check supplier');             
  COMMIT;
END;
/ 

BEGIN
  ords.define_template(p_module_name => 'lslmodule3.v1',
                       p_pattern     => 'supplier/',
                       p_comments    => 'check supplier');

  COMMIT;
END;
/