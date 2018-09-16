CREATE OR REPLACE PROCEDURE create_till_reconciliations (p_data  IN  CLOB)
AS

  l_data           varchar2(20000);
  l_buffer         varchar2(32767);
  l_amount         number;
  l_offset         number;

BEGIN
    l_data := p_data;
    --l_data := '[{"date":"2018-06-04T00:00:00","products":[{"saleSummaryID":1,"date":"2018-06-04T00:00:00","productId":"d06bd7ed-6fe1-4a36-9050-d49d36966b71","partNumber":"000001","title":"Product One","avgCostEx":4.5455,"avgCostTax":0.4546,"unit":"Each","totalUnits":1.000,"totalValueEx":18.1800,"totalValueTax":1.8200}]}]';

   INSERT INTO TillReconciliationSummary (
                                "Date"      ,
                                PaymentType
                              )
                        SELECT *
FROM 
     JSON_TABLE(
     l_data
     , '$[*]' COLUMNS (
      "Date" varchar2(30) PATH '$.Date',
              NESTED PATH '$.PaymentTypes[*]' COLUMNS (
                           PaymentType   varchar2(40)    PATH '$.PaymentType'
              )

          )
      ) JT;


      INSERT INTO TillReconciliationSummaryLine (
                                PaymentType      ,
                                Difference
                              )
                        SELECT *
FROM 
     JSON_TABLE(
     l_data
     , '$[*]' COLUMNS (
      PaymentType varchar2(30) PATH '$.PaymentType',
      Difference  number PATH '$.Difference'
)) JT;      
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