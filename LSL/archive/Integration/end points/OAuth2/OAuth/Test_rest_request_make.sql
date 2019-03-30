declare
l_clob CLOB;
begin
        select APEX_WEB_SERVICE.make_rest_request ( p_url         => 'https://203.208.66.244:31258/api/token',
                                                       p_http_method => 'POST',
                                                       p_body        => 'grant_type=password'||'&'||'username='||'ck_ufyuken0jybbasfanuqadtxcg0vcx8gx01uyt'||'&'||'password='||'cs_0hioe2gwvnwlj1t7sfq3b08teh7jq1al7mxm4',
                                                       -- p_parm_name   => apex_util.string_to_table('appid:format'),
                                                       -- p_parm_value  => apex_util.string_to_table(apex_application.g_x01||':'||apex_application.g_x02)
                                                       p_wallet_path => 'file:/home/oracle/wallet2',
                                                       p_wallet_pwd  => null,
                                                       p_https_host  => 'support.pbsa.com.au'
                                                     )
        into l_clob
        from dual;
        
        DBMS_OUTPUT.PUT_LINE(l_clob);
       
end;