
BEGIN
  ords.enable_schema(p_enabled             => TRUE,
                     p_schema              => 'APEX',
                     p_url_mapping_type    => 'BASE_PATH',
                     p_url_mapping_pattern => 'apex',
                     p_auto_rest_auth      => FALSE);
  COMMIT;
END;
/
BEGIN          
  ords.define_module(p_module_name    => 'dev.v1',
                     p_base_path      => 'dev/',
                     p_items_per_page => 10,
                     p_status         => 'PUBLISHED',
                     p_comments       => 'Oracle EBS outbounds');             
  COMMIT;
END;
/
BEGIN
  ords.define_template(p_module_name => 'dev.v1',
                       p_pattern     => 'suppliers/',
                       p_comments    => 'supplier creations and updates');
                       
  COMMIT;
END;
/
BEGIN
  ords.define_handler(p_module_name => 'dev.v1',
                      p_pattern     => 'suppliers/',
                      p_method      => 'POST',
                      p_source_type => ords.source_type_plsql,
                      p_source      => q'[
                                        DECLARE
                                            l_response  VARCHAR2(32767);
                                        BEGIN
                                        
                                            l_response := UTL_RAW.cast_to_varchar2(:body);
                                            
                                            IF l_response = '{}'
                                            THEN
--                                                l_response := '{
--"supplier":[{"SupplierId":"","Name":"Ewis Peripherals (Pvt) Ltd","BillToAddress":[{"Street":"Galle face","PostCode":"01400","Country":"SRI LANKA","ContactName":"Test-Anchor"}],"ShipToAddress":[{"Street":"Galle face","PostCode":"01400","Country":"SRI LANKA","ContactName":"Test-Anchor"}],"Active":true}]
--}';
                                                 l_response := XXPBSA_CRUD_EBS_SUPPLIERS;
                                            ELSE
                                                XXPBSA_UPDATE_SUP_GUID@DATABASE_LINK_APEX_EBS(l_response);
                                                l_response := 'successful operation';
                                            END IF;
                                            
                                            HTP.p(l_response);
                                            
                                        EXCEPTION
                                          WHEN OTHERS THEN
                                            HTP.p('405 Invalid Input'||SQLERRM);
                                        END;]',
                      p_comments    => 'Send supplier data and update Oracle EBS accordingly');
commit;
END;
/