create or replace function xxlsl_apply_recipt(
										 p_amount 				number ,
										 p_receipt_number 		varchar2,
										 p_receipt_date 		date,
										 p_gl_date 				date,
										 p_customer_number 		varchar2,
										 p_receipt_method_id 	number 1001,
										 p_trx_number 			varchar2,
										 p_currency_code 		varchar2 'LKR'
)
return varchar2
	l_return_status 		VARCHAR2(1);
	l_msg_count 			NUMBER;
	l_msg_data 				VARCHAR2(240);
	l_cash_receipt_id 		NUMBER;
	p_count 				number := 0;
    
	v_user_id      NUMBER;
	v_resp_id      NUMBER;
	v_resp_appl_id NUMBER;
	v_lang         VARCHAR2(100);
	v_session_lang VARCHAR2(100)	:=fnd_global.current_language;
	v_return       VARCHAR2(10)		:='T';
	v_nls_lang     VARCHAR2(100);
	v_org_id       NUMBER		 	:= 81;

/* Cursor to get the user id information based on the input user name */
CURSOR cur_user
IS
   SELECT user_id
   FROM fnd_user
   WHERE user_name = :i_user_name;
/* Cursor to get the responsibility information */
CURSOR cur_resp
IS
    SELECT responsibility_id
          ,application_id
          ,language
    FROM fnd_responsibility_tl
    WHERE responsibility_name = :i_resp_name;
/* Cursor to get the nls language information for setting the language context */
CURSOR cur_lang(p_lang_code VARCHAR2)
IS
    SELECT nls_language
    FROM fnd_languages
    WHERE language_code = p_lang_code;

BEGIN
     -- 1) Set the applications context
    mo_global.init('AR');
    mo_global.set_policy_context('S','81');
  

    /* To get the user id details */
    OPEN cur_user;
    FETCH cur_user INTO v_user_id;
    IF cur_user%NOTFOUND
    THEN
        v_return:='F';    
	END IF; --IF cur_user%NOTFOUND
    CLOSE cur_user;
	
    /* To get the responsibility and responsibility application id */
    OPEN cur_resp;
    FETCH cur_resp INTO v_resp_id, v_resp_appl_id,v_lang;
    IF cur_resp%NOTFOUND
    THEN
        v_return:='F';        
    END IF; --IF cur_resp%NOTFOUND
    CLOSE cur_resp; 
	
    /* Setting the oracle applications context for the particular session */
    fnd_global.apps_initialize ( 
								 user_id      => v_user_id
                                ,resp_id      => v_resp_id
                                ,resp_appl_id => v_resp_appl_id
							   );

    --fnd_global.apps_initialize(1011902, 50559, 222,0);


    AR_RECEIPT_API_PUB.create_and_apply( p_api_version 			=> 1.0,
										 p_init_msg_list 		=> FND_API.G_TRUE,
										 p_commit 				=> FND_API.G_TRUE,
										 p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
										 x_return_status 		=> l_return_status,
										 x_msg_count 			=> l_msg_count,
										 x_msg_data 			=> l_msg_data,
										 p_amount 				=> p_amount,
										 p_receipt_number 		=> p_receipt_number,
										 p_receipt_date 		=> p_receipt_date,
										 p_gl_date 				=> p_gl_date,
										 p_customer_number 		=> p_customer_number,
										 p_receipt_method_id 	=> 1001,
										 p_trx_number 			=> p_trx_number,
										 p_currency_code 		=> p_currency_code,
										 p_cr_id 				=> l_cash_receipt_id 
										);

    -- 3) Review the API output
    dbms_output.put_line('Status ' || l_return_status);
    dbms_output.put_line('Message count ' || l_msg_count);
    dbms_output.put_line('Cash Receipt ID ' || l_cash_receipt_id );

    if l_msg_count = 1 Then
       dbms_output.put_line('l_msg_data '|| l_msg_data);
    elsif l_msg_count > 1 Then
       loop
          p_count := p_count + 1;
          l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
          if l_msg_data is NULL Then
             exit;
          end if;
          dbms_output.put_line('Message ' || p_count ||'. '||l_msg_data);
       end loop;
    end if;
	return l_return_status;
END;
/