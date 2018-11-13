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
                                      host=> '203.208.66.244'
    );
End;
/

BEGIN
  DBMS_NETWORK_ACL_ADMIN.add_privilege ( 
                                        acl         => 'psbapos_acl.xml', 
                                        principal   => 'APEX_050000',
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

select *
from dba_tables
where table_name like 'DBA_NETWORK_ACL_WALLET';

select *
from  DBA_NETWORK_ACL_;

SELECT * FROM dba_network_acl_privileges;

BEGIN
  DBMS_NETWORK_ACL_ADMIN.drop_acl ( 
    acl         => 'psbapos_acl.xml');

  COMMIT;
END;
/
