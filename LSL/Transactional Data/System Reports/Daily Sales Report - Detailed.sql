select pay_taking.mode_settlement
      ,(pay_taking.dialy_collection - pay_return.dialy_collection) dialy_collection
      ,(pay_taking.ptd - pay_return.ptd) ptd
      ,(pay_taking.ytd - pay_return.ytd) ytd
from (
        select pts.PAYMENTTYPE mode_settlement
              ,sum(pts.TOTALVALUE) dialy_collection
              ,sum(pay_ptd.TOTALVALUE) ptd
              ,sum(pay_ptd.TOTALVALUE) ytd
        from  PAYMENTSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ps
             ,PAYMENTTYPESUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG pts
             ,(select pts.TOTALVALUE
               from  PAYMENTSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ps
                    ,PAYMENTTYPESUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG pts
               where 1 = 1
                     --and ps.date between :p_period_from-startdate and :REP_DATE
                     and ps.PAYMENTDATE between (
                                                  select START_DATE
                                                  from gl_periods
                                                  where PERIOD_NAME = to_char(to_date(:REP_DATE), 'MON-RRRR')
                                                ) and :REP_DATE
                     and ps.PAYMENTTYPESID between :p_store_from and :p_store_to
                     and pts.PAYMENTTYPE = :p_payment_type
              ) pay_ptd
              ,(select pts.TOTALVALUE
               from  PAYMENTSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ps
                    ,PAYMENTTYPESUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG pts
               where 1 = 1
                     --and ps.date between :p_period_from-yearstartdate and :REP_DATE
                     and ps.PAYMENTDATE  between (
                                                   select distinct YEAR_START_DATE
                                                   from gl_periods
                                                   where PERIOD_YEAR = to_char(to_date(:REP_DATE), 'RRRR')
                                                 ) and :REP_DATE
                     and ps.PAYMENTTYPESID between :p_store_from and :p_store_to
                     and pts.PAYMENTTYPE = :p_payment_type
              ) pay_ytd
        where 1 = 1
              and ps.PAYMENTTYPESID = pts.PAYMENTTYPESID
              and ps.PAYMENTDATE between :p_period_from and :p_period_to
              and ps.PAYMENTTYPESID between :p_store_from and :p_store_to
              and pts.PAYMENTTYPE = :p_payment_type
              and ps.PAYMENTDATE between :REP_DATE and :REP_DATE
        group by pts.PAYMENTTYPE
     ) pay_taking
     ,(
             select pts.PAYMENTTYPE mode_settlement
              ,sum(pts.TOTALVALUE) dialy_collection
              ,sum(pay_ptd.TOTALVALUE) ptd
              ,sum(pay_ptd.TOTALVALUE) ytd
        from  PAYMENTSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ps
             ,PAYMENTTYPESUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG pts
             ,(select pts.TOTALVALUE
               from  PAYMENTSUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ps
                    ,PAYMENTTYPESUMMARY@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG pts
               where 1 = 1
                     and ps.PAYMENTDATE between (
                                                  select START_DATE
                                                  from gl_periods
                                                  where PERIOD_NAME = to_char(to_date(:REP_DATE), 'MON-RRRR')
                                                ) and :REP_DATE
                     and ps.PAYMENTTYPESID between :p_store_from and :p_store_to
                     and pts.PAYMENTTYPE = :p_payment_type
              ) pay_ptd
              ,(select pts.TOTALVALUE
               from  PAYMENTSUMMARYRETURN@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ps
                    ,PAYMENTTYPESUMMARYRETURN@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG pts
               where 1 = 1
                     and ps.PAYMENTDATE between (
                                                  select distinct YEAR_START_DATE
                                                  from gl_periods
                                                  where PERIOD_YEAR = to_char(to_date(:REP_DATE), 'RRRR')
                                                ) and :REP_DATE
                     and ps.PAYMENTTYPESID between :p_store_from and :p_store_to
                     and pts.PAYMENTTYPE = :p_payment_type
              ) pay_ytd
        where 1 = 1
              and ps.PAYMENTTYPESID = pts.PAYMENTTYPESID
              and ps.PAYMENTDATE between :p_period_from and :p_period_to
              and ps.PAYMENTTYPESID between :p_store_from and :p_store_to
              and pts.PAYMENTTYPE = :p_payment_type
              and ps.PAYMENTDATE between :REP_DATE and :REP_DATE
        group by pts.PAYMENTTYPE
      ) pay_return
where 1 = 1;