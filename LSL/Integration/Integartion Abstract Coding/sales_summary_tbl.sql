create table sales_summary_tbl (
                sales_date      varchar2(30),
                saleSummaryID   number(8),
                sale_date       varchar2(30),
                productId       varchar2(45),
                partNumber      varchar2(20),
                title           varchar2(50),
                avgCostEx       number(5,4),
                avgCostTax      number(5,4),
                unit            varchar2(10),
                totalUnits      number(10),
                totalValueEx    number(10,2),
                totalValueTax   number(10,2)
                );
                
                select *
                from sales_summary_tbl;
                
                drop table sales_summary_tbl;