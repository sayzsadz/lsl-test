create or replace procedure XXPBSA_EXECUTE_IMPORT_PRC
as
    l_token_type    varchar2(50);
    l_access_token  varchar2(2000);
    p_token_type    varchar2(50);
    p_access_token  varchar2(2000);
    l_response      varchar2(20000);
    l_url           varchar2(100);
    l_https_host    varchar2(100);
    l_wallet_path   varchar2(50);
    sqlstring       varchar2(10000);
    
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
      --where PROCNAME in ( 'create_sales_summary', 'create_returns_summary', 'create_pay_sum_takings' , 'create_pay_sum_returns');
      where PROCNAME in ( 'create_sales_summary', 'create_returns_summary');
    
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
    
    
    --sqlstring := cur_rec.PROCNAME || '(' || l_response || ')';
    
    --dbms_output.put_line(sqlstring);

    --execute immediate sqlstring;

    
    if cur_rec.PROCNAME = 'create_sales_summary'
      then create_sales_summary(l_response);            
      dbms_output.put_line('create_sales_summary procedure 1.');
    elsif cur_rec.PROCNAME = 'create_returns_summary'
      then create_returns_summary(l_response);
      dbms_output.put_line('create_returns_summary procedure 2.');
    elsif cur_rec.PROCNAME = 'create_pay_sum_takings'
      then create_pay_sum_takings(l_response);
      dbms_output.put_line('create_pay_sum_takings procedure 3.');
    elsif cur_rec.PROCNAME = 'create_pay_sum_returns'
      then create_pay_sum_returns(l_response);
      dbms_output.put_line('create_pay_sum_returns procedure 4');
    elsif cur_rec.PROCNAME = 'create_pay_sum_credit'
      then create_pay_sum_credit(l_response);
      dbms_output.put_line('create_pay_sum_credit procedure 5.');
    elsif cur_rec.PROCNAME = 'create_sup_returns_summary'
      then create_sup_returns_summary(l_response);
      dbms_output.put_line('create_sup_returns_summary procedure 6');      
    elsif cur_rec.PROCNAME = 'create_stock_inter_trans'
      then create_stock_inter_trans(l_response);
      dbms_output.put_line('create_stock_inter_trans procedure 7');      
    elsif cur_rec.PROCNAME = 'create_stock_movement'
      then create_stock_movement(l_response);
      dbms_output.put_line('create_stock_movement procedure 8.');      
    elsif cur_rec.PROCNAME = 'create_deliveries_summary'
      then create_deliveries_summary(l_response);
      dbms_output.put_line('create_deliveries_summary procedure 9.');      
    elsif cur_rec.PROCNAME = 'create_tills_bank_deposits'
      then create_tills_bank_deposits(l_response);
      dbms_output.put_line('create_tills_bank_deposits procedure 10.');      
    elsif cur_rec.PROCNAME = 'create_tills_reconciliations'
      then create_tills_reconciliations(l_response);
      dbms_output.put_line('create_tills_reconciliations procedure 11.');
    else
      dbms_output.put_line('no procedure');
    end if;

    
    update XXPBSA_ENDPOINTS
    set STATUS = 'P', PARAMETER1 = l_response
    where PROCNAME = cur_rec.PROCNAME;

    
    end loop;
    --DBMS_OUTPUT.put_line('detailed error message: '||UTL_HTTP.get_detailed_sqlerrm);
    
end;