CREATE OR REPLACE PROCEDURE create_pay_sum_returns (p_data  IN  CLOB)
AS

  l_data           varchar2(20000);
  l_buffer         varchar2(32767);
  l_amount         number;
  l_offset         number;

BEGIN
    l_data := p_data;
    --l_data := '[{"date":"2018-06-04T00:00:00","products":[{"saleSummaryID":1,"date":"2018-06-04T00:00:00","productId":"d06bd7ed-6fe1-4a36-9050-d49d36966b71","partNumber":"000001","title":"Product One","avgCostEx":4.5455,"avgCostTax":0.4546,"unit":"Each","totalUnits":1.000,"totalValueEx":18.1800,"totalValueTax":1.8200}]}]';

   INSERT INTO paymentsummaryreturn (
                                      PAYMENTDATE,
                                      PaymentTypesID,
                                      TransactionId
                                      )
                        SELECT *
                        FROM 
                             JSON_TABLE(
                             l_data
                             , '$[*]' COLUMNS (
                              PAYMENTDATE varchar2(30) PATH '$.Date',
                                      NESTED PATH '$.CreditCardTransactions[*]' COLUMNS (
                                                   PaymentTypesID   number      PATH '$.TransactionId',                           
                                                   TransactionId   number      PATH '$.TransactionId'
                        )
                        
                        )) JT;
  
  INSERT INTO paymenttypesummaryreturn (
                                  PAYMENTTYPESID,
                                  PaymentType,
                                  TotalValue
                                 )
                        SELECT TransactionId,
                               PaymentType,
                               TotalValue
                        FROM 
                             JSON_TABLE(
                             l_data
                             , '$[*]' COLUMNS (
                             "Date" varchar2(30) PATH '$.Date'
                             ,NESTED PATH  '$.PaymentTypes[*]' COLUMNS (
                                                                        PaymentType   number      PATH '$.PaymentType',
                                                                        TotalValue   number       PATH '$.TotalValue'
                                                                        )
                             ,NESTED PATH '$.CreditCardTransactions[*]' COLUMNS (
                                                                                  TransactionId   number      PATH '$.TransactionId'
                                                                                )

                            )) JT;

  INSERT INTO CreditCardTransaction (
                                      TransactionId,
                                      CreditCardType,
                                      TransactionDate,
                                      Amount,
                                      ReferenceNumber
                                    )
                        SELECT TransactionId
                              ,CreditCardType
                              ,TransactionDate
                              ,Amount
                              ,ReferenceNumber
                        FROM 
                             JSON_TABLE(
                             l_data
                             , '$[*]' COLUMNS (
                              TransactionId1 varchar2(30) PATH '$.TransactionId',
                                      NESTED PATH '$.CreditCardTransactions[*]' COLUMNS (
                                                                              TransactionId   number      PATH '$.TransactionId',
                                                                              CreditCardType   varchar2(20)      PATH '$.CreditCardType',
                                                                              TransactionDate   varchar2(100)      PATH '$.TransactionDate',
                                                                              Amount   number      PATH '$.Amount',
                                                                              ReferenceNumber   number      PATH '$.ReferenceNumber'
                                                                              )
                        
                              )
                        ) JT;             


            
            COMMIT;
--
--  l_amount := 32000;
--  l_offset := 1;
--  
--        begin
--            loop
--                dbms_lob.read( l_clob, l_amount, l_offset, l_buffer );
--                htp.p(l_buffer);
--                l_offset := l_offset + l_amount;
--                l_amount := 32000;
--            end loop;
--        exception
--            when no_data_found then
--                DBMS_OUTPUT.put_line('Message: unsuccessful operation');c v
--            when others then
--                DBMS_OUTPUT.put_line(SQLERRM);
--        end;

END;