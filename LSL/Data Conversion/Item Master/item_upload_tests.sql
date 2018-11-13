select *
from mtl_system_items_b
where segment1 = 'ITEM00007';

select *
from XXPBSA_ITEM_LOAD_TBL
where item_segment1 = 'ITEM00007';

        select msi.inventory_item_id
        from mtl_system_items_b msi
        where msi.organization_id != 102;

select CATEGORY_ID, CONCATENATED_SEGMENTS
from mtl_categories_b_kfv;

select *
from XXPBSA_ITEM_LOAD_TBL;

select *
from MTL_SYSTEM_ITEMS_INTERFACE;

select *
from MTL_INTERFACE_ERRORS;

insert into MTL_SYSTEM_ITEMS_INTERFACE(ORGANIZATION_CODE, TEMPLATE_NAME, SEGMENT1, DESCRIPTION, PRIMARY_UOM_CODE, PURCHASING_ITEM_FLAG, PURCHASING_ENABLED_FLAG, PROCESS_FLAG, transaction_type, SECONDARY_UOM_CODE, TRACKING_QUANTITY_IND, SECONDARY_DEFAULT_IND)
select 'SIO' ORGANIZATION_CODE, TEMPLATE_NAME, 'ITEM00007' SEGMENT1, 'TEST ITEM00007' DESCRIPTION, 'ECH' PRIMARY_UOM_CODE, PURCHASING_ITEM_FLAG, PURCHASING_ENABLED_FLAG, 1 PROCESS_FLAG, 'CREATE' transaction_type
,'CSE' SECONDARY_UOM_CODE, 'PS' TRACKING_QUANTITY_IND, 'D' SECONDARY_DEFAULT_IND
from XXPBSA_ITEM_LOAD_TBL
where rownum = 1;

declare
  x_msg_data              Error_Handler.Error_Tbl_Type;
  x_status                varchar2(2);
  x_msg_count		      NUMBER := 0;
  
  cursor c1 is
        select msi.inventory_item_id
        from mtl_system_items_b msi
        where msi.organization_id != 102;
  
begin
    for cur_rec in c1
    loop
         EGO_ITEM_PUB.ASSIGN_ITEM_TO_ORG(p_api_version       => 1.0,
                                         p_init_msg_list     => fnd_api.g_true,
                                         p_commit            => fnd_api.g_true,
                                         p_inventory_item_id => cur_rec.inventory_item_id,
                                         p_item_number       => null,
                                         p_organization_id   => 102,
                                         p_organization_code => NULL,
                                         --p_primary_uom_code  => x_item_tbl(l_rowcnt).primary_uom,
                                         x_return_status     => x_status,
                                         x_msg_count         => x_msg_count);
    end loop;
    commit;
end;
