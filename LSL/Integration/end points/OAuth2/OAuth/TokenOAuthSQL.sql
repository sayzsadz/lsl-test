create or replace PROCEDURE xxpbsa_request_token
AS
  l_clob    CLOB;
  l_result  VARCHAR2(32767);
BEGIN
  
  -- Request grants for username and password
  -- Get the token from the web service.
  l_clob := APEX_WEB_SERVICE.make_rest_request( p_url         => 'http://104.197.10.182/ap1/api/token',
                                                p_http_method => 'POST',
                                                p_body        => 'grant_type=password'||'&'||'username=ck_2kh7x79yhyz759njnorad3qmradn7oeljdavj'||'&'||'password=cs_fpnmhhsna6xj9jzrmipd8i9l9hw7viy5kjzco'
                                              );

  -- Display the token returned.
  DBMS_OUTPUT.put_line('l_clob=' || l_clob);

END;