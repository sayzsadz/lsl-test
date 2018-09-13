CREATE OR REPLACE PROCEDURE XXPBSA_JE_INTERFACE IS
BEGIN
/*
SELECT * FROM GL_INTERFACE
MANDATORY FIELDS 

            STATUS 
            ACCOUNTING_DATE 
            CURRENCY_CODE 
            DATE_CREATED 
            CREATED_BY 
            ACTUAL_FLAG 
            USER_JE_CATEGORY_NAME 
            USER_JE_SOURCE_NAME 
*/
 -- GL > JOURNALS  >   IMPORT   >  RUN   
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
                          'Addition'                , --  SELECT USER_JE_CATEGORY_NAME FROM GL_JE_CATEGORIES WHERE USER_JE_CATEGORY_NAME LIKE 'SSE%'       
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
                         '11'                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT1 = 02   
                         '09100'                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT2 = 01  
                         '00'                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT3 = 01   
                         '00000'                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT4 = 05   
                         '000'                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT5 = 00   
                         '191400'                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT6 = 00   
                         '00000'                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT7 = 01   
                         '000'                     , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT8 = 981100  
                         '000'                         , --  SELECT * FROM GL_CODE_COMBINATIONS_KFV WHERE SEGMENT9 = 00   
                          2300                        , --  i.ENTERED_DR                           
                          2300                        , --  i.ENTERED_CR                           
                          2300                        , --  i.ACCOUNTED_DR                         
                          2300                        , --  i.ACCOUNTED_CR                         
                          'Dec-17'                    , --  i.PERIOD_NAME     (PERIOD SHOULD BE OPEN )                         
                          SYSDATE                     , --  i.REFERENCE1                        
                          'INSERTED BY CUSTOM GL INT' , --  i.REFERENCE2                          
                          'INSERT'                    , --  i.REFERENCE4     ( REFERENCE4   it takes in JE NAME  ) 
                          'SSE'                         --  i.REFERENCE5                   
                         );
END;
/
begin
XXPBSA_JE_INTERFACE;
end;
/