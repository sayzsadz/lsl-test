CREATE OR REPLACE PROCEDURE XXPBSA_JE_INTERFACE_SALES_PAY
IS

     L_SEGMENT1 number;
     L_SEGMENT2 number;
     L_SEGMENT3 number;
     L_SEGMENT4 number;
     L_SEGMENT5 number;
     L_SEGMENT6 number;
     L_SEGMENT7 number;
     L_SEGMENT8 number;
     L_SEGMENT9 number;
        
        cursor cur
        is
        select  2021                        LEDGER_ID, --  SELECT * FROM GL_SETS_OF_BOOKS 
                'Y'                         STATUS, --  i.STATUS                                                          
                2021                        SET_OF_BOOKS_ID, --  SELECT * FROM GL_SETS_OF_BOOKS      (Trading Companies SOB) 
                'Manual'                    USER_JE_SOURCE_NAME, --  SELECT * FROM GL_JE_SOURCES WHERE JE_SOURCE_NAME LIKE 'Manual'         
                'Adjustment'                USER_JE_CATEGORY_NAME, --  SELECT USER_JE_CATEGORY_NAME FROM GL_JE_CATEGORIES WHERE USER_JE_CATEGORY_NAME LIKE 'SSE%'       
                ss.SALEDATE                 ACCOUNTING_DATE, --  i.ACCOUNTING_DATE     
                'LKR'                       CURRENCY_CODE, --  i.CURRENCY_CODE  
                ss.SALEDATE                 DATE_CREATED, --  DATE_CREATED   
                0                           user_id,--  fnd_global.user_id  
                'A'                         ACTUAL_FLAG, --  i.ACTUAL_FLAG    -- A  Actual , B – Budget E – Encumbrance  
            --  i.ENCUMBRANCE_TYPE_ID       ,      
            --  i.BUDGET_VERSION_ID         ,        
                ''                          USER_CURRENCY_CONVERSION_TYPE, --  i.USER_CURRENCY_CONVERSION_TYPE        
                ''                          CURRENCY_CONVERSION_DATE, --  i.CURRENCY_CONVERSION_DATE   
                ''                          CURRENCY_CONVERSION_RATE, --  i.CURRENCY_CONVERSION_RATE    
               '00'                         SEGMENT1, --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT1 = 02   
               '00000'                      SEGMENT2   , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT2 = 01  
               '00'                         SEGMENT3, --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT3 = 01   
               '00000'                      SEGMENT4   , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT4 = 05   
               '000'                        SEGMENT5, --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT5 = 00   
               '000000'                     SEGMENT6, --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00   
               '00000'                      SEGMENT7, --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01   
               '000'                        SEGMENT8, --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100  
               '000'                        SEGMENT9, --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00   
                SSP.TOTALVALUEEX   ENTERED_DR                     , --  i.ENTERED_DR                           
                SSP.TOTALVALUEEX   ENTERED_CR                     , --  i.ENTERED_CR                           
                SSP.TOTALVALUEEX   ACCOUNTED_DR                     , --  i.ACCOUNTED_DR                         
                SSP.TOTALVALUEEX   ACCOUNTED_CR                     , --  i.ACCOUNTED_CR                         
                XXPBSA_GL_CURR_OPERIOD  PERIOD_NAME                  , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )                         
                SYSDATE   REFERENCE1                  , --  i.REFERENCE1                        
                SSP.TITLE REFERENCE2, --  i.REFERENCE2                          
                'INSERT'               REFERENCE4     , --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  ) 
                ssp.partnumber         REFERENCE5                --  i.REFERENCE5
                from SALESSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ss
                    ,SALESSUMMARYPRODUCT@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ssp
                where ss.PRODUCTID = ssp.PRODUCTID;

     
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
                          2021                        , --  SELECT * FROM GL_SETS_OF_BOOKS 
                          'Y'                         , --  i.STATUS                                                          
                          2021                        , --  SELECT * FROM GL_SETS_OF_BOOKS      (Trading Companies SOB) 
                          'Manual'                    , --  SELECT * FROM GL_JE_SOURCES WHERE JE_SOURCE_NAME LIKE 'Manual'         
                          'Adjustment'                , --  SELECT USER_JE_CATEGORY_NAME FROM GL_JE_CATEGORIES WHERE USER_JE_CATEGORY_NAME LIKE 'SSE%'       
                          SYSDATE                     , --  i.ACCOUNTING_DATE     
                          'LKR'                       , --  i.CURRENCY_CODE  
                          sysdate                     , --  DATE_CREATED   
                          0                        , --  fnd_global.user_id  
                          'A'                         , --  i.ACTUAL_FLAG    -- A  Actual , B – Budget E – Encumbrance  
                      --  i.ENCUMBRANCE_TYPE_ID       ,      
                      --  i.BUDGET_VERSION_ID         ,        
                          ''                          , --  i.USER_CURRENCY_CONVERSION_TYPE        
                          ''                          , --  i.CURRENCY_CONVERSION_DATE   
                          ''                          , --  i.CURRENCY_CONVERSION_RATE    
                         L_SEGMENT1                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT1 = 02   
                         L_SEGMENT2                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT2 = 01  
                         L_SEGMENT3                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT3 = 01   
                         L_SEGMENT4                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT4 = 05   
                         L_SEGMENT5                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT5 = 00   
                         L_SEGMENT6                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00   
                         L_SEGMENT7                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01   
                         L_SEGMENT8                     , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100  
                         L_SEGMENT9                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00   
                          12                        , --  i.ENTERED_DR                           
                          12                        , --  i.ENTERED_CR                           
                          12                        , --  i.ACCOUNTED_DR                         
                          12                        , --  i.ACCOUNTED_CR                         
                          'Jan-17'                    , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )                         
                          SYSDATE                     , --  i.REFERENCE1                        
                          'INSERTED BY CUSTOM GL INT' , --  i.REFERENCE2                          
                          'INSERT'                    , --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  ) 
                          'SSE'                         --  i.REFERENCE5                   
                         );
 end loop;
END;
/

begin
XXPBSA_JE_INTERFACE;
XXPBSA_REQ_JE_IMPORT()
end;
/