declare
        id sales_summary.saleSummaryID%type;
begin
insert into sales_summary (
                saleSummaryID,
                sale_date,
                productId,
                partNumber,
                title,
                avgCostEx,
                avgCostTax,
                unit,
                totalUnits,
                totalValueEx,
                totalValueTax
                ) values 
                (
                :saleSummaryID,
                :sale_date,
                :productId,
                :partNumber,
                :title,
                :avgCostEx,
                :avgCostTax,
                :unit,
                :totalUnits,
                :totalValueEx,
                :totalValueTax
                );
  
  RETURNING saleSummaryID INTO id;
  :location := id;
  :status := 201;
    
end;