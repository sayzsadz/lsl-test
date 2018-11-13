CREATE OR REPLACE PROCEDURE XXPBSA_JE_INTERFACE_SALES_SUM(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2) 
IS

    l_segment4      varchar2(20);
    l_segment6      varchar2(20);
    l_code          varchar2(500);
    l_segment2      varchar2(20);
    l_batch_name    varchar2(100);
    


cursor cur
is
select LEDGER_ID,
  STATUS,
  SET_OF_BOOKS_ID,
  USER_JE_SOURCE_NAME,
  USER_JE_CATEGORY_NAME,
  ACCOUNTING_DATE,
  CURRENCY_CODE,
  DATE_CREATED,
  CREATED_BY,
  ACTUAL_FLAG,
  USER_CURRENCY_CONVERSION_TYPE,
  CURRENCY_CONVERSION_DATE,
  CURRENCY_CONVERSION_RATE,
  SEGMENT1,
  SEGMENT2,
  SEGMENT3,
  SEGMENT4,
  SEGMENT5,
  SEGMENT6,
  SEGMENT7,
  SEGMENT8,
  SEGMENT9,
SUM(ENTERED_DR) ENTERED_DR,
  SUM(ENTERED_CR) ENTERED_CR,
  SUM(ACCOUNTED_DR) ACCOUNTED_DR,
  SUM(ACCOUNTED_CR) ACCOUNTED_CR,
    PERIOD_NAME,
  REFERENCE1,
  REFERENCE2,
  'TEST JOURNAL SALES' REFERENCE4,
  REFERENCE5
from
(
SELECT LEDGER_ID,
  STATUS,
  SET_OF_BOOKS_ID,
  USER_JE_SOURCE_NAME,
  USER_JE_CATEGORY_NAME,
  ACCOUNTING_DATE,
  CURRENCY_CODE,
  DATE_CREATED,
  CREATED_BY,
  ACTUAL_FLAG,
  USER_CURRENCY_CONVERSION_TYPE,
  CURRENCY_CONVERSION_DATE,
  CURRENCY_CONVERSION_RATE,
  SEGMENT1,
  SEGMENT2,
  SEGMENT3,
  SEGMENT4,
  SEGMENT5,
  SEGMENT6,
  SEGMENT7,
  SEGMENT8,
  SEGMENT9,
  ENTERED_DR,
  ENTERED_CR,
  ACCOUNTED_DR,
  ACCOUNTED_CR,
--(
--  CASE 
--  WHEN                 segment1
--                ||'.'||segment2
--                ||'.'||segment3
--                ||'.'||segment4
--                ||'.'||segment5
--                ||'.'||segment6
--                ||'.'||segment7
--                ||'.'||segment8
--                ||'.'||segment9 = XXPBSA_GET_GL_ACCOUNT('Lanka Sathosa Ltd.Head Office.Unspecified.Unspecified.Unspecified.Sales And Payment Control.Unspecified.Unspecified') THEN
--    ENTERED_DR
--  ELSE 0
--  END) ENTERED_DR ,
--(
--  CASE 
--  WHEN                 segment1
--                ||'.'||segment2
--                ||'.'||segment3
--                ||'.'||segment4
--                ||'.'||segment5
--                ||'.'||segment6
--                ||'.'||segment7
--                ||'.'||segment8
--                ||'.'||segment9 = XXPBSA_GET_GL_ACCOUNT('Lanka Sathosa Ltd.Head Office.Unspecified.Unspecified.Unspecified.Sales And Payment Control.Unspecified.Unspecified') THEN
--    0
--  ELSE ENTERED_CR
--  END) ENTERED_CR,
--(
--  CASE 
--  WHEN                 segment1
--                ||'.'||segment2
--                ||'.'||segment3
--                ||'.'||segment4
--                ||'.'||segment5
--                ||'.'||segment6
--                ||'.'||segment7
--                ||'.'||segment8
--                ||'.'||segment9 = XXPBSA_GET_GL_ACCOUNT('Lanka Sathosa Ltd.Head Office.Unspecified.Unspecified.Unspecified.Sales And Payment Control.Unspecified.Unspecified') THEN
--    ACCOUNTED_DR
--  ELSE 0
--  END) ACCOUNTED_DR,
--(
--  CASE 
--  WHEN                 segment1
--                ||'.'||segment2
--                ||'.'||segment3
--                ||'.'||segment4
--                ||'.'||segment5
--                ||'.'||segment6
--                ||'.'||segment7
--                ||'.'||segment8
--                ||'.'||segment9 = XXPBSA_GET_GL_ACCOUNT('Lanka Sathosa Ltd.Head Office.Unspecified.Unspecified.Unspecified.Sales And Payment Control.Unspecified.Unspecified') THEN
--    0
--  ELSE ACCOUNTED_CR
--  END) ACCOUNTED_CR,
  PERIOD_NAME,
  REFERENCE1,
  REFERENCE2,
  REFERENCE4,
  REFERENCE5
FROM
  (
  (select SALESUMMARYID,
  LEDGER_ID,
  STATUS,
  SET_OF_BOOKS_ID,
  USER_JE_SOURCE_NAME,
  USER_JE_CATEGORY_NAME,
  ACCOUNTING_DATE,
  CURRENCY_CODE,
  DATE_CREATED,
  CREATED_BY,
  ACTUAL_FLAG,
  USER_CURRENCY_CONVERSION_TYPE,
  CURRENCY_CONVERSION_DATE,
  CURRENCY_CONVERSION_RATE,
  SEGMENT1,
  SEGMENT2,
  SEGMENT3,
  SEGMENT4,
  SEGMENT5,
  SEGMENT6,
  SEGMENT7,
  SEGMENT8,
  SEGMENT9,
  SUM(ENTERED_DR) ENTERED_DR,
  SUM(ENTERED_CR) ENTERED_CR,
  SUM(ACCOUNTED_DR) ACCOUNTED_DR,
  SUM(ACCOUNTED_CR) ACCOUNTED_CR,
  PERIOD_NAME,
  REFERENCE1,
  REFERENCE2,
  REFERENCE4,
  REFERENCE5
  from
  (SELECT DISTINCT ss.SALESUMMARYID,
    2021 LEDGER_ID,     --  SELECT * FROM GL_SETS_OF_BOOKS
    'Y' STATUS,                         --  i.STATUS
    2021 SET_OF_BOOKS_ID,               --  SELECT * FROM GL_SETS_OF_BOOKS      (Trading Companies SOB)
    'Manual' USER_JE_SOURCE_NAME,       --  SELECT * FROM GL_JE_SOURCES WHERE JE_SOURCE_NAME LIKE 'Manual'
    'Adjustment' USER_JE_CATEGORY_NAME, --  SELECT USER_JE_CATEGORY_NAME FROM GL_JE_CATEGORIES WHERE USER_JE_CATEGORY_NAME LIKE 'SSE%'
    sysdate ACCOUNTING_DATE, --ss.SALES_DATE ACCOUNTING_DATE,      --  i.ACCOUNTING_DATE
    'LKR' CURRENCY_CODE,                --  i.CURRENCY_CODE
    sysdate DATE_CREATED,--ss.SALES_DATE DATE_CREATED,         --  DATE_CREATED
    0 CREATED_BY,                       --  fnd_global.user_id
    'A' ACTUAL_FLAG,                    --  i.ACTUAL_FLAG    -- A  Actual , B – Budget E – Encumbrance
    --  i.ENCUMBRANCE_TYPE_ID       ,
    --  i.BUDGET_VERSION_ID         ,
    '' USER_CURRENCY_CONVERSION_TYPE,    --  i.USER_CURRENCY_CONVERSION_TYPE
    '' CURRENCY_CONVERSION_DATE,         --  i.CURRENCY_CONVERSION_DATE
    '' CURRENCY_CONVERSION_RATE,         --  i.CURRENCY_CONVERSION_RATE
    '11' SEGMENT1,                       --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT1 = 02
    '11000' SEGMENT2 ,                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT2 = 01
    '00' SEGMENT3,                       --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT3 = 01
    gl.segment4 SEGMENT4 ,                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT4 = 05
    '000' SEGMENT5,                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT5 = 00
    gl.segment6 SEGMENT6,                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00
    '00000' SEGMENT7,                    --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01
    '000' SEGMENT8,                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100
    '000' SEGMENT9,                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00
    0 ENTERED_DR ,        --  i.ENTERED_DR
    SSP.TOTALVALUEEX ENTERED_CR ,        --  i.ENTERED_CR
    0 ACCOUNTED_DR ,      --  i.ACCOUNTED_DR
    SSP.TOTALVALUEEX ACCOUNTED_CR ,      --  i.ACCOUNTED_CR
    XXPBSA_GL_CURR_OPERIOD PERIOD_NAME , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )
    SYSDATE REFERENCE1 ,                 --  i.REFERENCE1
    SSP.TITLE REFERENCE2,                --  i.REFERENCE2
    'SALES' REFERENCE4 ,                --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  )
    ssp.PARTNUMBER REFERENCE5            --  i.REFERENCE5
  FROM SALESSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ss ,
    SALESSUMMARYPRODUCT@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ssp,
    (SELECT distinct gcc.segment4
     , gcc.segment6
     ,msi.segment1 item_segment1
     ,mc.segment1
FROM  mtl_item_categories mic,
      mtl_category_sets_tl mcst,
      mtl_category_sets_b mcs,
      mtl_categories_b_kfv mc,
      mtl_system_items_b msi,
      GL_CODE_COMBINATIONS gcc
WHERE mic.category_set_id = mcs.category_set_id
      AND mcs.category_set_id   = mcst.category_set_id
      AND mcst.LANGUAGE         = USERENV ('LANG')
      AND mic.category_id       = mc.category_id     
      AND msi.organization_id = mic.organization_id    
      AND msi.inventory_item_id = mic.inventory_item_id
      --AND UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))) like '%Sales%'
      AND REPLACE(UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))), 'SALES - LIQUOR', 'SALES - LIQUOR ' || q'[&]' || ' TOBACCO') like UPPER('%'||mc.segment1||'%')
      AND UPPER('%'||mc.segment4||'%') like (CASE WHEN mc.segment1 like '%GROCERY%' then UPPER(DECODE(gcc.segment4,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,4,gcc.segment4))) else mc.segment4 end)
      AND gcc.end_date_active is null
      ) gl
  WHERE ss.SALESUMMARYID = ssp.SALESUMMARYID
        AND gl.item_segment1(+) = ssp.partnumber
        AND ss.status_flag is null
        
  )
  group by SALESUMMARYID,
  LEDGER_ID,
  STATUS,
  SET_OF_BOOKS_ID,
  USER_JE_SOURCE_NAME,
  USER_JE_CATEGORY_NAME,
  ACCOUNTING_DATE,
  CURRENCY_CODE,
  DATE_CREATED,
  CREATED_BY,
  ACTUAL_FLAG,
  USER_CURRENCY_CONVERSION_TYPE,
  CURRENCY_CONVERSION_DATE,
  CURRENCY_CONVERSION_RATE,
  SEGMENT1,
  SEGMENT2,
  SEGMENT3,
  SEGMENT4,
  SEGMENT5,
  SEGMENT6,
  SEGMENT7,
  SEGMENT8,
  SEGMENT9,
  PERIOD_NAME,
  REFERENCE1,
  REFERENCE2,
  REFERENCE4,
  REFERENCE5) 
  UNION ALL
  (SELECT SALESUMMARYID,
  LEDGER_ID,
  STATUS,
  SET_OF_BOOKS_ID,
  USER_JE_SOURCE_NAME,
  USER_JE_CATEGORY_NAME,
  ACCOUNTING_DATE,
  CURRENCY_CODE,
  DATE_CREATED,
  CREATED_BY,
  ACTUAL_FLAG,
  USER_CURRENCY_CONVERSION_TYPE,
  CURRENCY_CONVERSION_DATE,
  CURRENCY_CONVERSION_RATE,
  SEGMENT1,
  SEGMENT2,
  SEGMENT3,
  SEGMENT4,
  SEGMENT5,
  SEGMENT6,
  SEGMENT7,
  SEGMENT8,
  SEGMENT9,
  SUM(ENTERED_DR) ENTERED_DR,
  SUM(ENTERED_CR) ENTERED_CR,
  SUM(ACCOUNTED_DR) ACCOUNTED_DR,
  SUM(ACCOUNTED_CR) ACCOUNTED_CR,
  PERIOD_NAME,
  REFERENCE1,
  REFERENCE2,
  REFERENCE4,
  REFERENCE5
FROM
  ( SELECT DISTINCT '0' SALESUMMARYID,
    2021 LEDGER_ID,                     --  SELECT * FROM GL_SETS_OF_BOOKS
    'Y' STATUS,                         --  i.STATUS
    2021 SET_OF_BOOKS_ID,               --  SELECT * FROM GL_SETS_OF_BOOKS      (Trading Companies SOB)
    'Manual' USER_JE_SOURCE_NAME,       --  SELECT * FROM GL_JE_SOURCES WHERE JE_SOURCE_NAME LIKE 'Manual'
    'Adjustment' USER_JE_CATEGORY_NAME, --  SELECT USER_JE_CATEGORY_NAME FROM GL_JE_CATEGORIES WHERE USER_JE_CATEGORY_NAME LIKE 'SSE%'
    sysdate ACCOUNTING_DATE,            --ss.SALES_DATE ACCOUNTING_DATE,      --  i.ACCOUNTING_DATE
    'LKR' CURRENCY_CODE,                --  i.CURRENCY_CODE
    sysdate DATE_CREATED,               --ss.SALES_DATE DATE_CREATED,         --  DATE_CREATED
    0 CREATED_BY,                       --  fnd_global.user_id
    'A' ACTUAL_FLAG,                    --  i.ACTUAL_FLAG    -- A  Actual , B – Budget E – Encumbrance
    --  i.ENCUMBRANCE_TYPE_ID       ,
    --  i.BUDGET_VERSION_ID         ,
    '' USER_CURRENCY_CONVERSION_TYPE,                   --  i.USER_CURRENCY_CONVERSION_TYPE
    '' CURRENCY_CONVERSION_DATE,                        --  i.CURRENCY_CONVERSION_DATE
    '' CURRENCY_CONVERSION_RATE,                        --  i.CURRENCY_CONVERSION_RATE
    '11' SEGMENT1,                                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT1 = 02
    '11000' SEGMENT2 ,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT2 = 01
    '00' SEGMENT3,                                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT3 = 01
    '00000' SEGMENT4 ,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT4 = 05
    '000' SEGMENT5,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT5 = 00
    '210800' SEGMENT6,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00
    '00000' SEGMENT7,                                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01
    '000' SEGMENT8,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100
    '000' SEGMENT9,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00
    0 ENTERED_DR ,   --  i.ENTERED_DR
    SSP.TOTALVALUETAX ENTERED_CR ,   --  i.ENTERED_CR
    0 ACCOUNTED_DR , --  i.ACCOUNTED_DR
    SSP.TOTALVALUETAX ACCOUNTED_CR , --  i.ACCOUNTED_CR
    XXPBSA_GL_CURR_OPERIOD PERIOD_NAME , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )
    SYSDATE REFERENCE1 ,      --  i.REFERENCE1
    'Tax Account' REFERENCE2,     --  i.REFERENCE2
    'TAX' REFERENCE4 ,     --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  )
    'Tax Account' REFERENCE5 --  i.REFERENCE5
  FROM SALESSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ss ,
    SALESSUMMARYPRODUCT@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ssp
  WHERE ss.SALESUMMARYID = ssp.SALESUMMARYID
        and ss.status_flag is null
        
  )
GROUP BY SALESUMMARYID,
  LEDGER_ID,
  STATUS,
  SET_OF_BOOKS_ID,
  USER_JE_SOURCE_NAME,
  USER_JE_CATEGORY_NAME,
  ACCOUNTING_DATE,
  CURRENCY_CODE,
  DATE_CREATED,
  CREATED_BY,
  ACTUAL_FLAG,
  USER_CURRENCY_CONVERSION_TYPE,
  CURRENCY_CONVERSION_DATE,
  CURRENCY_CONVERSION_RATE,
  SEGMENT1,
  SEGMENT2,
  SEGMENT3,
  SEGMENT4,
  SEGMENT5,
  SEGMENT6,
  SEGMENT7,
  SEGMENT8,
  SEGMENT9,
  PERIOD_NAME,
  REFERENCE1,
  REFERENCE2,
  REFERENCE4,
  REFERENCE5)
UNION ALL
(
SELECT SALESUMMARYID,
  LEDGER_ID,
  STATUS,
  SET_OF_BOOKS_ID,
  USER_JE_SOURCE_NAME,
  USER_JE_CATEGORY_NAME,
  ACCOUNTING_DATE,
  CURRENCY_CODE,
  DATE_CREATED,
  CREATED_BY,
  ACTUAL_FLAG,
  USER_CURRENCY_CONVERSION_TYPE,
  CURRENCY_CONVERSION_DATE,
  CURRENCY_CONVERSION_RATE,
  SEGMENT1,
  SEGMENT2,
  SEGMENT3,
  SEGMENT4,
  SEGMENT5,
  SEGMENT6,
  SEGMENT7,
  SEGMENT8,
  SEGMENT9,
  SUM(ENTERED_DR) ENTERED_DR,
  SUM(ENTERED_CR) ENTERED_CR,
  SUM(ACCOUNTED_DR) ACCOUNTED_DR,
  SUM(ACCOUNTED_CR) ACCOUNTED_CR,
  PERIOD_NAME,
  REFERENCE1,
  REFERENCE2,
  REFERENCE4,
  REFERENCE5
FROM
  ( SELECT DISTINCT '0' SALESUMMARYID,
    2021 LEDGER_ID,                     --  SELECT * FROM GL_SETS_OF_BOOKS
    'Y' STATUS,                         --  i.STATUS
    2021 SET_OF_BOOKS_ID,               --  SELECT * FROM GL_SETS_OF_BOOKS      (Trading Companies SOB)
    'Manual' USER_JE_SOURCE_NAME,       --  SELECT * FROM GL_JE_SOURCES WHERE JE_SOURCE_NAME LIKE 'Manual'
    'Adjustment' USER_JE_CATEGORY_NAME, --  SELECT USER_JE_CATEGORY_NAME FROM GL_JE_CATEGORIES WHERE USER_JE_CATEGORY_NAME LIKE 'SSE%'
    sysdate ACCOUNTING_DATE,            --ss.SALES_DATE ACCOUNTING_DATE,      --  i.ACCOUNTING_DATE
    'LKR' CURRENCY_CODE,                --  i.CURRENCY_CODE
    sysdate DATE_CREATED,               --ss.SALES_DATE DATE_CREATED,         --  DATE_CREATED
    0 CREATED_BY,                       --  fnd_global.user_id
    'A' ACTUAL_FLAG,                    --  i.ACTUAL_FLAG    -- A  Actual , B – Budget E – Encumbrance
    --  i.ENCUMBRANCE_TYPE_ID       ,
    --  i.BUDGET_VERSION_ID         ,
    '' USER_CURRENCY_CONVERSION_TYPE,                   --  i.USER_CURRENCY_CONVERSION_TYPE
    '' CURRENCY_CONVERSION_DATE,                        --  i.CURRENCY_CONVERSION_DATE
    '' CURRENCY_CONVERSION_RATE,                        --  i.CURRENCY_CONVERSION_RATE
    '11' SEGMENT1,                                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT1 = 02
    '11000' SEGMENT2 ,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT2 = 01
    '00' SEGMENT3,                                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT3 = 01
    gl.segment4 SEGMENT4 ,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT4 = 05
    '000' SEGMENT5,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT5 = 00
    gl.segment6 SEGMENT6,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00
    '00000' SEGMENT7,                                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01
    '000' SEGMENT8,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100
    '000' SEGMENT9,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00
    SSP.AVGCOSTEX * SSP.TOTALUNITS ENTERED_DR ,   --  i.ENTERED_DR
    0 ENTERED_CR ,   --  i.ENTERED_CR
    SSP.AVGCOSTEX * SSP.TOTALUNITS ACCOUNTED_DR , --  i.ACCOUNTED_DR
    0 ACCOUNTED_CR , --  i.ACCOUNTED_CR
    XXPBSA_GL_CURR_OPERIOD PERIOD_NAME , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )
    SYSDATE REFERENCE1 ,      --  i.REFERENCE1
    'Cost Account' REFERENCE2,     --  i.REFERENCE2
    'COST' REFERENCE4 ,     --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  )
    'Cost Account' REFERENCE5 --  i.REFERENCE5
  FROM SALESSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ss ,
    SALESSUMMARYPRODUCT@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ssp,
    (
    SELECT   distinct gcc.segment4
             ,gcc.segment6
             ,msi.segment1 item_segment1
        FROM  mtl_item_categories mic,
              mtl_category_sets_tl mcst,
              mtl_category_sets_b mcs,
              mtl_categories_b_kfv mc,
              mtl_system_items_b msi,
              GL_CODE_COMBINATIONS gcc
        WHERE mic.category_set_id = mcs.category_set_id
              AND mcs.category_set_id   = mcst.category_set_id
              AND mcst.LANGUAGE         = USERENV ('LANG')
              AND mic.category_id       = mc.category_id     
              AND msi.organization_id = mic.organization_id    
              AND msi.inventory_item_id = mic.inventory_item_id   
              AND REPLACE(UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))), 'SALES - LIQUOR', 'SALES - LIQUOR ' || q'[&]' || ' TOBACCO') like UPPER('%Cost of Sale%'||mc.segment1||'%')
              AND UPPER('%'||mc.segment4||'%') like (CASE WHEN mc.segment1 like '%GROCERY%' then UPPER(DECODE(gcc.segment4,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,4,gcc.segment4))) else mc.segment4 end)
              AND gcc.end_date_active is null
        ) gl
  WHERE ss.SALESUMMARYID = ssp.SALESUMMARYID
        AND ssp.partnumber = gl.item_segment1(+)
        and ss.status_flag is null
        
  )
GROUP BY SALESUMMARYID,
  LEDGER_ID,
  STATUS,
  SET_OF_BOOKS_ID,
  USER_JE_SOURCE_NAME,
  USER_JE_CATEGORY_NAME,
  ACCOUNTING_DATE,
  CURRENCY_CODE,
  DATE_CREATED,
  CREATED_BY,
  ACTUAL_FLAG,
  USER_CURRENCY_CONVERSION_TYPE,
  CURRENCY_CONVERSION_DATE,
  CURRENCY_CONVERSION_RATE,
  SEGMENT1,
  SEGMENT2,
  SEGMENT3,
  SEGMENT4,
  SEGMENT5,
  SEGMENT6,
  SEGMENT7,
  SEGMENT8,
  SEGMENT9,
  PERIOD_NAME,
  REFERENCE1,
  REFERENCE2,
  REFERENCE4,
  REFERENCE5
)
UNION ALL
    (SELECT SALESUMMARYID,
  LEDGER_ID,
  STATUS,
  SET_OF_BOOKS_ID,
  USER_JE_SOURCE_NAME,
  USER_JE_CATEGORY_NAME,
  ACCOUNTING_DATE,
  CURRENCY_CODE,
  DATE_CREATED,
  CREATED_BY,
  ACTUAL_FLAG,
  USER_CURRENCY_CONVERSION_TYPE,
  CURRENCY_CONVERSION_DATE,
  CURRENCY_CONVERSION_RATE,
  SEGMENT1,
  SEGMENT2,
  SEGMENT3,
  SEGMENT4,
  SEGMENT5,
  SEGMENT6,
  SEGMENT7,
  SEGMENT8,
  SEGMENT9,
  SUM(ENTERED_DR) ENTERED_DR,
  SUM(ENTERED_CR) ENTERED_CR,
  SUM(ACCOUNTED_DR) ACCOUNTED_DR,
  SUM(ACCOUNTED_CR) ACCOUNTED_CR,
  PERIOD_NAME,
  REFERENCE1,
  REFERENCE2,
  REFERENCE4,
  REFERENCE5
FROM
  ( SELECT DISTINCT '0' SALESUMMARYID,
    2021 LEDGER_ID,                     --  SELECT * FROM GL_SETS_OF_BOOKS
    'Y' STATUS,                         --  i.STATUS
    2021 SET_OF_BOOKS_ID,               --  SELECT * FROM GL_SETS_OF_BOOKS      (Trading Companies SOB)
    'Manual' USER_JE_SOURCE_NAME,       --  SELECT * FROM GL_JE_SOURCES WHERE JE_SOURCE_NAME LIKE 'Manual'
    'Adjustment' USER_JE_CATEGORY_NAME, --  SELECT USER_JE_CATEGORY_NAME FROM GL_JE_CATEGORIES WHERE USER_JE_CATEGORY_NAME LIKE 'SSE%'
    sysdate ACCOUNTING_DATE,            --ss.SALES_DATE ACCOUNTING_DATE,      --  i.ACCOUNTING_DATE
    'LKR' CURRENCY_CODE,                --  i.CURRENCY_CODE
    sysdate DATE_CREATED,               --ss.SALES_DATE DATE_CREATED,         --  DATE_CREATED
    0 CREATED_BY,                       --  fnd_global.user_id
    'A' ACTUAL_FLAG,                    --  i.ACTUAL_FLAG    -- A  Actual , B – Budget E – Encumbrance
    --  i.ENCUMBRANCE_TYPE_ID       ,
    --  i.BUDGET_VERSION_ID         ,
    '' USER_CURRENCY_CONVERSION_TYPE,                   --  i.USER_CURRENCY_CONVERSION_TYPE
    '' CURRENCY_CONVERSION_DATE,                        --  i.CURRENCY_CONVERSION_DATE
    '' CURRENCY_CONVERSION_RATE,                        --  i.CURRENCY_CONVERSION_RATE
    '11' SEGMENT1,                                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT1 = 02
    '11000' SEGMENT2 ,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT2 = 01
    '00' SEGMENT3,                                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT3 = 01
    gl.segment4 SEGMENT4 ,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT4 = 05
    '000' SEGMENT5,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT5 = 00
    gl.segment6 SEGMENT6,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00
    '00000' SEGMENT7,                                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01
    '000' SEGMENT8,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100
    '000' SEGMENT9,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00
    0 ENTERED_DR ,   --  i.ENTERED_DR
    SSP.AVGCOSTEX * SSP.TOTALUNITS ENTERED_CR ,   --  i.ENTERED_CR
    0 ACCOUNTED_DR , --  i.ACCOUNTED_DR
    SSP.AVGCOSTEX * SSP.TOTALUNITS ACCOUNTED_CR , --  i.ACCOUNTED_CR
    XXPBSA_GL_CURR_OPERIOD PERIOD_NAME , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )
    SYSDATE REFERENCE1 ,      --  i.REFERENCE1
    'Inventory Control Account' REFERENCE2,     --  i.REFERENCE2
    'INV CONTROL' REFERENCE4 ,     --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  )
    'Inventory Control Account' REFERENCE5 --  i.REFERENCE5
  FROM SALESSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ss ,
    SALESSUMMARYPRODUCT@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ssp,
    (SELECT   distinct gcc.segment4
             ,gcc.segment6
             ,msi.segment1 item_segment1
        FROM  mtl_item_categories mic,
              mtl_category_sets_tl mcst,
              mtl_category_sets_b mcs,
              mtl_categories_b_kfv mc,
              mtl_system_items_b msi,
              GL_CODE_COMBINATIONS gcc
        WHERE mic.category_set_id = mcs.category_set_id
              AND mcs.category_set_id   = mcst.category_set_id
              AND mcst.LANGUAGE         = USERENV ('LANG')
              AND mic.category_id       = mc.category_id     
              AND msi.organization_id = mic.organization_id    
              AND msi.inventory_item_id = mic.inventory_item_id   
              AND REPLACE(UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))), 'SALES - LIQUOR', 'SALES - LIQUOR ' || q'[&]' || ' TOBACCO') like UPPER('%Control%'||mc.segment1||'%')
              AND UPPER('%'||mc.segment4||'%') like (CASE WHEN mc.segment1 like '%GROCERY%' then UPPER(DECODE(gcc.segment4,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,4,gcc.segment4))) else mc.segment4 end)
              AND gcc.end_date_active is null
      ) gl
        WHERE ss.SALESUMMARYID = ssp.SALESUMMARYID
        AND gl.item_segment1(+) = ssp.partnumber
        AND ss.status_flag is null
        
  )
GROUP BY SALESUMMARYID,
  LEDGER_ID,
  STATUS,
  SET_OF_BOOKS_ID,
  USER_JE_SOURCE_NAME,
  USER_JE_CATEGORY_NAME,
  ACCOUNTING_DATE,
  CURRENCY_CODE,
  DATE_CREATED,
  CREATED_BY,
  ACTUAL_FLAG,
  USER_CURRENCY_CONVERSION_TYPE,
  CURRENCY_CONVERSION_DATE,
  CURRENCY_CONVERSION_RATE,
  SEGMENT1,
  SEGMENT2,
  SEGMENT3,
  SEGMENT4,
  SEGMENT5,
  SEGMENT6,
  SEGMENT7,
  SEGMENT8,
  SEGMENT9,
  PERIOD_NAME,
  REFERENCE1,
  REFERENCE2,
  REFERENCE4,
  REFERENCE5)
  UNION ALL
  (
  SELECT SALESUMMARYID,
  LEDGER_ID,
  STATUS,
  SET_OF_BOOKS_ID,
  USER_JE_SOURCE_NAME,
  USER_JE_CATEGORY_NAME,
  ACCOUNTING_DATE,
  CURRENCY_CODE,
  DATE_CREATED,
  CREATED_BY,
  ACTUAL_FLAG,
  USER_CURRENCY_CONVERSION_TYPE,
  CURRENCY_CONVERSION_DATE,
  CURRENCY_CONVERSION_RATE,
  SEGMENT1,
  SEGMENT2,
  SEGMENT3,
  SEGMENT4,
  SEGMENT5,
  SEGMENT6,
  SEGMENT7,
  SEGMENT8,
  SEGMENT9,
  SUM(ENTERED_DR) ENTERED_DR,
  SUM(ENTERED_CR) ENTERED_CR,
  SUM(ACCOUNTED_DR) ACCOUNTED_DR,
  SUM(ACCOUNTED_CR) ACCOUNTED_CR,
  PERIOD_NAME,
  REFERENCE1,
  REFERENCE2,
  REFERENCE4,
  REFERENCE5
FROM
  ( SELECT DISTINCT '0' SALESUMMARYID,
    2021 LEDGER_ID,                     --  SELECT * FROM GL_SETS_OF_BOOKS
    'Y' STATUS,                         --  i.STATUS
    2021 SET_OF_BOOKS_ID,               --  SELECT * FROM GL_SETS_OF_BOOKS      (Trading Companies SOB)
    'Manual' USER_JE_SOURCE_NAME,       --  SELECT * FROM GL_JE_SOURCES WHERE JE_SOURCE_NAME LIKE 'Manual'
    'Adjustment' USER_JE_CATEGORY_NAME, --  SELECT USER_JE_CATEGORY_NAME FROM GL_JE_CATEGORIES WHERE USER_JE_CATEGORY_NAME LIKE 'SSE%'
    sysdate ACCOUNTING_DATE,            --ss.SALES_DATE ACCOUNTING_DATE,      --  i.ACCOUNTING_DATE
    'LKR' CURRENCY_CODE,                --  i.CURRENCY_CODE
    sysdate DATE_CREATED,               --ss.SALES_DATE DATE_CREATED,         --  DATE_CREATED
    0 CREATED_BY,                       --  fnd_global.user_id
    'A' ACTUAL_FLAG,                    --  i.ACTUAL_FLAG    -- A  Actual , B – Budget E – Encumbrance
    --  i.ENCUMBRANCE_TYPE_ID       ,
    --  i.BUDGET_VERSION_ID         ,
    '' USER_CURRENCY_CONVERSION_TYPE,                   --  i.USER_CURRENCY_CONVERSION_TYPE
    '' CURRENCY_CONVERSION_DATE,                        --  i.CURRENCY_CONVERSION_DATE
    '' CURRENCY_CONVERSION_RATE,                        --  i.CURRENCY_CONVERSION_RATE
    '11' SEGMENT1,                                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT1 = 02
    '11000' SEGMENT2 ,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT2 = 01
    '00' SEGMENT3,                                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT3 = 01
    '00000' SEGMENT4 ,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT4 = 05
    '000' SEGMENT5,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT5 = 00
    '219030' SEGMENT6,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00
    '00000' SEGMENT7,                                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01
    '000' SEGMENT8,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100
    '000' SEGMENT9,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00
    SSP.TOTALVALUEEX + SSP.TOTALVALUETAX ENTERED_DR ,   --  i.ENTERED_DR
    0 ENTERED_CR ,   --  i.ENTERED_CR
    SSP.TOTALVALUEEX + SSP.TOTALVALUETAX ACCOUNTED_DR , --  i.ACCOUNTED_DR
    0 ACCOUNTED_CR , --  i.ACCOUNTED_CR
    XXPBSA_GL_CURR_OPERIOD PERIOD_NAME , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )
    SYSDATE REFERENCE1 ,      --  i.REFERENCE1
    'Cash Control Account' REFERENCE2,     --  i.REFERENCE2
    'CASH CONTROL' REFERENCE4 ,     --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  )
    'Cash Control Account' REFERENCE5 --  i.REFERENCE5
  FROM SALESSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ss ,
    SALESSUMMARYPRODUCT@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ssp,
    (
    SELECT   distinct gcc.segment4
             ,gcc.segment6
             ,msi.segment1 item_segment1
        FROM  mtl_item_categories mic,
              mtl_category_sets_tl mcst,
              mtl_category_sets_b mcs,
              mtl_categories_b_kfv mc,
              mtl_system_items_b msi,
              GL_CODE_COMBINATIONS gcc
        WHERE mic.category_set_id = mcs.category_set_id
              AND mcs.category_set_id   = mcst.category_set_id
              AND mcst.LANGUAGE         = USERENV ('LANG')
              AND mic.category_id       = mc.category_id     
              AND msi.organization_id = mic.organization_id    
              AND msi.inventory_item_id = mic.inventory_item_id   
              AND REPLACE(UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))), 'SALES - LIQUOR', 'SALES - LIQUOR ' || q'[&]' || ' TOBACCO') like UPPER('%Cash Control%'||mc.segment1||'%')
              AND UPPER('%'||mc.segment4||'%') like (CASE WHEN mc.segment1 like '%GROCERY%' then UPPER(DECODE(gcc.segment4,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,4,gcc.segment4))) else mc.segment4 end)
              AND gcc.end_date_active is null
    ) gl
  WHERE ss.SALESUMMARYID = ssp.SALESUMMARYID
        and ss.status_flag is null
        AND gl.item_segment1(+) = ssp.partnumber
        
  )
GROUP BY SALESUMMARYID,
  LEDGER_ID,
  STATUS,
  SET_OF_BOOKS_ID,
  USER_JE_SOURCE_NAME,
  USER_JE_CATEGORY_NAME,
  ACCOUNTING_DATE,
  CURRENCY_CODE,
  DATE_CREATED,
  CREATED_BY,
  ACTUAL_FLAG,
  USER_CURRENCY_CONVERSION_TYPE,
  CURRENCY_CONVERSION_DATE,
  CURRENCY_CONVERSION_RATE,
  SEGMENT1,
  SEGMENT2,
  SEGMENT3,
  SEGMENT4,
  SEGMENT5,
  SEGMENT6,
  SEGMENT7,
  SEGMENT8,
  SEGMENT9,
  PERIOD_NAME,
  REFERENCE1,
  REFERENCE2,
  REFERENCE4,
  REFERENCE5
  )
  ) glq
WHERE 1 = 1
)
group by LEDGER_ID,
  STATUS,
  SET_OF_BOOKS_ID,
  USER_JE_SOURCE_NAME,
  USER_JE_CATEGORY_NAME,
  ACCOUNTING_DATE,
  CURRENCY_CODE,
  DATE_CREATED,
  CREATED_BY,
  ACTUAL_FLAG,
  USER_CURRENCY_CONVERSION_TYPE,
  CURRENCY_CONVERSION_DATE,
  CURRENCY_CONVERSION_RATE,
  SEGMENT1,
  SEGMENT2,
  SEGMENT3,
  SEGMENT4,
  SEGMENT5,
  SEGMENT6,
  SEGMENT7,
  SEGMENT8,
  SEGMENT9,
  PERIOD_NAME,
  REFERENCE1,
  REFERENCE2,
  REFERENCE4,
  REFERENCE5;
  
    cursor outlet
    is
    SELECT ffv.flex_value, ffvt.description
    FROM   fnd_flex_values ffv
          ,fnd_flex_values_tl ffvt
    WHERE  ffv.flex_value_id = ffvt.flex_value_id
           AND ffv.flex_value_set_id = 1017028--need to change after the next setup
           AND ffv.attribute2 is null;--need to change with the data from LSL mapped to SALESSUMMARY table new column
  
    cursor prod
    is
    SELECT ssp.PARTNUMBER
    FROM SALESSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ss,
         SALESSUMMARYPRODUCT@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ssp
    WHERE 1 = 1
          AND ss.SALESUMMARYID = ssp.SALESUMMARYID
          AND ss.status_flag is null;

    cursor parts_gcc(p_parts varchar2)
    is
    SELECT ffv.flex_value
    FROM   fnd_flex_values ffv
          ,fnd_flex_values_tl ffvt
    WHERE  ffv.flex_value_id = ffvt.flex_value_id
    AND    ffv.flex_value_set_id = 1017032--need to change after the next setup
           and UPPER(ffvt.description) like 
           '%'||
           (SELECT distinct UPPER(mc.segment1)
            FROM  mtl_item_categories mic,
                  mtl_category_sets_tl mcst,
                  mtl_category_sets_b mcs,
                  mtl_categories_b_kfv mc,
                  mtl_system_items_b msi
            WHERE mic.category_set_id = mcs.category_set_id
                  AND mcs.category_set_id   = mcst.category_set_id
                  AND mcst.LANGUAGE         = USERENV ('LANG')
                  AND mic.category_id       = mc.category_id     
                  AND msi.organization_id = mic.organization_id    
                  AND msi.inventory_item_id = mic.inventory_item_id
                  AND msi.segment1 = p_parts)
            ||'%';
        
        cursor prod_gcc(p_prod varchar2)
        is
        SELECT ffv.flex_value
        FROM   fnd_flex_values ffv
              ,fnd_flex_values_tl ffvt
        WHERE  ffv.flex_value_id = ffvt.flex_value_id
        AND    ffv.flex_value_set_id = 1017030--need to change after the next setup
               and UPPER(ffvt.description) like 
               '%'||
               (SELECT distinct UPPER(mc.segment4)
                FROM  mtl_item_categories mic,
                      mtl_category_sets_tl mcst,
                      mtl_category_sets_b mcs,
                      mtl_categories_b_kfv mc,
                      mtl_system_items_b msi
                WHERE mic.category_set_id = mcs.category_set_id
                      AND mcs.category_set_id   = mcst.category_set_id
                      AND mcst.LANGUAGE         = USERENV ('LANG')
                      AND mic.category_id       = mc.category_id     
                      AND msi.organization_id = mic.organization_id    
                      AND msi.inventory_item_id = mic.inventory_item_id
                      AND msi.organization_id = 101
                      AND msi.segment1 = p_prod)
                ||'%';
  
BEGIN

SELECT ffv.flex_value, ffvt.description
into l_segment2, l_batch_name
FROM   fnd_flex_values ffv
      ,fnd_flex_values_tl ffvt
WHERE  ffv.flex_value_id = ffvt.flex_value_id
       AND ffv.flex_value_set_id = 1017028
       AND ffv.flex_value = '11000'
       AND ffv.attribute2 is null;--store ID value based on IP of data sent to Oracle

for cur_parts in prod
loop
    for parts_cc in parts_gcc(cur_parts.PARTNUMBER)
    loop
        l_segment6 := parts_cc.flex_value;
    end loop;
    
    for prod_cc in prod_gcc(cur_parts.PARTNUMBER)
    loop
        l_segment4 := prod_cc.flex_value;
    end loop;
end loop;

for cur_rec in cur
loop

select   cur_rec.SEGMENT1||'-'||l_segment2||'-'||cur_rec.SEGMENT3||'-'||
         DECODE(cur_rec.SEGMENT4,l_segment4,cur_rec.SEGMENT4)||'-'||cur_rec.SEGMENT5||'-'||l_segment6      ||'-'||
         cur_rec.SEGMENT7||'-'||cur_rec.SEGMENT8||'-'||cur_rec.SEGMENT9
into l_code
from dual;         

insert into XXPBSA_ACCOUNT_COMBINATIONS
(select l_code from dual where l_code not in (select CONCATENATED_SEGMENTS from gl_code_combinations_kfv));
COMMIT;

XXPBSA_CREATE_GL_ACC_COMB;

INSERT INTO GL_INTERFACE (
                          LEDGER_ID                     ,
                          STATUS                        ,                                  
                          SET_OF_BOOKS_ID               ,        
                          USER_JE_SOURCE_NAME           ,        
                          USER_JE_CATEGORY_NAME         ,      
                          ACCOUNTING_DATE               ,      
                          CURRENCY_CODE                 ,      
                          DATE_CREATED                  ,      
                          CREATED_BY                    ,      
                          ACTUAL_FLAG                   ,      
                   --       ENCUMBRANCE_TYPE_ID         ,      
                   --       BUDGET_VERSION_ID           ,        
                          USER_CURRENCY_CONVERSION_TYPE ,        
                          CURRENCY_CONVERSION_DATE      ,        
                          CURRENCY_CONVERSION_RATE      ,        
                          SEGMENT1                      ,        
                          SEGMENT2                      ,        
                          SEGMENT3                      ,        
                          SEGMENT4                      ,        
                          SEGMENT5                      ,        
                          SEGMENT6                      ,  
                          SEGMENT7                      ,
                          SEGMENT8                      ,
                          SEGMENT9                      ,      
                          ENTERED_DR                    ,        
                          ENTERED_CR                    ,        
                          ACCOUNTED_DR                  ,        
                          ACCOUNTED_CR                  ,        
                          PERIOD_NAME                   ,        
                          REFERENCE1                    ,        
                          REFERENCE2                    ,        
                          REFERENCE4                    ,   
                          REFERENCE5                              
                        )
                    values
                        ( 
                          
                          cur_rec.LEDGER_ID                     ,
                          cur_rec.STATUS                        ,                                  
                          cur_rec.SET_OF_BOOKS_ID               ,        
                          cur_rec.USER_JE_SOURCE_NAME           ,        
                          cur_rec.USER_JE_CATEGORY_NAME         ,      
                          cur_rec.ACCOUNTING_DATE               ,      
                          cur_rec.CURRENCY_CODE                 ,      
                          cur_rec.DATE_CREATED                  ,      
                          cur_rec.CREATED_BY                    ,      
                          cur_rec.ACTUAL_FLAG                   ,      
                   --       ENCUMBRANCE_TYPE_ID         ,      
                   --       BUDGET_VERSION_ID           ,        
                          cur_rec.USER_CURRENCY_CONVERSION_TYPE ,        
                          cur_rec.CURRENCY_CONVERSION_DATE      ,        
                          cur_rec.CURRENCY_CONVERSION_RATE      ,        

                         cur_rec.SEGMENT1                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT1 = 02   
                         l_segment2                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT2 = 01  
                         cur_rec.SEGMENT3                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT3 = 01   
                         cur_rec.SEGMENT4                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT4 = 05   
                         cur_rec.SEGMENT5                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT5 = 00   
                         cur_rec.SEGMENT6                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00   
                         cur_rec.SEGMENT7                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01   
                         cur_rec.SEGMENT8                     , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100  
                         cur_rec.SEGMENT9                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00                          
                          
                          cur_rec.ENTERED_DR                    ,        
                          cur_rec.ENTERED_CR                    ,        
                          cur_rec.ACCOUNTED_DR                  ,        
                          cur_rec.ACCOUNTED_CR                  ,        
                          cur_rec.PERIOD_NAME                   ,        
                          l_batch_name,--cur_rec.REFERENCE1                    ,        
                          l_batch_name||'-'||SYSDATE,--cur_rec.REFERENCE2                    ,        
                          cur_rec.REFERENCE4                    ,   
                          cur_rec.REFERENCE5                   
                         );
                         
                         update SALESSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG
                         set status_flag = 'P'
                         where SALESUMMARYID in
                         ( select distinct ss.SALESUMMARYID 
                           FROM SALESSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ss ,
                                SALESSUMMARYPRODUCT@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ssp
                           WHERE ss.SALESUMMARYID = ssp.SALESUMMARYID
                                 and ssp.PARTNUMBER = cur_rec.REFERENCE5)
                                and status_flag is null;
 end loop;
 XXPBSA_REQ_JE_IMPORT('Manual');
END;
/