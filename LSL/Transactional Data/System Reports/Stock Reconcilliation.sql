--SELECT distinct gcc.segment2 SHOP_CODE --Shop Code
--      ,ffv.description SHOP_NAME      --Shop Name
--      ,msi.attribute1 O_Cost--Opening Inventory Balance (Cost)
--      ,msi.attribute2 C_Cost--Closing Inventory Balance (Cost)
--      ,msi.attribute3 O_Selling--Opening Inventory Balance (Selling)
--      ,msi.attribute4 C_Selling
--FROM dual;

SELECT distinct mc.segment2 SHOP_CODE
      ,ffv.description SHOP_NAME
      ,msi.attribute1 O_Cost--Opening Inventory Balance (Cost)
      ,msi.attribute2 C_Cost--Closing Inventory Balance (Cost)
      ,msi.attribute3 O_Selling--Opening Inventory Balance (Selling)
      ,msi.attribute4 C_Selling
FROM  mtl_item_categories mic,
      mtl_category_sets_tl mcst,
      mtl_category_sets_b mcs,
      mtl_categories_b_kfv mc,
      mtl_system_items_b msi,
      GL_CODE_COMBINATIONS gcc,
      (
        SELECT ffv.flex_value, ffvt.description
        FROM   fnd_flex_values ffv
              ,fnd_flex_values_tl ffvt
        WHERE  ffv.flex_value_id = ffvt.flex_value_id
               AND ffv.flex_value_set_id = 1017028
               AND ffv.attribute2 is null
      ) ffv
WHERE mic.category_set_id = mcs.category_set_id
      AND mcs.category_set_id   = mcst.category_set_id
      AND mcst.LANGUAGE         = USERENV ('LANG')
      AND mic.category_id       = mc.category_id     
      AND msi.organization_id = mic.organization_id    
      AND msi.inventory_item_id = mic.inventory_item_id
      AND REPLACE(UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))), 'SALES - LIQUOR', 'SALES - LIQUOR ' || q'[&]' || ' TOBACCO') like UPPER('%'||mc.segment1||'%')
      AND UPPER(DECODE(gcc.segment4,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,4,gcc.segment4))) = (CASE WHEN mc.segment1 like '%GROCERY%' then UPPER(DECODE(gcc.segment4,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,4,gcc.segment4))) else 'UNSPECIFIED' end)
      AND gcc.end_date_active is null
      AND ffv.flex_value = mc.segment2;
      