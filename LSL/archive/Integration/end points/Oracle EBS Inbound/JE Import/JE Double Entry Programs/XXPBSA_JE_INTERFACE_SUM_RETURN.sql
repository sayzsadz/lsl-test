CREATE OR REPLACE PROCEDURE XXPBSA_JE_INTERFACE_SUM_RETURN(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2) 
IS        
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
  REFERENCE4,
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
--  ENTERED_DR,
--  ENTERED_CR,
--  ACCOUNTED_DR,
--  ACCOUNTED_CR,
(
  CASE 
  WHEN  REFERENCE2 like ('%'||'Cash'||'%')
     OR REFERENCE4 like UPPER('%'||'%Sales%Control%'||'%') 
     OR REFERENCE4 like UPPER('%'||'%Card%Control%'||'%') 
     OR REFERENCE4 like UPPER('%'||'%Bank%Control%'||'%') 
     OR REFERENCE4 like UPPER('%'||'%COGS%'||'%') 
     THEN
    0
  ELSE ENTERED_DR
  END) ENTERED_DR ,
(
  CASE 
    WHEN  REFERENCE2 like ('%'||'Cash'||'%')
     OR REFERENCE4 like UPPER('%'||'%Sales%Control%'||'%') 
     OR REFERENCE4 like UPPER('%'||'%Card%Control%'||'%') 
     OR REFERENCE4 like UPPER('%'||'%Bank%Control%'||'%') 
     OR REFERENCE4 like UPPER('%'||'%COGS%'||'%') 
     THEN
    ENTERED_CR
  ELSE 0
  END) ENTERED_CR,
(
  CASE 
    WHEN  REFERENCE2 like ('%'||'Cash'||'%')
     OR REFERENCE4 like UPPER('%'||'%Sales%Control%'||'%') 
     OR REFERENCE4 like UPPER('%'||'%Card%Control%'||'%') 
     OR REFERENCE4 like UPPER('%'||'%Bank%Control%'||'%') 
     OR REFERENCE4 like UPPER('%'||'%COGS%'||'%') 
     THEN
    0
  ELSE ACCOUNTED_DR
  END) ACCOUNTED_DR,
(
  CASE 
    WHEN  REFERENCE2 like ('%'||'Cash'||'%')
     OR REFERENCE4 like UPPER('%'||'%Sales%Control%'||'%') 
     OR REFERENCE4 like UPPER('%'||'%Card%Control%'||'%') 
     OR REFERENCE4 like UPPER('%'||'%Bank%Control%'||'%') 
     OR REFERENCE4 like UPPER('%'||'%COGS%'||'%') 
     THEN
    ACCOUNTED_CR
  ELSE 0
  END) ACCOUNTED_CR,
  PERIOD_NAME,
  REFERENCE1,
  REFERENCE2,
  REFERENCE4,
  REFERENCE5
FROM
  (
  (
  
  SELECT DISTINCT 0 PAYMENTTYPESID,
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
    gcc.segment6 SEGMENT6,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00
    '00000' SEGMENT7,                                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01
    '000' SEGMENT8,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100
    '000' SEGMENT9,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00
    pts.TOTALVALUE + NVL(ccs.AMOUNT, 0) ENTERED_DR ,   --  i.ENTERED_DR
    pts.TOTALVALUE + NVL(ccs.AMOUNT, 0) ENTERED_CR ,   --  i.ENTERED_CR
    pts.TOTALVALUE + NVL(ccs.AMOUNT, 0) ACCOUNTED_DR , --  i.ACCOUNTED_DR
    pts.TOTALVALUE + NVL(ccs.AMOUNT, 0) ACCOUNTED_CR , --  i.ACCOUNTED_CR
    XXPBSA_GL_CURR_OPERIOD PERIOD_NAME , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )
    ccs.CREDITCARDTYPE REFERENCE1 ,      --  i.REFERENCE1
    pts.PAYMENTTYPE REFERENCE2,     --  i.REFERENCE2
    'COGS' REFERENCE4 ,     --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  )
    ccs.REFERENCENUMBER REFERENCE5 --  i.REFERENCE5
  FROM CREDITCARDTRANSACTION@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ccs,
       PAYMENTSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ps,
       PAYMENTTYPESUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG pts,
       GL_CODE_COMBINATIONS gcc
  WHERE 1 = 1
        and ps.TRANSACTIONID = ccs.TRANSACTIONID
        and ps.PAYMENTTYPESID = pts.PAYMENTTYPESID
        and ps.status_flag is null
        --and pts.PAYMENTTYPE like '%Credit%'
        AND REPLACE(UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))), 'SALES - LIQUOR', 'SALES - LIQUOR ' || q'[&]' || ' TOBACCO') like UPPER('%Cost%Sale%General%')
        AND gcc.end_date_active is null
  )
  UNION ALL
  (
  
  SELECT DISTINCT 0 PAYMENTTYPESID,
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
    gcc.segment6 SEGMENT6,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00
    '00000' SEGMENT7,                                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01
    '000' SEGMENT8,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100
    '000' SEGMENT9,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00
    pts.TOTALVALUE + NVL(ccs.AMOUNT, 0) ENTERED_DR ,   --  i.ENTERED_DR
    pts.TOTALVALUE + NVL(ccs.AMOUNT, 0) ENTERED_CR ,   --  i.ENTERED_CR
    pts.TOTALVALUE + NVL(ccs.AMOUNT, 0) ACCOUNTED_DR , --  i.ACCOUNTED_DR
    pts.TOTALVALUE + NVL(ccs.AMOUNT, 0) ACCOUNTED_CR , --  i.ACCOUNTED_CR
    XXPBSA_GL_CURR_OPERIOD PERIOD_NAME , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )
    ccs.CREDITCARDTYPE REFERENCE1 ,      --  i.REFERENCE1
    pts.PAYMENTTYPE REFERENCE2,     --  i.REFERENCE2
    'INV CONTROL' REFERENCE4 ,     --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  )
    ccs.REFERENCENUMBER REFERENCE5 --  i.REFERENCE5
  FROM CREDITCARDTRANSACTION@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ccs,
       PAYMENTSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ps,
       PAYMENTTYPESUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG pts,
       GL_CODE_COMBINATIONS gcc
  WHERE 1 = 1
        and ps.TRANSACTIONID = ccs.TRANSACTIONID
        and ps.PAYMENTTYPESID = pts.PAYMENTTYPESID
        and ps.status_flag is null
        --and pts.PAYMENTTYPE like '%Credit%'
        AND REPLACE(UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))), 'SALES - LIQUOR', 'SALES - LIQUOR ' || q'[&]' || ' TOBACCO') like UPPER('%Inv%Control%')
        AND gcc.end_date_active is null
  )
  UNION ALL
  (
  
  SELECT DISTINCT 0 PAYMENTTYPESID,
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
    gcc.segment6 SEGMENT6,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00
    '00000' SEGMENT7,                                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01
    '000' SEGMENT8,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100
    '000' SEGMENT9,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00
    NVL(ccs.AMOUNT, 0) ENTERED_DR ,   --  i.ENTERED_DR
    NVL(ccs.AMOUNT, 0) ENTERED_CR ,   --  i.ENTERED_CR
    NVL(ccs.AMOUNT, 0) ACCOUNTED_DR , --  i.ACCOUNTED_DR
    NVL(ccs.AMOUNT, 0) ACCOUNTED_CR , --  i.ACCOUNTED_CR
    XXPBSA_GL_CURR_OPERIOD PERIOD_NAME , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )
    ccs.CREDITCARDTYPE REFERENCE1 ,      --  i.REFERENCE1
    pts.PAYMENTTYPE REFERENCE2,     --  i.REFERENCE2
    'BANK CONTROL ACCOUNT' REFERENCE4 ,     --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  )
    ccs.REFERENCENUMBER REFERENCE5 --  i.REFERENCE5
  FROM CREDITCARDTRANSACTION@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ccs,
       PAYMENTSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ps,
       PAYMENTTYPESUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG pts,
       GL_CODE_COMBINATIONS gcc
  WHERE 1 = 1
        and ps.TRANSACTIONID = ccs.TRANSACTIONID(+)
        and ps.PAYMENTTYPESID = pts.PAYMENTTYPESID
        and ps.status_flag is null
        and pts.PAYMENTTYPE like '%Credit%'
        AND REPLACE(UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))), 'SALES - LIQUOR', 'SALES - LIQUOR ' || q'[&]' || ' TOBACCO') like UPPER('%Control%BOC%')
        AND gcc.end_date_active is null
  )--needs to modify BANK CONTROL ACCOUNT
  UNION ALL
  (
  
  SELECT DISTINCT 0 PAYMENTTYPESID,
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
    gcc.segment6 SEGMENT6,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00
    '00000' SEGMENT7,                                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01
    '000' SEGMENT8,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100
    '000' SEGMENT9,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00
    NVL(ccs.AMOUNT, 0) ENTERED_DR ,   --  i.ENTERED_DR
    NVL(ccs.AMOUNT, 0) ENTERED_CR ,   --  i.ENTERED_CR
    NVL(ccs.AMOUNT, 0) ACCOUNTED_DR , --  i.ACCOUNTED_DR
    NVL(ccs.AMOUNT, 0) ACCOUNTED_CR , --  i.ACCOUNTED_CR
    XXPBSA_GL_CURR_OPERIOD PERIOD_NAME , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )
    ccs.CREDITCARDTYPE REFERENCE1 ,      --  i.REFERENCE1
    pts.PAYMENTTYPE REFERENCE2,     --  i.REFERENCE2
    'BANK ACCOUNT' REFERENCE4 ,     --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  )
    ccs.REFERENCENUMBER REFERENCE5 --  i.REFERENCE5
  FROM CREDITCARDTRANSACTION@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ccs,
       PAYMENTSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ps,
       PAYMENTTYPESUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG pts,
       GL_CODE_COMBINATIONS gcc
  WHERE 1 = 1
        and ps.TRANSACTIONID = ccs.TRANSACTIONID(+)
        and pts.PAYMENTTYPESID = ps.PAYMENTTYPESID
        and ps.status_flag is null
        and pts.PAYMENTTYPE like '%Credit%'
        AND REPLACE(UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))), 'SALES - LIQUOR', 'SALES - LIQUOR ' || q'[&]' || ' TOBACCO') like UPPER('BOC')
        AND gcc.end_date_active is null

    
  )
  UNION ALL
  (
  SELECT DISTINCT  0 PAYMENTTYPESID,
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
    '00000' SEGMENT4 ,                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT4 = 05
    '000' SEGMENT5,                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT5 = 00
    gcc.segment6 SEGMENT6,                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00
    '00000' SEGMENT7,                    --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01
    '000' SEGMENT8,                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100
    '000' SEGMENT9,                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00
    NVL(ccs.AMOUNT, 0) ENTERED_DR ,        --  i.ENTERED_DR
    NVL(ccs.AMOUNT, 0) ENTERED_CR ,        --  i.ENTERED_CR
    NVL(ccs.AMOUNT, 0) ACCOUNTED_DR ,      --  i.ACCOUNTED_DR
    NVL(ccs.AMOUNT, 0) ACCOUNTED_CR ,      --  i.ACCOUNTED_CR
    XXPBSA_GL_CURR_OPERIOD PERIOD_NAME , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )
    TO_CHAR(SYSDATE) REFERENCE1 ,                 --  i.REFERENCE1
    'Card' REFERENCE2,                --  i.REFERENCE2
    'CARD CONTROL' REFERENCE4 ,                --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  )
    'CARD Account' REFERENCE5            --  i.REFERENCE5
  FROM CREDITCARDTRANSACTION@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ccs,
       PAYMENTSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ps,
       PAYMENTTYPESUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG pts,
       GL_CODE_COMBINATIONS gcc
      WHERE 1 = 1
            and ps.TRANSACTIONID = ccs.TRANSACTIONID
            and pts.PAYMENTTYPESID = ps.PAYMENTTYPESID
            and ps.status_flag is null
            AND REPLACE(UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))), 'SALES - LIQUOR', 'SALES - LIQUOR ' || q'[&]' || ' TOBACCO') like UPPER('%'||'%Card Control Ac%')
            --AND UPPER(DECODE(gcc.segment4,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,4,gcc.segment4))) like UPPER('%'||mc.segment6||'%')
            AND gcc.end_date_active is null
  )
  UNION ALL
  (
  
  SELECT DISTINCT  0 PAYMENTTYPESID,
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
    '00000' SEGMENT4 ,                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT4 = 05
    '000' SEGMENT5,                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT5 = 00
    gcc.segment6 SEGMENT6,                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00
    '00000' SEGMENT7,                    --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01
    '000' SEGMENT8,                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100
    '000' SEGMENT9,                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00
    NVL(pts.TOTALVALUE, 0) ENTERED_DR ,        --  i.ENTERED_DR
    NVL(pts.TOTALVALUE, 0) ENTERED_CR ,        --  i.ENTERED_CR
    NVL(pts.TOTALVALUE, 0) ACCOUNTED_DR ,      --  i.ACCOUNTED_DR
    NVL(pts.TOTALVALUE, 0) ACCOUNTED_CR ,      --  i.ACCOUNTED_CR
    XXPBSA_GL_CURR_OPERIOD PERIOD_NAME , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )
    TO_CHAR(SYSDATE) REFERENCE1 ,                 --  i.REFERENCE1
    'Sales' REFERENCE2,                --  i.REFERENCE2
    'SALES CONTROL' REFERENCE4 ,                --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  )
    'Sales Control Account' REFERENCE5            --  i.REFERENCE5
  FROM CREDITCARDTRANSACTION@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ccs,
       PAYMENTSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ps,
       PAYMENTTYPESUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG pts,
       GL_CODE_COMBINATIONS gcc
      WHERE 1 = 1
            and ps.TRANSACTIONID = ccs.TRANSACTIONID(+)
            and pts.PAYMENTTYPESID = ps.PAYMENTTYPESID
            and ps.status_flag is null
            and pts.PAYMENTTYPE like '%Cash%'
            AND REPLACE(UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))), 'SALES - LIQUOR', 'SALES - LIQUOR ' || q'[&]' || ' TOBACCO') like UPPER('%'||'Sales And Payment Control%')
            --AND UPPER(DECODE(gcc.segment4,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,4,gcc.segment4))) like UPPER('%'||mc.segment6||'%')
            AND gcc.end_date_active is null
  
  )
  
  UNION ALL

  ( 
  SELECT DISTINCT 0 PAYMENTTYPESID,
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
    gcc.segment6 SEGMENT6,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00
    '00000' SEGMENT7,                                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01
    '000' SEGMENT8,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100
    '000' SEGMENT9,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00
    pts.TOTALVALUE ENTERED_DR ,   --  i.ENTERED_DR
    pts.TOTALVALUE ENTERED_CR ,   --  i.ENTERED_CR
    pts.TOTALVALUE ACCOUNTED_DR , --  i.ACCOUNTED_DR
    pts.TOTALVALUE ACCOUNTED_CR , --  i.ACCOUNTED_CR
    XXPBSA_GL_CURR_OPERIOD PERIOD_NAME , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )
    ccs.CREDITCARDTYPE REFERENCE1 ,      --  i.REFERENCE1
    pts.PAYMENTTYPE REFERENCE2,     --  i.REFERENCE2
    pts.PAYMENTTYPE||' CONTROL' REFERENCE4 ,     --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  )
    ccs.REFERENCENUMBER REFERENCE5 --  i.REFERENCE5
  FROM CREDITCARDTRANSACTION@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ccs,
       PAYMENTSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ps,
       PAYMENTTYPESUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG pts,
       GL_CODE_COMBINATIONS gcc
  WHERE 1 = 1
        and ps.TRANSACTIONID = ccs.TRANSACTIONID(+)
        and pts.PAYMENTTYPESID = ps.PAYMENTTYPESID
        and ps.status_flag is null
        AND REPLACE(UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))), 'SALES - LIQUOR', 'SALES - LIQUOR ' || q'[&]' || ' TOBACCO') like UPPER('%'||pts.PAYMENTTYPE||'%Control%')
        AND gcc.end_date_active is null
  )
  UNION ALL

  ( 
  SELECT DISTINCT 0 PAYMENTTYPESID,
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
    gcc.segment6 SEGMENT6,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00
    '00000' SEGMENT7,                                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01
    '000' SEGMENT8,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100
    '000' SEGMENT9,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00
    pts.TOTALVALUE + NVL(ccs.AMOUNT, 0) ENTERED_DR ,   --  i.ENTERED_DR
    pts.TOTALVALUE + NVL(ccs.AMOUNT, 0) ENTERED_CR ,   --  i.ENTERED_CR
    pts.TOTALVALUE + NVL(ccs.AMOUNT, 0) ACCOUNTED_DR , --  i.ACCOUNTED_DR
    pts.TOTALVALUE + NVL(ccs.AMOUNT, 0) ACCOUNTED_CR , --  i.ACCOUNTED_CR
    XXPBSA_GL_CURR_OPERIOD PERIOD_NAME , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )
    ccs.CREDITCARDTYPE REFERENCE1 ,      --  i.REFERENCE1
    pts.PAYMENTTYPE REFERENCE2,     --  i.REFERENCE2
    'SALES ACCOUNT' REFERENCE4 ,     --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  )
    ccs.REFERENCENUMBER REFERENCE5 --  i.REFERENCE5
  FROM CREDITCARDTRANSACTION@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ccs,
       PAYMENTSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ps,
       PAYMENTTYPESUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG pts,
       GL_CODE_COMBINATIONS gcc
  WHERE 1 = 1
        and ps.TRANSACTIONID = ccs.TRANSACTIONID
        and pts.PAYMENTTYPESID = ps.PAYMENTTYPESID
        and ps.status_flag is null
        AND REPLACE(UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))), 'SALES - LIQUOR', 'SALES - LIQUOR ' || q'[&]' || ' TOBACCO') like UPPER('%'||'%Sales%Payment%')
        AND gcc.end_date_active is null
  )
  
  )) glq
WHERE 1 = 1
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

BEGIN

for cur_rec in cur
loop

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
                         cur_rec.SEGMENT2                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT2 = 01  
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
                          cur_rec.REFERENCE1                    ,        
                          cur_rec.REFERENCE2                    ,        
                          cur_rec.REFERENCE4                    ,   
                          cur_rec.REFERENCE5                   
                         );
 end loop;
 XXPBSA_REQ_JE_IMPORT('Manual');
END;
/