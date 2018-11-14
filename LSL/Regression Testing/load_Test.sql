select REGEXP_SUBSTR(replace(URL,'https://',''),
                '([[:alnum:]]+\.?){3,4}/?') ip_address--, store_id
from xxpbsa_oauth
where store_id !=0
order by store_id;
  
  update xxpbsa_oauth
  set wallet_path = wallet_path||store_id
  where access_token is null;
  
  update xxpbsa_oauth
  set access_token = null;
  
  select distinct CLIENT_ID, CLIENT_SECRET, URL
  from xxpbsa_oauth
  where access_token is null;