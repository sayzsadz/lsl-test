select utl_http.request ('http://dummy.restapiexample.com/api/v1/employees',null,null,null)
from dual;

declare
    l_clob      CLOB;
BEGIN
 exec DBMS_OUTPUT.put_line(APEX_ACL.HAS_USER_ANY_ROLES (p_application_id =>255, p_user_name      =>  'SYS'));
 
--    l_clob := apex_web_service.make_rest_request(
--        p_url => 'http://dummy.restapiexample.com/api/v1/employees',
--        p_http_method => 'POST'
--        --p_parm_name => apex_util.string_to_table('appid:format'),
--        --p_parm_value => apex_util.string_to_table('xyz:xml')
--        );
 
END;
/
SET SERVEROUTPUT ON;
EXEC UTL_HTTP.set_wallet('WALLET_PATH', 'Pa$$w0rd');
EXEC show_html_from_url('https://203.208.66.244:31258/api/token/');
