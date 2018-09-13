DECLARE
   conn UTL_TCP.CONNECTION;
BEGIN
  conn := UTL_TCP.OPEN_CONNECTION(
  REMOTE_HOST => '203.208.66.244',
  REMOTE_PORT => 31258,
  CHARSET => 'US7ASCII');
  UTL_TCP.CLOSE_ALL_CONNECTIONS;
  UTL_TCP.CLOSE_CONNECTION (conn);  -- this line immediately following a call to UTL_TCP.CLOSE_ALL_CONNECTIONS generates the error!
EXCEPTION
 WHEN OTHERS THEN
   DBMS_OUTPUT.PUT_LINE ( SQLERRM );
 -- ensure connection is closed on exception
   UTL_TCP.CLOSE_CONNECTION (conn);
 END;

select utl_http.request ('https://203.208.66.244:31258/api/token',null,'file:/home/oraapex/wallet','Pa$$w0rd')
from dual;

select sys.utl_http.request(
                    url             =>'https://203.208.66.244:31258/api/token',
                    proxy           =>null,
                    wallet_path     =>'file:/home/oraapex/wallet',
                    wallet_password =>'Pa$$w0rd',
                    https_host      =>'203.208.66.244'
                  )
from dual;

EXEC DBMS_NETWORK_ACL_ADMIN.ASSIGN_WALLET_ACL('psbapos_acl.xml','file:/home/oraapex/wallet');

declare
    lv_check_file_exist boolean;
    lv_a number;
    lv_b number;
begin
    dbms_output.put_line ('test when file is available');
    utl_file.fgetattr ('CSV_PATH', 'test.txt', lv_check_file_exist, lv_a, lv_b );
if lv_check_file_exist then
dbms_output.put_line('file exists');
end if;
if not lv_check_file_exist then
dbms_output.put_line('file does not exist');
end if;
if lv_check_file_exist is null then
dbms_output.put_line('file check null');
end if;
if lv_check_file_exist is not null then
dbms_output.put_line('file check not null');
end if;
dbms_output.put_line('lv_a-->'||lv_a);
dbms_output.put_line('lv_b-->'||lv_b);
end;


SELECT DBMS_LOB.FILEEXISTS(BFILENAME('WALLET_PATH', 'ewallet.p12')) from dual;