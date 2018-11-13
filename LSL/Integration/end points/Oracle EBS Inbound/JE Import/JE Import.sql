CREATE OR REPLACE PROCEDURE XXPBSA_JE_INTERFACE_SALES_SUM(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2) 
IS        
        cursor cur
        is

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
                ||'.'||segment9 = XXPBSA_GET_GL_ACCOUNT('Lanka Sathosa Ltd.Ampara.Unspecified.Biscuits.Unspecified.Sales - Grocery Products.Unspecified.Unspecified') THEN
    ENTERED_CR
  ELSE 0
  END) ENTERED_CR ,
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
                ||'.'||segment9 = XXPBSA_GET_GL_ACCOUNT('Lanka Sathosa Ltd.Ampara.Unspecified.Biscuits.Unspecified.Sales - Grocery Products.Unspecified.Unspecified') THEN
    0
  ELSE ENTERED_DR
  END) ENTERED_DR,
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
                ||'.'||segment9 = XXPBSA_GET_GL_ACCOUNT('Lanka Sathosa Ltd.Ampara.Unspecified.Biscuits.Unspecified.Sales - Grocery Products.Unspecified.Unspecified') THEN
    ACCOUNTED_CR
  ELSE 0
  END) ACCOUNTED_CR,
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
                ||'.'||segment9 = XXPBSA_GET_GL_ACCOUNT('Lanka Sathosa Ltd.Ampara.Unspecified.Biscuits.Unspecified.Sales - Grocery Products.Unspecified.Unspecified') THEN
    0
  ELSE ACCOUNTED_DR
  END) ACCOUNTED_DR,
  PERIOD_NAME,
  REFERENCE1,
  REFERENCE2,
  REFERENCE4,
  REFERENCE5
FROM
  (
  ( SELECT DISTINCT ss.SALESUMMARYID,
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
    '11401' SEGMENT4 ,                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT4 = 05
    '000' SEGMENT5,                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT5 = 00
    '301200' SEGMENT6,                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00
    '00000' SEGMENT7,                    --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01
    '000' SEGMENT8,                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100
    '000' SEGMENT9,                      --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00
    SSP.TOTALVALUEEX + SSP.TOTALVALUETAX ENTERED_DR ,        --  i.ENTERED_DR
    SSP.TOTALVALUEEX + SSP.TOTALVALUETAX ENTERED_CR ,        --  i.ENTERED_CR
    SSP.TOTALVALUEEX + SSP.TOTALVALUETAX ACCOUNTED_DR ,      --  i.ACCOUNTED_DR
    SSP.TOTALVALUEEX + SSP.TOTALVALUETAX ACCOUNTED_CR ,      --  i.ACCOUNTED_CR
    XXPBSA_GL_CURR_OPERIOD PERIOD_NAME , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )
    SYSDATE REFERENCE1 ,                 --  i.REFERENCE1
    SSP.TITLE REFERENCE2,                --  i.REFERENCE2
    'INSERT' REFERENCE4 ,                --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  )
    ssp.partnumber REFERENCE5            --  i.REFERENCE5
  FROM SALESSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ss ,
    SALESSUMMARYPRODUCT@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ssp
  WHERE ss.SALESUMMARYID = ssp.SALESUMMARYID
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
  ( SELECT DISTINCT 0 SALESUMMARYID,
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
    '11401' SEGMENT4 ,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT4 = 05
    '000' SEGMENT5,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT5 = 00
    '219030' SEGMENT6,                                  --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00
    '00000' SEGMENT7,                                   --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01
    '000' SEGMENT8,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100
    '000' SEGMENT9,                                     --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00
    SSP.TOTALVALUEEX + SSP.TOTALVALUETAX ENTERED_DR ,   --  i.ENTERED_DR
    SSP.TOTALVALUEEX + SSP.TOTALVALUETAX ENTERED_CR ,   --  i.ENTERED_CR
    SSP.TOTALVALUEEX + SSP.TOTALVALUETAX ACCOUNTED_DR , --  i.ACCOUNTED_DR
    SSP.TOTALVALUEEX + SSP.TOTALVALUETAX ACCOUNTED_CR , --  i.ACCOUNTED_CR
    XXPBSA_GL_CURR_OPERIOD PERIOD_NAME , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )
    SYSDATE REFERENCE1 ,      --  i.REFERENCE1
    'Control Account' REFERENCE2,     --  i.REFERENCE2
    'CONTROL' REFERENCE4 ,     --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  )
    'Control Account' REFERENCE5 --  i.REFERENCE5
  FROM SALESSUMMARY ss ,
    SALESSUMMARYPRODUCT ssp
  WHERE ss.SALESUMMARYID = ssp.SALESUMMARYID
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
  REFERENCE5)) glq
WHERE 1 = 1;

     
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