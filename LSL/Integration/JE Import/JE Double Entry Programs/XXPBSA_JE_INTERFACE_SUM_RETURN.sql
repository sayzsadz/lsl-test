CREATE OR REPLACE PROCEDURE XXPBSA_JE_INTERFACE_SUM_TAKING(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2) 
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
  WHEN                 segment1
                ||'.'||segment2
                ||'.'||segment3
                ||'.'||segment4
                ||'.'||segment5
                ||'.'||segment6
                ||'.'||segment7
                ||'.'||segment8
                ||'.'||segment9 = XXPBSA_GET_GL_ACCOUNT('Lanka Sathosa Ltd.Head Office.Unspecified.Unspecified.Unspecified.Sales And Payment Control.Unspecified.Unspecified') THEN
    ENTERED_DR
  ELSE 0
  END) ENTERED_DR ,
(
  CASE 
  WHEN                 segment1
                ||'.'||segment2
                ||'.'||segment3
                ||'.'||segment4
                ||'.'||segment5
                ||'.'||segment6
                ||'.'||segment7
                ||'.'||segment8
                ||'.'||segment9 = XXPBSA_GET_GL_ACCOUNT('Lanka Sathosa Ltd.Head Office.Unspecified.Unspecified.Unspecified.Sales And Payment Control.Unspecified.Unspecified') THEN
    0
  ELSE ENTERED_CR
  END) ENTERED_CR,
(
  CASE 
  WHEN                 segment1
                ||'.'||segment2
                ||'.'||segment3
                ||'.'||segment4
                ||'.'||segment5
                ||'.'||segment6
                ||'.'||segment7
                ||'.'||segment8
                ||'.'||segment9 = XXPBSA_GET_GL_ACCOUNT('Lanka Sathosa Ltd.Head Office.Unspecified.Unspecified.Unspecified.Sales And Payment Control.Unspecified.Unspecified') THEN
    ACCOUNTED_DR
  ELSE 0
  END) ACCOUNTED_DR,
(
  CASE 
  WHEN                 segment1
                ||'.'||segment2
                ||'.'||segment3
                ||'.'||segment4
                ||'.'||segment5
                ||'.'||segment6
                ||'.'||segment7
                ||'.'||segment8
                ||'.'||segment9 = XXPBSA_GET_GL_ACCOUNT('Lanka Sathosa Ltd.Head Office.Unspecified.Unspecified.Unspecified.Sales And Payment Control.Unspecified.Unspecified') THEN
    0
  ELSE ACCOUNTED_CR
  END) ACCOUNTED_CR,
  PERIOD_NAME,
  REFERENCE1,
  REFERENCE2,
  REFERENCE4,
  REFERENCE5
FROM
  (
  (select PAYMENTTYPESID,
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
  (SELECT DISTINCT ps.PAYMENTTYPESID,
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
    gl.segment6 SEGMENT6,                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00
    '00000' SEGMENT7,                    --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01
    '000' SEGMENT8,                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100
    '000' SEGMENT9,                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00
    pts.TOTALVALUE ENTERED_DR ,        --  i.ENTERED_DR
    pts.TOTALVALUE ENTERED_CR ,        --  i.ENTERED_CR
    pts.TOTALVALUE ACCOUNTED_DR ,      --  i.ACCOUNTED_DR
    pts.TOTALVALUE ACCOUNTED_CR ,      --  i.ACCOUNTED_CR
    XXPBSA_GL_CURR_OPERIOD PERIOD_NAME , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )
    TO_CHAR(SYSDATE) REFERENCE1 ,                 --  i.REFERENCE1
    pts.PAYMENTTYPE REFERENCE2,                --  i.REFERENCE2
    'PAYMENTS TYPES' REFERENCE4 ,                --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  )
    'Payments Type Account' REFERENCE5            --  i.REFERENCE5
  FROM CREDITCARDTRANSACTION@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ccs,
       PAYMENTSUMMARYRETURN@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ps,
       PAYMENTTYPESUMMARYRETURN@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG pts,
      (SELECT distinct gcc.segment4
         , gcc.segment6
    FROM GL_CODE_COMBINATIONS gcc
    WHERE 1 = 1
          AND REPLACE(UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))), 'SALES - LIQUOR', 'SALES - LIQUOR ' || q'[&]' || ' TOBACCO') like UPPER('%'||'Payment'||'%')
          --AND UPPER(DECODE(gcc.segment4,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,4,gcc.segment4))) like UPPER('%'||mc.segment6||'%')
          AND gcc.end_date_active is null
          ) gl
      WHERE 1 = 1
            and ccs.TRANSACTIONID = ps.TRANSACTIONID
            and pts.PAYMENTTYPESID = ps.PAYMENTTYPESID
            and ps.status_flag is null
  )
  group by PAYMENTTYPESID,
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
  (SELECT PAYMENTTYPESID,
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
  ( SELECT DISTINCT 0 PAYMENTTYPESID,
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
    '09100' SEGMENT2 ,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT2 = 01
    '00' SEGMENT3,                                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT3 = 01
    '00000' SEGMENT4 ,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT4 = 05
    '000' SEGMENT5,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT5 = 00
    '219030' SEGMENT6,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00
    '00000' SEGMENT7,                                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01
    '000' SEGMENT8,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100
    '000' SEGMENT9,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00
    pts.TOTALVALUE ENTERED_DR ,   --  i.ENTERED_DR
    pts.TOTALVALUE ENTERED_CR ,   --  i.ENTERED_CR
    pts.TOTALVALUE ACCOUNTED_DR , --  i.ACCOUNTED_DR
    pts.TOTALVALUE ACCOUNTED_CR , --  i.ACCOUNTED_CR
    XXPBSA_GL_CURR_OPERIOD PERIOD_NAME , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )
    TO_CHAR(SYSDATE) REFERENCE1 ,      --  i.REFERENCE1
    'Control Account' REFERENCE2,     --  i.REFERENCE2
    'CONTROL' REFERENCE4 ,     --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  )
    'Control Account' REFERENCE5 --  i.REFERENCE5
  FROM CREDITCARDTRANSACTION@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ccs,
       PAYMENTSUMMARYRETURN@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ps,
       PAYMENTTYPESUMMARYRETURN@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG pts
  WHERE 1 = 1
        and ccs.TRANSACTIONID = ps.TRANSACTIONID
        and pts.PAYMENTTYPESID = ps.PAYMENTTYPESID
        and ps.status_flag is null
  )
GROUP BY PAYMENTTYPESID,
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
    (SELECT PAYMENTTYPESID,
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
  ( SELECT DISTINCT 0 PAYMENTTYPESID,
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
    '09100' SEGMENT2 ,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT2 = 01
    '00' SEGMENT3,                                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT3 = 01
    '00000' SEGMENT4 ,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT4 = 05
    '000' SEGMENT5,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT5 = 00
    '219030' SEGMENT6,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00
    '00000' SEGMENT7,                                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01
    '000' SEGMENT8,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100
    '000' SEGMENT9,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00
    CCS.AMOUNT ENTERED_DR ,   --  i.ENTERED_DR
    CCS.AMOUNT ENTERED_CR ,   --  i.ENTERED_CR
    CCS.AMOUNT ACCOUNTED_DR , --  i.ACCOUNTED_DR
    CCS.AMOUNT ACCOUNTED_CR , --  i.ACCOUNTED_CR
    XXPBSA_GL_CURR_OPERIOD PERIOD_NAME , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )
    ccs.CREDITCARDTYPE REFERENCE1 ,      --  i.REFERENCE1
    'Credit Card Account' REFERENCE2,     --  i.REFERENCE2
    'CREDIT CARD' REFERENCE4 ,     --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  )
    ccs.REFERENCENUMBER REFERENCE5 --  i.REFERENCE5
  FROM CREDITCARDTRANSACTION@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ccs,
       PAYMENTSUMMARYRETURN@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ps,
       PAYMENTTYPESUMMARYRETURN@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG pts
  WHERE 1 = 1
        and ccs.TRANSACTIONID = ps.TRANSACTIONID
        and pts.PAYMENTTYPESID = ps.PAYMENTTYPESID
        and ps.status_flag is null
  )
GROUP BY PAYMENTTYPESID,
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
  REFERENCE5)) glq
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