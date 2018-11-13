create or replace procedure IMPORT_SALES_SUMMARY
as
    l_token_type    varchar2(50);
    l_access_token  varchar2(2000);
    p_token_type    varchar2(50);
    p_access_token  varchar2(2000);
    l_client_id     varchar2(200) := 'ck_ufyuken0jybbasfanuqadtxcg0vcx8gx01uyt';
    l_client_secret varchar2(200) := 'cs_0hioe2gwvnwlj1t7sfq3b08teh7jq1al7mxm4';
    l_response      CLOB;
begin
    xxpbsa_request_pbsa_token(l_client_id, l_client_secret, p_token_type, p_access_token);
    l_token_type    := p_token_type;
    l_access_token  := p_access_token;
--    DBMS_OUTPUT.put_line('Token Type: '||l_token_type);
--    DBMS_OUTPUT.put_line('Access Token: '||l_access_token);
    
    select xxpbsa_request_pbsapos_data ( p_url           => 'https://203.208.66.244:31258/api/v1/sales/summary'
                                              , p_token_type    => l_token_type
                                              , p_access_token  => l_access_token
                                              , p_date_from     => '1 Jan 2018'
                                              , p_date_to       => '31 Dec 2018'
                                              )
    into l_response
    from dual;
    
    create_sales_summary(l_response);
    --DBMS_OUTPUT.put_line('detailed error message: '||UTL_HTTP.get_detailed_sqlerrm);
    
end;