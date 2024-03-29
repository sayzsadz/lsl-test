create or replace procedure xxpbsa_request_pbsa_token(
                                                       p_client_id     in varchar2
                                                     , p_client_secret in varchar2
                                                     , p_token_type    out varchar2
                                                     , p_access_token  out varchar2
                                                     , p_expires_in    out number
                                                     )
AS
        l_clob           CLOB;
        l_buffer         varchar2(32767);
        l_amount         number;
        l_offset         number;
        l_client_id      varchar2(2000);
        l_client_secret  varchar2(2000);
        l_token_type     varchar2(20);
        l_access_token   varchar2(2000);
        l_expires_in     number;
        
BEGIN
        --apex_web_service.g_request_headers(1).name    := 'User-Agent';
        --apex_web_service.g_request_headers(1).value   := 'Mozilla';
        -- Request grants for username and password
        -- Get the token from the web service.
        l_client_id     := p_client_id;
        l_client_secret := p_client_secret;
        select APEX_WEB_SERVICE.make_rest_request ( p_url         => 'https://203.208.66.244:31258/api/token',
                                                       p_http_method => 'POST',
                                                       p_body        => 'grant_type=password'||'&'||'username='||l_client_id||'&'||'password='||l_client_secret,
                                                       -- p_parm_name   => apex_util.string_to_table('appid:format'),
                                                       -- p_parm_value  => apex_util.string_to_table(apex_application.g_x01||':'||apex_application.g_x02)
                                                       p_wallet_path => 'file:/home/oracle/wallet2',
                                                       p_wallet_pwd  => null,
                                                       p_https_host  => 'support.pbsa.com.au'
                                                     )
        into l_clob
        from dual;
        -- reads the invoked web service response for OAuth tokenization
        -- clob typed object reads twice and need improvements
 
        select json_value(l_clob, '$.token_type')
        into l_token_type
        from dual;
        
        p_token_type := l_token_type;
        
        select json_value(l_clob, '$.access_token')
        into l_access_token
        from dual;
        
        p_access_token := l_access_token;
        
        select json_value(l_clob, '$.expires_in')
        into l_expires_in
        from dual;
        
        p_expires_in := l_expires_in;
        
        insert into XXPBSA_OAUTH (
                                  TOKEN_TYPE,
                                  ACCESS_TOKEN,
                                  EXPIRES_IN_SEC,
                                  START_DATE,
                                  END_DATE
                                 ) 
                         VALUES (
                                  l_token_type,
                                  l_access_token,
                                  l_expires_in,
                                  SYSDATE,
                                  SYSDATE + l_expires_in
                                );
        commit;
--                                               
--        l_amount := 32000;
--        l_offset := 1;
--
--        begin
--            loop
--                dbms_lob.read( l_clob, l_amount, l_offset, l_buffer );
--                htp.p(l_buffer);
--                l_offset := l_offset + l_amount;
--                l_amount := 32000;
--            end loop;
--        exception
--            when no_data_found then
--                DBMS_OUTPUT.put_line('Message: unsuccessful operation');
--            when others then
--                DBMS_OUTPUT.put_line(SQLERRM);
--        end;
END;