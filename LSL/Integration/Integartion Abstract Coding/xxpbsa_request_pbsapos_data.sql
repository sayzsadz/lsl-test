create or replace function xxpbsa_request_pbsapos_data (
                                                          p_url           in varchar2
                                                        , p_token_type    in varchar2
                                                        , p_access_token  in varchar2
                                                        , p_date_from     in varchar2
                                                        , p_date_to       in varchar2
                                                        )
return CLOB
is                                                      
  l_clob         CLOB;
  l_buffer       varchar2(32767);
  l_amount       number;
  l_offset       number;
  l_body         varchar2(100);
  l_date_from    varchar2(30);
  l_date_to      varchar2(30);
  l_token_type   varchar2(30);
  l_access_token varchar2(2000);
  l_url          varchar2(1000);
  -- l_site_name    varchar2(50) := 'http://104.197.10.182/ap1/api/v1/sales/summary';
  -- l_username     varchar2(50) := 'ck_o3vuhza8bgmvu5lxronckr2favaxeiolh3izb';
  -- l_password     varchar2(50) := 'cs_6bhldx7owbxrcmuo5ajcb7rql9mb0hglqrp97';
  -- l_basic_base64 varchar2(2000);

begin

  l_token_type    := p_token_type;
  l_access_token  := p_access_token;
  --l_basic_base64 := replace(utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(l_site_name||'\'||l_username||':'||l_password))),chr(13)||chr(10),'');
  --apex_web_service.g_request_headers(1).name    := 'User-Agent';
  --apex_web_service.g_request_headers(1).value   := 'Mozilla';
  apex_web_service.g_request_headers(1).name    := 'Authorization';
  apex_web_service.g_request_headers(1).value   := l_token_type||' '||l_access_token;
  apex_web_service.g_request_headers(2).name    := 'Content-Type';
  apex_web_service.g_request_headers(2).value   := 'application/json';
  --apex_web_service.g_request_headers(3).name    := 'Accept';  
  --apex_web_service.g_request_headers(3).value   := 'application/json'; 
  
  l_date_from := p_date_from;
  l_date_to := p_date_to;
  
  -- apex_json.parse
  select  '{"DateFrom": "'||l_date_from||'","DateTo": "'||l_date_to||'"}'
  into l_body
  from dual;
  
  l_url := p_url;
  
  -- Invoke the PBSA web service to retrieve data
  select apex_web_service.make_rest_request(  p_url         => l_url,
                                              p_http_method => 'POST',
                                              p_body        => l_body,
                                              p_wallet_path => 'file:/home/oracle/wallet2',
                                              p_wallet_pwd  => null,
                                              p_https_host  => 'support.pbsa.com.au' 
                                              )
  into l_clob
  from dual;
                                              
                                                
  DBMS_OUTPUT.put_line(l_clob);
  
--  l_amount := 32000;
--  l_offset := 1;
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
--                l_clob := null;
--            when others then
--                DBMS_OUTPUT.put_line(SQLERRM);
--                l_clob := null;
--        end;
--      
      return l_clob;
      
end;