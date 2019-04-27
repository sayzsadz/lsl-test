   SELECT user_id
   FROM fnd_user
   WHERE user_name = 'SJAYASINGHE1';
    
   SELECT responsibility_id
         ,application_id
         ,language
		 ,responsibility_name
   FROM fnd_responsibility_tl
   WHERE responsibility_name = 'Purchasing Super User';
    
select *
from ar_trx_header_gt;

select *
from ar_trx_lines_gt;

select *
from ar_trx_errors_gt;

delete from ar_trx_header_gt;
delete from ar_trx_lines_gt;
delete from ar_trx_errors_gt;


select *
from ra_customer_trx_all
where trx_number = '10000057';

select *
from ar_cash_receipts_all
where RECEIPT_NUMBER = '';

/* Formatted on 2009/11/22 11:35 (Formatter Plus v4.8.0) */
SELECT a.cust_account_id customer_id, p.party_id,
       a.account_number customer_number, p.party_number registry_id,
       p.party_name customer_name, l.address1, l.address2, l.address3,
       l.address4, l.city, l.country, l.po_box_number, sa.cust_acct_site_id,
       su.site_use_id, su.site_use_code, l.location_id,
       su.LOCATION location_code, sa.org_id,
       t.territory_short_name country_name, t.description country_description,
       p.orig_system_reference, a.status cust_status,
       sa.status cust_site_status,
       NVL ((SELECT overall_credit_limit
               FROM hz_cust_profile_amts cl
              WHERE cl.cust_account_id = a.cust_account_id
                AND cl.site_use_id = su.site_use_id),
            0
           ) credit_limit,
       (SELECT tu.payment_term_id
          FROM hz_cust_site_uses_all tu
         WHERE tu.site_use_id = su.site_use_id) term_id,
       (SELECT tm.NAME
          FROM hz_cust_site_uses_all tu, ra_terms_vl tm
         WHERE tm.term_id = tu.payment_term_id
           AND tu.site_use_id = su.site_use_id) term_name,
       s.party_site_name, hcp.phone_area_code areacode,
       hcp.phone_country_code country_code,
       hcp.phone_extension phone_extension, hcp.phone_number telephone,
       hcp1.phone_country_code fax_country_code,
       hcp1.phone_area_code fax_areacode, hcp1.phone_number fax,
       hcp2.email_address email
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
	   and  a.cust_account_id=1040