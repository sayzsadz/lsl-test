create or replace procedure xxpbsa_request_pbsapos_data AS
  l_clob         clob;
  --l_site_name    varchar2(50) := 'http://104.197.10.182/ap1/api/v1/sales/summary';
  --l_username     varchar2(50) := 'ck_o3vuhza8bgmvu5lxronckr2favaxeiolh3izb';
  --l_password     varchar2(50) := 'cs_6bhldx7owbxrcmuo5ajcb7rql9mb0hglqrp97';
  --l_basic_base64 varchar2(2000);
  --l_buffer       varchar2(32767);
  --l_amount       number;
  --l_offset       number;
begin
  --l_basic_base64 := replace(utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(l_site_name||'\'||l_username||':'||l_password))),chr(13)||chr(10),'');
  apex_web_service.g_request_headers(1).name    := 'User-Agent';
  apex_web_service.g_request_headers(1).value   := 'Mozilla';
  apex_web_service.g_request_headers(2).name    := 'Authorization';
  apex_web_service.g_request_headers(2).value   := 'Bearer AQAAANCMnd8BFdERjHoAwE_Cl-sBAAAARGbmhUmZzUWLe6F129xEjgAAAAACAAAAAAAQZgAAAAEAACAAAAAKEs8tGvw_zUxf4w7taVNFmplf2SbiqFdEMf8DXMOcrAAAAAAOgAAAAAIAACAAAACFhHlJsrgfd4LC24darSsYPQbSd9lhZe3hfKKfexlTaeAAAAB3GEu5lfC9oU878LY6xBnDzd5HQSqkEeixystmXPw5F02aCdySAHFpT6HV_XtbXb8ghYk12pk0broTWSmN2HUHIuvHnwUzb7OKZc9UMBrFtWuTSYXz9i07bjOuzZjVLjsWQB1PYxGaELhLYe6imDUoHw-eqHTeeajLnD1db-reZhtOsWiRlB4kO_xra60udAyCuqwryZpULAT1COtpPDqLqjyNAGwlN5n0HAG50jqDT_zwqv2LgmmBuhGHcGpaA8ZGxMyROdfLpCWZExP6w_8WeCDKbMImzEfiWkNjsPeU_UAAAAA98n7PDBEdoLnNcmsc_kVCaa8RkH17fc7CnYNVPXlD0g6GFi4-IlNXbTgFsu9iw6ZqoQ2C9G0IShkFA7eODC_f';

  -- Invoke the PBSA web service to retrieve data
  l_clob := apex_web_service.make_rest_request( p_url => 'https://203.208.66.244:31258/api/token', 
                                                p_http_method => 'POST' 
                                                --p_wallet_path => 'file:d:\eloqua_wallet',
                                                --p_wallet_pwd => '123222>' 
                                              );
  
  l_amount := 32000;
  l_offset := 1;
  
  dbms_output.put_line('aaa');
  
  begin
    loop
      dbms_lob.read( l_clob, l_amount, l_offset, l_buffer );
      dbms_output.put_line(l_buffer);
      l_offset := l_offset + l_amount;
      l_amount := 32000;
    end loop;
  exception
    when OTHERS then
      dbms_output.put_line(SQLERRM);
  end;
end;