BEGIN 
DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE( 
host => '*', 
ace => xs$ace_type(privilege_list => xs$name_list('connect'), 
principal_name => 'APEX_180100', 
principal_type => xs_acl.ptype_db)); 
END; 
/ 

select UTL_HTTP.REQUEST('https://203.208.66.244:31258/api/token',null,'file:/home/oraapex/wallet',null) Output from dual;

select apex_web_service.make_rest_request(
p_url=>'https://www.example.com/api/rest/orders',
p_http_method=>'GET',
p_https_host=>'*.someotherhost.net')
from dual;