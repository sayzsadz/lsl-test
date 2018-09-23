SELECT distinct gcc.segment4
, gcc.segment6
, MC.CONCATENATED_SEGMENTS
, mc.segment1
, mc.segment4
, UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))) gcc_segment6
, UPPER(DECODE(gcc.segment4,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,4,gcc.segment4))) gcc_segment4
FROM mtl_item_categories mic,
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
AND msi.segment1 in ('000003');
--AND UPPER(DECODE(gcc.segment4,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,4,gcc.segment4))) like UPPER('%'||mc.segment1||'%')
AND UPPER(DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6))) like UPPER('%'||mc.segment1||'%')
AND GCC.END_DATE_ACTIVE is null
;

select distinct DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,6,gcc.segment6)) PRODUCT_CATEGORY
      ,DECODE(gcc.segment4,NULL,'',apps.gl_flexfields_pkg.get_description_sql( gcc.chart_of_accounts_id,4,gcc.segment4)) PRODUCT
from GL_CODE_COMBINATIONS gcc;

select distinct SEGMENT1, segment4
from mtl_categories_b_kfv
where UPPER(segment1) like UPPER('%LIQUOR%');
      and UPPER(segment4) like UPPER('%Liquor%');
      
      delete from GL_INTERFACE;