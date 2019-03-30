select distinct summary1.CAT_SEG, summary1.GROSS_SALES, summary1.TAXES, summary1.NET_SALES, sum(td.PTD) PTD, sum(td.YTD) YTD
from
(
SELECT   distinct gb.code_combination_id,
         gb.PERIOD_NAME,
         NVL (gb.PERIOD_NET_DR, 0) - NVL (gb.PERIOD_NET_CR, 0) PTD,
         (NVL (gb.BEGIN_BALANCE_DR, 0) - NVL (gb.BEGIN_BALANCE_CR, 0)) + (NVL (gb.PERIOD_NET_DR, 0) - NVL (gb.PERIOD_NET_CR, 0)) YTD
FROM  gl_balances gb,
      gl_ledgers gl,
      gl_code_combinations_kfv glcc,
      APPS.FND_FLEX_VALUES_VL FFV
WHERE  gb.code_combination_id = glcc.code_combination_id
      AND gb.LEDGER_ID = gl.ledger_id
      AND GLCC.SEGMENT3 = FFV.FLEX_VALUE
      AND gl.NAME = 'LSL Ledger'
      AND gb.period_name = :p_period
) td
,
(
        SELECT distinct UPPER(mc.segment1||'.'||mc.segment2||'.'||mc.segment3||'.'||mc.segment4) cat
              ,gcc.code_combination_id
        FROM  mtl_item_categories mic,
              mtl_category_sets_tl mcst,
              mtl_category_sets_b mcs,
              mtl_categories_b_kfv mc,
              mtl_system_items_b msi,
              GL_CODE_COMBINATIONS gcc
        WHERE mic.category_set_id       = mcs.category_set_id
              AND mcs.category_set_id   = mcst.category_set_id
              AND mcst.LANGUAGE         = USERENV ('LANG')
              AND mic.category_id       = mc.category_id     
              AND msi.organization_id   = mic.organization_id    
              AND msi.inventory_item_id = mic.inventory_item_id
              AND gcc.end_date_active is null
) cat_seg
,
(
select cat_seg
      ,ptd
      ,ytd
      ,gross_sales
      ,taxes
      ,net_sales
      ,SALES_DATE
from 
(
select distinct prod.cat_seg
      ,'ptd' ptd
      ,'ytd' ytd
      ,(NVL(sal_summary.TOTALVALUEEX, 0)) + (NVL(ret_summary.TOTALVALUEEX, 0)) gross_sales--CS
      ,((NVL(sal_summary.AVGCOSTTAX, 0) * nvl(sal_summary.TOTALUNITS,0)) + (NVL(ret_summary.AVGCOSTTAX, 0) * nvl(ret_summary.TOTALUNITS, 0))) taxes--CS
      ,((NVL(sal_summary.TOTALVALUEEX, 0) + NVL(sal_summary.AVGCOSTTAX, 0) * nvl(sal_summary.TOTALUNITS,0)) + (NVL(ret_summary.TOTALVALUEEX, 0) + NVL(ret_summary.AVGCOSTTAX,0) * nvl(ret_summary.TOTALUNITS, 0))) net_sales--CS
      ,sal_summary.SALES_DATE
from  (
           select ssp.partnumber, ssp.SALES_DATE, SUM(ssp.TOTALVALUEEX) TOTALVALUEEX, SUM(ssp.TOTALUNITS) TOTALUNITS, SUM(ssp.AVGCOSTEX) AVGCOSTEX, SUM(ssp.AVGCOSTTAX) AVGCOSTTAX
           from SALESSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ss
               ,SALESSUMMARYPRODUCT@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ssp
           where  1 = 1
                  and ss.SALESUMMARYID = ssp.SALESUMMARYID
                  and ss.storeid in    (
                                        SELECT NVL(ffv.ATTRIBUTE9, '11') storeid
                                        FROM   fnd_flex_values ffv
                                              ,fnd_flex_values_tl ffvt
                                        WHERE  ffv.flex_value_id = ffvt.flex_value_id
                                               AND ffv.flex_value_set_id = 1017028
                                               AND ffv.flex_value = '11000'--needs to modify
                                               AND ffv.attribute2 is null
                                               AND ffv.flex_value = :cost_center
                                        )
                   and CAST(TO_TIMESTAMP_TZ(REPLACE(ss.SALES_DATE, 'T', ''), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') AS DATE) between (select YEAR_START_DATE
                                                                                                                                 from GL_PERIOD_STATUSES gl
                                                                                                                                 where PERIOD_NAME = :p_period
                                                                                                                                       and gl.application_id = 101) and (select add_months( to_date(YEAR_START_DATE), 12 ) YEAR_END_DATE
                                                                                                                                                                         from GL_PERIOD_STATUSES gl
                                                                                                                                                                         where PERIOD_NAME = :p_period
                                                                                                                                                                               and gl.application_id = 101)
                  --and CAST(TO_TIMESTAMP_TZ(REPLACE(ss.SALES_DATE, 'T', ''), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') AS DATE) between NVL(:REP_DATE, CAST(TO_TIMESTAMP_TZ(REPLACE(ss.SALES_DATE, 'T', ''), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') AS DATE)) and NVL(:REP_DATE, CAST(TO_TIMESTAMP_TZ(REPLACE(ss.SALES_DATE, 'T', ''), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') AS DATE))
                  --and STATUS_FLAG = 'P'
                  and storeid = 11
            group by ssp.partnumber, ssp.SALES_DATE
      ) sal_summary
     ,
     (     
           select rssp.partnumber, rssp.SALES_DATE, sum(rssp.TOTALVALUEEX) TOTALVALUEEX, sum(rssp.TOTALUNITS) TOTALUNITS, sum(rssp.AVGCOSTEX) AVGCOSTEX, sum(rssp.AVGCOSTTAX) AVGCOSTTAX
           from  RETURNSSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG rss
                ,RETURNSUMMARYPRODUCT@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG rssp
           where  1 = 1
                  and rss.SALESUMMARYID = rssp.SALESUMMARYID
                  and rss.storeid in   (
                                        SELECT NVL(ffv.ATTRIBUTE9, '11') storeid
                                        FROM   fnd_flex_values ffv
                                              ,fnd_flex_values_tl ffvt
                                        WHERE  ffv.flex_value_id = ffvt.flex_value_id
                                               AND ffv.flex_value_set_id = 1017028
                                               AND ffv.flex_value = '11000'--needs to modify
                                               AND ffv.attribute2 is null
                                               AND ffv.flex_value = :cost_center
                                        )
                  and CAST(TO_TIMESTAMP_TZ(REPLACE(rssp.SALES_DATE, 'T', ''), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') AS DATE) between (select YEAR_START_DATE
                                                                                                                                 from GL_PERIOD_STATUSES gl
                                                                                                                                 where PERIOD_NAME = :p_period
                                                                                                                                       and gl.application_id = 101) and (select add_months( to_date(YEAR_START_DATE), 12 ) YEAR_END_DATE
                                                                                                                                                                         from GL_PERIOD_STATUSES gl
                                                                                                                                                                         where PERIOD_NAME = :p_period
                                                                                                                                                                               and gl.application_id = 101)
                  --and CAST(TO_TIMESTAMP_TZ(REPLACE(rss.SALES_DATE, 'T', ''), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') AS DATE) between NVL(:REP_DATE, CAST(TO_TIMESTAMP_TZ(REPLACE(rss.SALES_DATE, 'T', ''), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') AS DATE)) and NVL(:REP_DATE, CAST(TO_TIMESTAMP_TZ(REPLACE(rss.SALES_DATE, 'T', ''), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') AS DATE))
                  --and STATUS_FLAG = 'P'
                  and storeid = 11
         group by rssp.partnumber, rssp.SALES_DATE
     ) ret_summary
     ,( 
        SELECT distinct msi.segment1, UPPER(mc.segment1||'.'||mc.segment2||'.'||mc.segment3||'.'||mc.segment4) cat_seg
        FROM  mtl_item_categories mic,
              mtl_category_sets_tl mcst,
              mtl_category_sets_b mcs,
              mtl_categories_b_kfv mc,
              mtl_system_items_b msi
        WHERE mic.category_set_id = mcs.category_set_id
              AND mcs.category_set_id   = mcst.category_set_id
              AND mcst.LANGUAGE         = USERENV ('LANG')
              AND mic.category_id       = mc.category_id     
              AND msi.organization_id = mic.organization_id    
              AND msi.inventory_item_id = mic.inventory_item_id
              AND msi.organization_id = 102
              AND msi.segment1 = '171321'
        ) prod
where 1 = 1
      and cat_seg = :p_catagory
      and prod.segment1 = sal_summary.partnumber(+)
      and prod.segment1 = ret_summary.partnumber(+)
) 
) summary1
where 1 = 1
      and td.code_combination_id = cat_seg.code_combination_id
      and td.PERIOD_NAME = :p_period
      and summary1.cat_seg = cat_seg.cat
      and CAST(TO_TIMESTAMP_TZ(REPLACE(summary1.SALES_DATE, 'T', ''), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') AS DATE) between (select START_DATE
                                                                                                                         from gl_periods
                                                                                                                         where PERIOD_NAME = :p_period
                                                                                                                               and PERIOD_SET_NAME = 'LSL_NEW') and (select END_DATE
                                                                                                                                                                     from gl_periods
                                                                                                                                                                     where PERIOD_NAME = :p_period
                                                                                                                                                                           and PERIOD_SET_NAME = 'LSL_NEW')
       and CAST(TO_TIMESTAMP_TZ(REPLACE(summary1.SALES_DATE, 'T', ''), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') AS DATE) between  (select START_DATE
                                                                                                                           from gl_periods
                                                                                                                           where PERIOD_NAME = :p_period
                                                                                                                                 and PERIOD_SET_NAME = 'LSL_NEW') and (select END_DATE
                                                                                                                                                                       from gl_periods
                                                                                                                                                                       where PERIOD_NAME = :p_period
                                                                                                                                                                             and PERIOD_SET_NAME = 'LSL_NEW')
group by summary1.CAT_SEG, summary1.GROSS_SALES, summary1.TAXES, summary1.NET_SALES;