create table XXPBSA_ACCOUNT_COMBINATIONS (CODE VARCHAR2(2000));

create or replace function xxpbsa_create_ccid 
( p_concat_segs in varchar2
) return varchar2
is
  -- pragma autonomous_transaction; -- if you need autonomy!
  l_keyval_status     BOOLEAN;
  l_coa_id            NUMBER;
   l_err_msg          varchar2(2000);
   l_error varchar2(255);
begin
  begin
    select chart_of_accounts_id
    into   l_coa_id
    from   gl_sets_of_books
    where  set_of_books_id = fnd_profile.value('GL_SET_OF_BKS_ID');
  exception
    when no_data_found then
      dbms_output.put_line('Chart of Accounts ID not found from profile option GL_SET_OF_BKS_ID');
      dbms_output.put_line('Try setting up your environment with fnd_global.apps_initialize');
      raise;
  end;
  -- keyval_mode can be one of CREATE_COMBINATION CHECK_COMBINATION FIND_COMBINATION
  --create will only work if dynamic inserts on and cross validation rules not broken
  l_keyval_status := fnd_flex_keyval.validate_segs(
                                           'CHECK_COMBINATION',
                                           'SQLGL',
                                           'GL#',
                                           l_coa_id,
                                           p_concat_segs,
                                           'V',
                                           sysdate,
                                           'ALL', NULL, NULL, NULL, NULL,
                                           FALSE,FALSE, NULL, NULL, NULL);
                                
  if l_keyval_status then  
    return 'S';   
  else
   --return l_error;
    l_err_msg:=substr(fnd_flex_keyval.error_message, 1, 240);     --fnd_message.get;
    
    l_error := substr(fnd_flex_keyval.error_message, 1, 240); 
   dbms_output.put_line(l_error); 
   dbms_output.put_line('ERROR SEGMENT :');
   l_error := to_char(fnd_flex_keyval.error_segment);
   dbms_output.put_line(l_error); 
   dbms_output.put_line('ERROR ENCODED :');
   l_error := substr(fnd_flex_keyval.encoded_error_message, 1, 240);
   dbms_output.put_line(l_error); 
   dbms_output.put_line('FALSE'); 

    dbms_output.put_line(l_err_msg||substr(sqlerrm,150,3));
    return l_error;
  end if;
end XXPBSA_CREATE_CCID;
/

CREATE TABLE XXPBSA_COMB_ERROR_STATUS
(
  CODE    VARCHAR2(2000 BYTE),
  STATUS  VARCHAR2(2000 BYTE)
);
/
CREATE OR REPLACE procedure XXPBSA_CREATE_GL_ACC_COMB
IS
V_COMBINATION VARCHAR2(240);
CURSOR C1 IS
SELECT DISTINCT CODE 
FROM   XXPBSA_ACCOUNT_COMBINATIONS
;
--where   rownum=1;

begin

FOR I IN C1 LOOP

select xxpbsa_create_ccid(I.CODE) into V_COMBINATION  from dual;

dbms_output.put_line (V_COMBINATION);

insert into XXPBSA_COMB_ERROR_STATUS (code,status) values (i.code,v_combination);

END LOOP;


end;
/