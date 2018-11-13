select (prod.cat_seg1||prod.cat_seg2||prod.cat_seg3||prod.cat_seg4) catagory_description
      ,sum(ret_summary.price) + sum(ret_summary.price) total_sales
      ,sum(ret_summary.cost) + sum(ret_summary.cost) total_cost_sales
      ,(sum(ret_summary.price) + sum(ret_summary.price) - sum(ret_summary.cost) + sum(ret_summary.cost)) total_profitability
from      (select *
           from SALESSUMMARY ss
               ,SALESSUMMARYPRODUCT ssp
           where  1 = 1
                  and sal_ss.SALESUMMARYID = sal_ssp.SALESUMMARYID
                  and sal_ss.SALESUMMARYID = sal_ssp.SALESUMMARYID
                  and ret_rss.SALES_DATE = sal_ss.SALES_DATE
                  and sal_ssp.partnumber = rssp.partnumber
                  and sal_ss.storeid = rss.storeid
                  and sal_ss.storeid = :cost_center
                  and sal_SALES_DATE between (select START_DATE
                                          from gl_periods
                                          where PERIOD_NAME = :p_period) and (select END_DATE
                                                                              from gl_periods
                                                                              where PERIOD_NAME = :p_period)
                  and sal_SALES_DATE between :REP_DATE and :REP_DATE
                  and prod.segment1 = sal_ssp.partnumber
                  and (prod.cat_seg1||prod.cat_seg2||prod.cat_seg3||prod.cat_seg4) = :p_catagory
                  and STATUS_FLAG = 'P'
      ) sal_summary
     ,
     (     select *
           from  RETURNSSUMMARY rss
                ,RETURNSUMMARYPRODUCT rssp
           where  1 = 1
                  and rss.SALESUMMARYID = rssp.SALESUMMARYID
                  and rss.storeid = :cost_center
                  and rss.SALES_DATE between (select START_DATE
                                              from gl_periods
                                              where PERIOD_NAME = :p_period) and (select END_DATE
                                                                                  from gl_periods
                                                                                  where PERIOD_NAME = :p_period)
                  and rss.SALES_DATE between :REP_DATE and :REP_DATE
                  and prod.segment1 = rssp.partnumber
                  and (prod.cat_seg1||prod.cat_seg2||prod.cat_seg3||prod.cat_seg4) = :p_catagory
                  and STATUS_FLAG = 'P'
     ) ret_summary
     ,( SELECT distinct UPPER(mc.segment1) cat_seg1, UPPER(mc.segment2) cat_seg2, UPPER(mc.segment3) cat_seg3, UPPER(mc.segment4) cat_seg4, msi.segment1
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
              AND msi.organization_id = 101
        ) prod
where 1 = 1
      and sal_summary.SALES_DATE = ret_summary.SALES_DATE
      and sal_summary.partnumber = ret_summary.partnumber
      
      
      