create or replace procedure XXPBSA_EXECUTE_IMPORT_PRC
as
    l_token_type    varchar2(50);
    l_access_token  varchar2(2000);
    p_token_type    varchar2(50);
    p_access_token  varchar2(2000);
    l_response      CLOB;
    l_url           varchar2(100);
    l_https_host    varchar2(100);
    l_wallet_path   varchar2(50);
    
    cursor cur
    is
      select HOST,
             PORT,
             BASE_URL,
             ENDPOINT_URL,
             PROTOCOL,
             PROCNAME,
             TO_CHAR(SYSTIMESTAMP - INTERVAL '1' DAY, 'yyyy-mm-dd"T"HH24:MI:SS.SSTZH:TZM') START_DATE,
             TO_CHAR(systimestamp, 'yyyy-mm-dd"T"HH24:MI:SS.SSTZH:TZM') END_DATE
      from XXPBSA_ENDPOINTS
      where PROCNAME = 'create_sales_summary';
    
begin
    xxpbsa_request_pbsa_token;
    
    select TOKEN_TYPE
          ,ACCESS_TOKEN
          ,URL
          ,HTTPS_HOST
          ,WALLET_PATH
    into l_token_type
        ,l_access_token
        ,l_url
        ,l_https_host
        ,l_wallet_path
    from XXPBSA_OAUTH
    where rownum = 1; 
    
    
    
--    DBMS_OUTPUT.put_line('Token Type: '||l_token_type);
--    DBMS_OUTPUT.put_line('Access Token: '||l_access_token);

    for cur_rec in cur
    loop
    select xxpbsa_request_pbsapos_data (  p_url           => cur_rec.PROTOCOL||cur_rec.HOST||cur_rec.PORT||cur_rec.BASE_URL||cur_rec.ENDPOINT_URL
                                        --, p_token_type    => l_token_type
                                        --, p_access_token  => l_access_token
                                        , p_date_from     => cur_rec.START_DATE
                                        , p_date_to       => cur_rec.END_DATE
                                       )
    into l_response
    from dual;
    
    begin
    --execute immediate 'begin ' || 'create_sales_summary' || '('|| '{}' ||'); end;';
    
    --create_sales_summary(l_response);
    
    update XXPBSA_ENDPOINTS
    set STATUS = 'P', PARAMETER1 = l_response
    where STATUS = 'N';
    end;
    
    end loop;
    --DBMS_OUTPUT.put_line('detailed error message: '||UTL_HTTP.get_detailed_sqlerrm);
    
end;