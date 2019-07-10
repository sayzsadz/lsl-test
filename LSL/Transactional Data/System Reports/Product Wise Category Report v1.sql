
select cat catagory_description, pbsasales total_sales, pbsacos total_cost_sales, (pbsasales - pbsacos) total_profitability
from
(
select pbsasales.RUNNING_TOTAL_DR pbsasales, pbsacos.RUNNING_TOTAL_DR pbsacos, pbsasales.segment1||'.'||pbsasales.segment2||'.'||pbsasales.segment3||'.'||pbsasales.segment4 cat
from
     (
     
     select distinct ENTERED_CR RUNNING_TOTAL_DR, cat.segment1, cat.segment2, cat.segment3, cat.segment4
     from gl_je_headers gh,
          gl_je_lines gl,
          gl_code_combinations gcc,
          (
                SELECT distinct fv.description cat, flex_value, mc.segment1, mc.segment2, mc.segment3, mc.segment4
                FROM  mtl_item_categories mic,
                      mtl_category_sets_tl mcst,
                      mtl_category_sets_b mcs,
                      mtl_categories_b_kfv mc,
                      mtl_system_items_b msi,
                      (
                        SELECT ffv.flex_value, upper(ffvt.description) description
                        FROM   fnd_flex_values ffv
                              ,fnd_flex_values_tl ffvt
                        WHERE  ffv.flex_value_id = ffvt.flex_value_id
                               AND ffv.flex_value_set_id = 1017030
                      ) fv
                WHERE mic.category_set_id       = mcs.category_set_id
                      AND mcs.category_set_id   = mcst.category_set_id
                      AND mic.category_id       = mc.category_id     
                      AND msi.organization_id   = mic.organization_id    
                      AND msi.inventory_item_id = mic.inventory_item_id
                      AND upper(mc.segment4) = fv.description
                      
                ) cat
     where gh.JE_HEADER_ID = gl.JE_HEADER_ID
           and gh.PERIOD_NAME = :p_period
           and JE_CATEGORY in (
               select JE_CATEGORY_NAME
               from gl_je_categories_tl
               where USER_JE_CATEGORY_NAME = 'PBSA_Sales'
           )
           
           and (:p_cat1 is null or UPPER(:p_cat1) = UPPER(cat.segment1))
           and (:p_cat2 is null or UPPER(:p_cat2) = UPPER(cat.segment2))
           and (:p_cat3 is null or UPPER(:p_cat3) = UPPER(cat.segment3))
           and (:p_cat4 is null or UPPER(:p_cat4) = UPPER(cat.segment4))

           and gl.code_combination_id = gcc.code_combination_id
           and DATE_CREATED between (:p_date_from) and (:p_date_to)
           AND gcc.segment4 = cat.flex_value
           and gcc.segment2 = :p_seg2
           and gcc.segment6 in (
                    SELECT ffv.flex_value
                    FROM fnd_flex_values ffv
                        ,fnd_flex_values_tl ffvt
                    WHERE  ffv.flex_value_id = ffvt.flex_value_id
                          AND ffv.flex_value_set_id = 1017032--need to change after the next setup
                          AND UPPER(ffvt.description) like UPPER('Sales -%')
              )
     ) pbsasales,
    (
    
     
     select distinct ENTERED_DR RUNNING_TOTAL_DR, cat.segment1, cat.segment2, cat.segment3, cat.segment4
     from gl_je_headers gh,
          gl_je_lines gl,
          gl_code_combinations gcc,
          (
                SELECT distinct fv.description cat, flex_value, mc.segment1, mc.segment2, mc.segment3, mc.segment4
                FROM  mtl_item_categories mic,
                      mtl_category_sets_tl mcst,
                      mtl_category_sets_b mcs,
                      mtl_categories_b_kfv mc,
                      mtl_system_items_b msi,
                      (
                        SELECT ffv.flex_value, upper(ffvt.description) description
                        FROM   fnd_flex_values ffv
                              ,fnd_flex_values_tl ffvt
                        WHERE  ffv.flex_value_id = ffvt.flex_value_id
                               AND ffv.flex_value_set_id = 1017030
                      ) fv
                WHERE mic.category_set_id       = mcs.category_set_id
                      AND mcs.category_set_id   = mcst.category_set_id
                      AND mic.category_id       = mc.category_id     
                      AND msi.organization_id   = mic.organization_id    
                      AND msi.inventory_item_id = mic.inventory_item_id
                      AND upper(mc.segment4) = fv.description
                      
                ) cat
     where gh.JE_HEADER_ID = gl.JE_HEADER_ID
           and gh.PERIOD_NAME = :p_period
           and JE_CATEGORY in (
               select JE_CATEGORY_NAME
               from gl_je_categories_tl
               where USER_JE_CATEGORY_NAME = 'PBSA_COS'
           )
           
           and (:p_cat1 is null or UPPER(:p_cat1) = UPPER(cat.segment1))
           and (:p_cat2 is null or UPPER(:p_cat2) = UPPER(cat.segment2))
           and (:p_cat3 is null or UPPER(:p_cat3) = UPPER(cat.segment3))
           and (:p_cat4 is null or UPPER(:p_cat4) = UPPER(cat.segment4))

           and gl.code_combination_id = gcc.code_combination_id
           and DATE_CREATED between (:p_date_from) and (:p_date_to)
           AND gcc.segment4 = cat.flex_value
           and gcc.segment2 = :p_seg2
           and gcc.segment6 in (
                    SELECT ffv.flex_value
                    FROM fnd_flex_values ffv
                        ,fnd_flex_values_tl ffvt
                    WHERE  ffv.flex_value_id = ffvt.flex_value_id
                          AND ffv.flex_value_set_id = 1017032--need to change after the next setup
                          AND UPPER(ffvt.description) like UPPER('%Cost of Sales%')
              )
     
    ) pbsacos
where pbsacos.segment1||'.'||pbsacos.segment2||'.'||pbsacos.segment3||'.'||pbsacos.segment4 = pbsasales.segment1||'.'||pbsasales.segment2||'.'||pbsasales.segment3||'.'||pbsasales.segment4

)
;