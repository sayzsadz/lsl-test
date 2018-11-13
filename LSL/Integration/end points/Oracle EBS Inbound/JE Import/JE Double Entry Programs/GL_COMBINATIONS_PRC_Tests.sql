SELECT ffv.flex_value, ffvt.description
FROM   fnd_flex_values ffv
      ,fnd_flex_values_tl ffvt
WHERE  ffv.flex_value_id = ffvt.flex_value_id
       AND ffv.flex_value_set_id = 1017028
       AND ffv.attribute2 is null;


--need to change after the next setup
       and UPPER(ffvt.description) like 
       '%'||
       (SELECT distinct UPPER(mc.segment4)
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
              AND msi.segment1 = '000001')
        ||'%';
       
       
        
SELECT UPPER(ffvt.description), ffv.flex_value_set_id
FROM   fnd_flex_values ffv
      ,fnd_flex_values_tl ffvt
WHERE  ffv.flex_value_id = ffvt.flex_value_id
AND    UPPER(ffvt.description) like '%AMPARA%';