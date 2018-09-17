CREATE OR REPLACE PROCEDURE create_deliveries_summary (p_data  IN  CLOB)
AS

  l_data           varchar2(20000);
  l_buffer         varchar2(32767);
  l_amount         number;
  l_offset         number;

BEGIN
    l_data := p_data;
    --l_data := '[{"date":"2018-06-04T00:00:00","products":[{"saleSummaryID":1,"date":"2018-06-04T00:00:00","productId":"d06bd7ed-6fe1-4a36-9050-d49d36966b71","partNumber":"000001","title":"Product One","avgCostEx":4.5455,"avgCostTax":0.4546,"unit":"Each","totalUnits":1.000,"totalValueEx":18.1800,"totalValueTax":1.8200}]}]';

   INSERT INTO deliverysummary (
                                DeliveryId      ,
                                PurchaseOrderID   ,
                                ExternalReferenceNumber       ,
                                "Date"       ,
                                Freight      ,
                                FreightTax           ,
                                SupplierId
                              )
                        SELECT *
FROM 
     JSON_TABLE(
     l_data
     , '$[*]' COLUMNS (
      DeliveryId number PATH '$.DeliveryId',
      PurchaseOrderID number PATH '$.PurchaseOrderID',
      ExternalReferenceNumber varchar2(30) PATH '$.ExternalReferenceNumber',
      "Date" varchar2(30) PATH '$.Date',
      Freight number PATH '$.Freight',
      FreightTax number PATH '$.FreightTax',
      SupplierId number PATH '$.SupplierId'
)) JT;
   
   INSERT INTO deliverysummaryline (
                                DeliveryId      ,
                                DeliveryDetailId   ,
                                ProductId       ,
                                Title       ,
                                Quantity      ,
                                Unit           ,
                                PerUnitCost       ,
                                PerUnitCostTax      ,
                                LineTotalCost            ,
                                LineTotalCostTax 
                              )
                        SELECT *
FROM 
     JSON_TABLE(
     l_data
     , '$[*]' COLUMNS (
      DeliveryId varchar2(30) PATH '$.DeliveryId',
              NESTED PATH '$.products[*]' COLUMNS (
                           
                           DeliveryDetailId   number      PATH '$.DeliveryDetailId',
                                          ProductId       varchar2(30)        PATH '$.ProductId',
                                          Title       varchar2(300)    PATH '$.Title',
                                          Quantity      varchar2(300)    PATH '$.Quantity',
                                          Unit           varchar2(300)    PATH '$.Unit',
                                          PerUnitCost       number      PATH '$.PerUnitCost',
                                          PerUnitCostTax      number      PATH '$.PerUnitCostTax',
                                          LineTotalCost            varchar(300)     PATH '$.LineTotalCost',
                                          LineTotalCostTax      number      PATH '$.LineTotalCostTax'
)

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