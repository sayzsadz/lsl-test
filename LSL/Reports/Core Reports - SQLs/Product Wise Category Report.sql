select summary1.cat_seg catagory_description
      ,sum(summary1.TOTALVALUEEX) + sum(summary1.TOTALVALUEEX) total_sales
      ,sum(summary1.AVGCOSTEX) + sum(summary1.AVGCOSTEX) total_cost_sales
      ,(NVL(sum(summary1.TOTALVALUEEX), 0) + NVL(sum(summary1.TOTALVALUEEX), 0) - NVL(sum(summary1.AVGCOSTEX), 0) + NVL(sum(summary1.AVGCOSTEX), 0)) total_profitability
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
      ,TOTALVALUEEX
      ,AVGCOSTEX
      ,NVL(CAST(TO_TIMESTAMP_TZ(REPLACE(SALES_DATE, 'T', ''), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') AS DATE), SYSTIMESTAMP) SALES_DATE
from 
(
select distinct prod.cat_seg
      ,NVL(ret_summary.TOTALVALUEEX, 0) TOTALVALUEEX
      ,NVL(ret_summary.AVGCOSTEX, 0) AVGCOSTEX
      ,ret_summary.SALES_DATE
from (     
           select rssp.partnumber, rssp.SALES_DATE, sum(rssp.TOTALVALUEEX) TOTALVALUEEX, sum(rssp.TOTALUNITS) TOTALUNITS, sum(rssp.AVGCOSTTAX) AVGCOSTTAX, sum(rssp.AVGCOSTEX) AVGCOSTEX
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
                  and CAST(TO_TIMESTAMP_TZ(REPLACE(rssp.SALES_DATE, 'T', ''), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') AS DATE) between (select START_DATE
                                                                                                                                     from gl_periods
                                                                                                                                     where PERIOD_NAME = :p_period
                                                                                                                                           and PERIOD_SET_NAME = 'LSL_NEW') and (select END_DATE
                                                                                                                                                                                 from gl_periods
                                                                                                                                                                                 where PERIOD_NAME = :p_period
                                                                                                                                                                                       and PERIOD_SET_NAME = 'LSL_NEW')
                   and CAST(TO_TIMESTAMP_TZ(REPLACE(rssp.SALES_DATE, 'T', ''), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') AS DATE) between  (select START_DATE
                                                                                                                                       from gl_periods
                                                                                                                                       where PERIOD_NAME = :p_period
                                                                                                                                             and PERIOD_SET_NAME = 'LSL_NEW') and (select END_DATE
                                                                                                                                                                                   from gl_periods
                                                                                                                                                                                   where PERIOD_NAME = :p_period
                                                                                                                                                                                         and PERIOD_SET_NAME = 'LSL_NEW')
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
      and prod.segment1 = ret_summary.partnumber(+)
) 
) summary1
where 1 = 1
      and td.code_combination_id = cat_seg.code_combination_id
      and td.PERIOD_NAME = :p_period
      and summary1.cat_seg = cat_seg.cat
      and summary1.SALES_DATE between   (select START_DATE
                                         from gl_periods
                                         where PERIOD_NAME = :p_period
                                               and PERIOD_SET_NAME = 'LSL_NEW') and (select END_DATE
                                                                                     from gl_periods
                                                                                     where PERIOD_NAME = :p_period
                                                                                           and PERIOD_SET_NAME = 'LSL_NEW')
group by summary1.cat_seg
;