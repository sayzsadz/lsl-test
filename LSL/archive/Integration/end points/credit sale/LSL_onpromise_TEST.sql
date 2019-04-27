FUNCTION xxlsl_set_context( 
					  i_user_name  	IN  VARCHAR2
                     ,i_resp_name   IN  VARCHAR2
                     ,i_org_id      IN  NUMBER
) RETURN VARCHAR2
IS
v_user_id      NUMBER;
v_resp_id      NUMBER;
v_resp_appl_id NUMBER;
v_lang         VARCHAR2(100);
v_session_lang VARCHAR2(100):= fnd_global.current_language;
v_return       VARCHAR2(10)	:= 'T';
v_nls_lang     VARCHAR2(100);
v_org_id       NUMBER		:= i_org_id;

/* Cursor to get the user id information based on the input user name */
CURSOR cur_user
IS
   SELECT user_id
   FROM fnd_user
   WHERE user_name = i_user_name;
/* Cursor to get the responsibility information */
CURSOR cur_resp
IS
    SELECT responsibility_id
          ,application_id
          ,language
    FROM fnd_responsibility_tl
    WHERE responsibility_name = i_resp_name;
/* Cursor to get the nls language information for setting the language context */
CURSOR cur_lang(p_lang_code VARCHAR2)
IS
    SELECT nls_language
    FROM fnd_languages
    WHERE language_code = p_lang_code;
BEGIN
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
    fnd_global.apps_initialize ( user_id      => v_user_id
                                ,resp_id      => v_resp_id
                                ,resp_appl_id => v_resp_appl_id);
    /* Setting the org context for the particular session */
    mo_global.set_policy_context('S',v_org_id);
    /* setting the nls context for the particular session */
    IF v_session_lang != v_lang
    THEN
        OPEN cur_lang(v_lang);
        FETCH cur_lang INTO v_nls_lang;
        CLOSE cur_lang;
        fnd_global.set_nls_context(v_nls_lang);
    END IF; --IF v_session_lang != v_lang
  RETURN v_return;
EXCEPTION
WHEN OTHERS THEN
    RETURN 'F';
END set_context;


create or replace function xxlsl_ar_inv(p_cust varchar2, p_description varchar2, P_CODE_COMBINATION_ID number, p_amount number, p_qty varchar2)
return varchar2

	l_return_status 	varchar2(1);
	p_count  			NUMBER;
	l_msg_count 		number;
	l_msg_data 			varchar2(2000);
	l_batch_id 			number;
	l_cnt 				number := 0;
	l_customer_trx_id 	number;
	cnt 				number; 
	v_context 			varchar2(100);

	l_batch_source_rec 		ar_invoice_api_pub.batch_source_rec_type;
	l_trx_header_tbl 		ar_invoice_api_pub.trx_header_tbl_type;
	l_trx_lines_tbl 		ar_invoice_api_pub.trx_line_tbl_type;
	l_trx_dist_tbl 			ar_invoice_api_pub.trx_dist_tbl_type;
	l_trx_salescredits_tbl 	ar_invoice_api_pub.trx_salescredits_tbl_type;




BEGIN
 
DBMS_OUTPUT.PUT_LINE('1');
--1. Set applications context if not already set.
	BEGIN
	v_context := set_context('&username','&responsiblity_name',&org_id);
	IF v_context = 'F'
		THEN
			DBMS_OUTPUT.PUT_LINE('Error while setting the context');        
		END IF;
	DBMS_OUTPUT.PUT_LINE('2');
	exception
	when others then
	dbms_output.put_line('Error in Crea_cm:'||sqlerrm);
	end;
	
	select trx_header_seq.nextval
	into v_trx_header_id
	from dual;
	
	select trx_line_seq.nextval
	into v_trx_line_id
	from dual;
	
	select trx_dist_seq.nextval
	into v_trx_dist_id
	from dual;
	
	--v_trx_header_id = 102
	--v_trx_line_id = 101
	--v_trx_dist_id = 1021
	
	

	-- Populate header information.
	l_trx_header_tbl(1).trx_header_id := v_trx_header_id;
	--l_trx_header_tbl(1).trx_number := 'Test_inv';--The transaction number is populated when automatic transaction numbering is selected on the transaction batch source.
	l_trx_header_tbl(1).bill_to_customer_id := p_cust;
	l_trx_header_tbl(1).cust_trx_type_id := 1;
	l_trx_header_tbl(1).primary_salesrep_id := -3;
	-- Populate batch source information.
	l_batch_source_rec.batch_source_id := 1001;
	-- Populate line 1 information.
	l_trx_lines_tbl(1).trx_header_id := v_trx_header_id;
	l_trx_lines_tbl(1).trx_line_id := v_trx_line_id;
	l_trx_lines_tbl(1).line_number := 1;
	l_trx_lines_tbl(1).description := p_description;
	l_trx_lines_tbl(1).quantity_invoiced := p_qty;
	l_trx_lines_tbl(1).unit_selling_price := (p_amount/p_qty);
	l_trx_lines_tbl(1).uom_code := 'ECH';
	l_trx_lines_tbl(1).line_type := 'LINE';
	l_trx_lines_tbl(1).taxable_flag := 'N';
	-- Populate Distribution Information
	l_trx_dist_tbl(1).trx_dist_id := v_trx_dist_id;
	l_trx_dist_tbl(1).trx_header_id := v_trx_header_id;
	l_trx_dist_tbl(1).trx_LINE_ID := v_trx_line_id;
	l_trx_dist_tbl(1).ACCOUNT_CLASS := 'REV';
	l_trx_dist_tbl(1).percent     := 100;
	l_trx_dist_tbl(1).AMOUNT := p_amount;
	l_trx_dist_tbl(1).CODE_COMBINATION_ID := P_CODE_COMBINATION_ID;
	
	-- CAll the api
		AR_INVOICE_API_PUB.create_single_invoice(
													p_api_version 			=> 1.0,
													p_batch_source_rec 		=> l_batch_source_rec,
													p_trx_header_tbl 		=> l_trx_header_tbl,
													p_trx_lines_tbl 		=> l_trx_lines_tbl,
													p_trx_dist_tbl 			=> l_trx_dist_tbl,
													p_trx_salescredits_tbl 	=> l_trx_salescredits_tbl,
													x_customer_trx_id 		=> l_customer_trx_id,
													x_return_status 		=> l_return_status,
													x_msg_count 			=> l_msg_count,
													x_msg_data 				=> l_msg_data
												); 

	DBMS_OUTPUT.PUT_LINE('l_return_status : '||l_return_status);

	IF l_return_status = 'S' THEN
	dbms_output.put_line('unexpected errors found!'); 
	 IF l_msg_count = 1 Then
		  dbms_output.put_line('l_msg_data '||l_msg_data);
	   ELSIF l_msg_count > 1 Then
	   LOOP
		 p_count := p_count+1;
		 l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
		 IF l_msg_data is NULL Then
		 EXIT;
		 END IF;
		 dbms_output.put_line('Message' || p_count ||'.'||l_msg_data);
	   END LOOP;
	   END IF;
	ELSE
	dbms_output.put_line(' Got Created Sucessfully : '||l_customer_trx_id);
	END IF;
	return l_customer_trx_id;
END;

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

create or replace procedure xxlsl_execute
as
	v_status	varchar2(50);
	v_status1	varchar2(5);
	
	cursor c1
	is		
	  select cust_name, details, qty, amt , bal
	  from demo_emp
	  where status = 'NP';
	  
begin
  for c1 in cur_rec
  loop
	
  select code_combination_id
  into P_CODE_COMBINATION_ID
  from gl_code_combinations
  where segment6 = '123456'

  SELECT a.cust_account_id, a.account_number
  into p_cust, p_cust_num
  FROM hz_locations l,
       hz_party_sites s,
       hz_parties p,
       hz_cust_accounts a,
       hz_cust_acct_sites_all sa,
       hz_cust_site_uses_all su,
       fnd_territories_vl t,
       hz_contact_points hcp,
       hz_contact_points hcp1,
       hz_contact_points hcp2
 WHERE l.location_id = s.location_id
	   AND s.party_id = p.party_id
	   AND a.party_id = p.party_id
	   AND sa.cust_account_id = a.cust_account_id
	   AND sa.party_site_id = s.party_site_id
	   AND sa.cust_acct_site_id = su.cust_acct_site_id
	   AND t.territory_code = l.country
	   AND a.status = 'A'
	   AND sa.status = 'A'
	   AND p.party_id = hcp.owner_table_id(+)
	   AND hcp.owner_table_name(+) = 'HZ_PARTIES'
	   AND hcp.contact_point_type(+) = 'PHONE'
	   AND hcp.phone_line_type(+) = 'GEN'
	   AND p.party_id = hcp1.owner_table_id(+)
	   AND hcp1.owner_table_name(+) = 'HZ_PARTIES'
	   AND hcp1.contact_point_type(+) = 'PHONE'
	   AND hcp1.phone_line_type(+) = 'FAX'
	   AND p.party_id = hcp2.owner_table_id(+)
	   AND hcp2.owner_table_name(+) = 'HZ_PARTIES'
	   AND hcp2.contact_point_type(+) = 'EMAIL'
	   AND p.party_name = cur_rec.cust_name

		v_status := xxlsl_ar_inv(p_cust => p_cust, p_description => cur_rec.details, P_CODE_COMBINATION_ID => P_CODE_COMBINATION_ID, p_amount => cur_rec.amt, p_qty => cur_rec.qty);
		dbms_output.put_line(v_status);
		
		select trx_date, gl_date, trx_number
		into p_trx_date, p_gl_date, p_trx_number
		from ra_cuat_trx_all
		where cust_trx_id = v_status;
		
		v_status1 := xxlsl_apply_recipt(
										 p_amount 				=> cur_rec.amt - cur_rec.bal ,
										 p_receipt_number 		=> 'RCP'||v_status,
										 p_receipt_date 		=> p_trx_date,
										 p_gl_date 				=> p_gl_date,
										 p_customer_number 		=> p_cust_num,
										 p_receipt_method_id 	=> 1001,
										 p_trx_number 			=> p_trx_number,
										 p_currency_code 		=> 'LKR'
										);
		
	end loop;
end;