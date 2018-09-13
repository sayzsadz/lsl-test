--Create Role
BEGIN
  ords.create_role(p_role_name => 'store_role');
  COMMIT;
END;

-- Create privilege
DECLARE
  la_roles owa.vc_arr;
BEGIN
  la_roles(1) := 'store_role';
  ords.define_privilege(p_privilege_name => 'store.privilege',
                        p_roles          => la_roles,
                        p_label          => 'Store Access',
                        p_description    => 'Access to Store Web Services');
  COMMIT;
END;

-- Create Priviledge Mapping 
DECLARE
  la_priv_patterns owa.vc_arr;
BEGIN
  la_priv_patterns(1) := '/store/v1/stores';
  ords.create_privilege_mapping(p_privilege_name => 'store.privilege',
                                p_patterns       => la_priv_patterns);
  COMMIT;
END;


BEGIN
  oauth.create_client(p_name => 'Client 1',
                      p_grant_type       => 'client_credentials',
                      p_description      => 'Client with access to PO Resources',
                      p_support_email    => 'rpnalin@gmail.com',
                      p_privilege_names  => NULL);
  COMMIT;
END;

SELECT id, name, description, client_id, client_secret
FROM user_ords_clients
WHERE name = 'Client 1';

select *
from all_tables
where table_name like UPPER('%ords%');

select *
from ORDS_METADATA.USER_ORDS_CLIENT_ROLES;

select *
from ORDS_METADATA.USER_ORDS_CLIENT_PRIVILEGES;

select *
from ORDS_METADATA.USER_ORDS_URL_MAPPINGS;



select *
from ORDS_METADATA.OAUTH_CLIENT_PRIVILEGES;

BEGIN
  oauth.grant_client_role(p_client_name => 'Client 1',
                          p_role_name   => 'store_role');
  COMMIT;
END;


SELECT id, name, uri_prefix
FROM   user_ords_modules
ORDER BY name;

SELECT id, module_id, uri_template
FROM   user_ords_templates
ORDER BY module_id;