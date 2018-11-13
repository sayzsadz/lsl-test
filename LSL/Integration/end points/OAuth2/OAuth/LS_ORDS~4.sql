drop table j_nls;
drop table j_nls_test;

CREATE TABLE j_nls(
  id          NUMBER(10),
  jsondoc     CLOB CONSTRAINT ensure_json CHECK (jsondoc IS JSON)
);

CREATE TABLE j_nls_test(
  id            varchar2(20),
  j_id          varchar2(20),
  j_description varchar2(20),
  j_decimal     varchar2(20)
);

INSERT INTO j_nls VALUES(
160000,
'{ "IDNumber"      : 160000,
   "Description"   : "Just a wide ID",
   "DecimalNumber" : 160000}'
);

INSERT INTO j_nls VALUES(
1601,
'{ "IDNumber"      : 1601,
   "Description"   : "Simple Integer",
   "DecimalNumber" : 1601}'
);

INSERT INTO j_nls VALUES(
1602,
'{ "IDNumber"      : 1602,
   "Description"   : "One decimal",
   "DecimalNumber" : 1602.1}'
);

INSERT INTO j_nls VALUES(
1603,
'{ "IDNumber"      : 1603,
   "Description"   : "Three decimals",
   "DecimalNumber" : 1603.123}'
);

COMMIT;
select *
from j_nls_test;

declare
p_data clob := '[{"date":"2018-06-04T00:00:00","products":[{"saleSummaryID":1,"date":"2018-06-04T00:00:00","productId":"d06bd7ed-6fe1-4a36-9050-d49d36966b71","partNumber":"000001","title":"Product One","avgCostEx":4.5455,"avgCostTax":0.4546,"unit":"Each","totalUnits":1.000,"totalValueEx":18.1800,"totalValueTax":1.8200}]}]';
begin
insert into j_nls_test (
 id            ,
  j_id          ,
  j_description ,
  j_decimal     
)
SELECT *
FROM json_table(
'[{"date":"2018-06-04T00:00:00","products":[{"saleSummaryID":1,"date":"2018-06-04T00:00:00","productId":"d06bd7ed-6fe1-4a36-9050-d49d36966b71","partNumber":"000001","title":"Product One","avgCostEx":4.5455,"avgCostTax":0.4546,"unit":"Each","totalUnits":1.000,"totalValueEx":18.1800,"totalValueTax":1.8200}]}]' 
,  
        '$' COLUMNS (
         date VARCHAR2(20) PATH '$.date')
     )) jt;
     
end;     
    
SELECT *
FROM json_table('{"date":"01-02-2018","products":{ "IDNumber"      : 1602,
   "Description"   : "One decimal",
   "DecimalNumber" : 1602.1}}', 
   '$.products' COLUMNS (
          j_IDNumber    varchar2(300 char) path '$.IDNumber'
 ,
          J_DECIMAL VARCHAR2(300 CHAR) PATH '$.DecimalNumber')
     ) jt;    
     
     ,
          '$.products' COLUMNS (
          J_DECIMAL VARCHAR2(300 CHAR) PATH '$.DecimalNumber')
     
     ,
          '$.' COLUMNS (
          j_date    varchar2(300 char) path '$.date'
          )

     select *
     from j_nls;
     
     ;
     
SELECT *
FROM 
     JSON_TABLE(
     '[{"date":"01-02-2018","test":[{"one":1,"two":2}],"products":[{ "IDNumber"      : 1602,
   "Description"   : "One decimal",
   "DecimalNumber" : 1602.1}]}]'
     , '$[*]' COLUMNS (
       "Message" PATH '$.date',
NESTED PATH '$.products[*]' COLUMNS (
         "Author_l"
VARCHAR2(20) PATH '$.IDNumber'
,
"Author_lc"
VARCHAR2(20) PATH '$.Description'
)

)) "JT";