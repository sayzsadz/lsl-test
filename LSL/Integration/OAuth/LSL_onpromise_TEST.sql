select *
from xxpbsa_sup_stg;

select *
from xxpbsa_sup_site_stg;

alter table xxpbsa_sup_site_stg add VENDOR_NAME VARCHAR2(100);

select *
from xxpbsa_sup_con_stg;

create table xxpbsa_sup_stg
as
select SEGMENT1 
      ,VENDOR_NAME
      ,PAY_GROUP_LOOKUP_CODE
      ,' testing ...'TERMS_NAME
      ,'N' AUTO_TAX_CALC_FLAG
from AP_SUPPLIERS
where rownum < 2;

select *
from AP_SUPPLIERS;
                           
alter table xxpbsa_sup_stg add STATUS VARCHAR2(10);
alter table xxpbsa_sup_stg add ERROR_CODE VARCHAR2(1000);

create table xxpbsa_sup_site_stg
as
select 'testing ....' VENDOR_NAME
      ,COUNTRY
      ,ADDRESS_LINE1
      ,ADDRESS_LINE2
      ,ADDRESS_LINE3
from AP_SUPPLIER_SITES_ALL
where rownum < 2;

alter table xxpbsa_sup_site_stg add STATUS VARCHAR2(10);
alter table xxpbsa_sup_site_stg add ERROR_CODE VARCHAR2(1000);

create table xxpbsa_sup_con_stg
as
select  'testing ....' VENDOR_NAME
       ,FIRST_NAME
       ,PHONE
       ,FAX
from AP_SUPPLIER_CONTACTS
where rownum < 2;

alter table xxpbsa_sup_con_stg add STATUS VARCHAR2(10);
alter table xxpbsa_sup_con_stg add ERROR_CODE VARCHAR2(1000);
