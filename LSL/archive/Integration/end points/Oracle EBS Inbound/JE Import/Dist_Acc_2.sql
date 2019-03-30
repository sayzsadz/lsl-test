SELECT distinct gcc.segment4
     , gcc.segment6
     ,msi.segment1 item_segment1
     ,mc.segment1
FROM  mtl_item_categories mic,
      mtl_category_sets_tl mcst,
      mtl_category_sets_b mcs,
      mtl_categories_b_kfv mc,
      mtl_system_items_b msi,
      GL_CODE_COMBINATIONS gcc
WHERE mic.category_set_id = mcs.category_set_id
      AND mcs.category_set_id   = mcst.category_set_id
      AND mcst.LANGUAGE         = USERENV ('LANG')
      AND mic.category_id       = mc.category_id     
      AND msi.organization_id = mic.organization_id    
      AND msi.inventory_item_id = mic.inventory_item_id
      AND msi.segment1 = '000003'
      AND REPLACE(UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))), 'SALES - LIQUOR', 'SALES - LIQUOR ' || q'[&]' || ' TOBACCO') like UPPER('%'||mc.segment1||'%')
      AND gcc.end_date_active is null
      --AND UPPER(DECODE(gcc.segment4,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,4,gcc.segment4))) like UPPER('%'||mc.segment6||'%')
      ;
      
      select REPLACE(UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))), 'SALES - LIQUOR', 'SALES - LIQUOR ' || q'[&]' || ' TOBACCO')
      from GL_CODE_COMBINATIONS gcc;