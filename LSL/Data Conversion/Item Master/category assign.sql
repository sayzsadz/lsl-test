        --XXPBSA_AssignItmToCat
        
        SELECT msi.segment1, mcs.category_set_name, mc.CONCATENATED_SEGMENTS 
        FROM  mtl_categories_b_kfv mc,
              mtl_category_sets mcs,
              mtl_system_items_b msi,
              XXPBSA_ITEM_CATEGORIES_STG stg
        WHERE 1 = 1
              AND stg.ITEM_NUMBER = msi.segment1
              AND mc.CATEGORY_ID = stg.NEW_ITEM_CAT_ID
              AND mcs.STRUCTURE_ID = mc.STRUCTURE_ID
              AND msi.segment1 = '000001';