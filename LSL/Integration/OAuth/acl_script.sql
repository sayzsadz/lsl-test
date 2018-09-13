BEGIN
    DBMS_NETWORK_ACL_ADMIN.create_acl(
                                      acl           =>  'psbapos_acl.xml',
                                      description   =>  'Connect to PBSAPOS',
                                      principal     =>  'SYS',                        
                                      is_grant      =>  TRUE,
                                      privilege     =>  'connect',
                                      start_date    =>  SYSTIMESTAMP,
                                      end_date      =>  NULL
    );
End;
/

begin
    DBMS_NETWORK_ACL_ADMIN.assign_acl(
                                      acl => 'psbapos_acl.xml',
                                      host=> '13.67.34.43'
    );
End;
/

BEGIN
  DBMS_NETWORK_ACL_ADMIN.add_privilege ( 
                                        acl         => 'psbapos_acl.xml', 
                                        principal   => 'LSLDEMO',
                                        is_grant    => true, 
                                        privilege   => 'connect', 
                                        position    => NULL, 
                                        start_date  => NULL,
                                        end_date    => NULL
  );

  COMMIT;
END;
/



BEGIN
  DBMS_NETWORK_ACL_ADMIN.drop_acl ( 
                                    acl         => 'psbapos_acl.xml'
  );

  COMMIT;
END;
/

select * FROM   dba_network_acls;

SELECT * FROM dba_network_acl_privileges;