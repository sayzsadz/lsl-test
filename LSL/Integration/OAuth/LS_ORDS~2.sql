create table sales_summary_tbl (
                saleSummaryID   number(8),
                sale_date       date,
                productId       varchar(45),
                partNumber      varchar(20),
                title           varchar(50),
                avgCostEx       number(5,4),
                avgCostTax      number(5,4),
                unit            varchar(10),
                totalUnits      number(10),
                totalValueEx    number(10,2),
                totalValueTax   number(10,2)
                );