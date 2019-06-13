insert into MTL_SYSTEM_ITEMS_INTERFACE(ORGANIZATION_CODE, TEMPLATE_NAME, SEGMENT1, DESCRIPTION, PRIMARY_UOM_CODE, PURCHASING_ITEM_FLAG, PURCHASING_ENABLED_FLAG, PROCESS_FLAG, transaction_type, SECONDARY_UOM_CODE, TRACKING_QUANTITY_IND, SECONDARY_DEFAULT_IND,LIST_PRICE_PER_UNIT, INVENTORY_ASSET_FLAG)
select 'SIO' ORGANIZATION_CODE, TEMPLATE_NAME, '00000022' SEGMENT1, DESCRIPTION, 'ECH' PRIMARY_UOM_CODE, PURCHASING_ITEM_FLAG, PURCHASING_ENABLED_FLAG, 1 PROCESS_FLAG, 'CREATE' transaction_type
,'CSE' SECONDARY_UOM_CODE, 'PS' TRACKING_QUANTITY_IND, 'D' SECONDARY_DEFAULT_IND, LIST_PRICE_PER_UNIT, 'N' INVENTORY_ASSET_FLAG
from XXPBSA_ITEM_LOAD_TBL
where rownum = 1;

insert into MTL_SYSTEM_ITEMS_INTERFACE(ORGANIZATION_CODE, TEMPLATE_NAME, SEGMENT1, DESCRIPTION, PRIMARY_UOM_CODE, PURCHASING_ITEM_FLAG, PURCHASING_ENABLED_FLAG, PROCESS_FLAG, transaction_type, SECONDARY_UOM_CODE, TRACKING_QUANTITY_IND, SECONDARY_DEFAULT_IND,LIST_PRICE_PER_UNIT, INVENTORY_ASSET_FLAG)
select 'SIO' ORGANIZATION_CODE, '@Product Family' TEMPLATE_NAME, '00000023', DESCRIPTION, 'ECH' PRIMARY_UOM_CODE, 'Y' PURCHASING_ITEM_FLAG, 'Y' PURCHASING_ENABLED_FLAG, 1 PROCESS_FLAG, 'CREATE' transaction_type
,'CSE' SECONDARY_UOM_CODE, 'PS' TRACKING_QUANTITY_IND, 'D' SECONDARY_DEFAULT_IND, LIST_PRICE_PER_UNIT, 'N' INVENTORY_ASSET_FLAG
from XXPBSA_ITEM_LOAD_TBL
where rownum = 1;

--0. run import items with default conc. parameters

select *
from MTL_SYSTEM_ITEMS_INTERFACE;

select *
from mtl_system_items_b
order by INVENTORY_ITEM_ID desc;

insert into XXPBSA_ITEM_LOAD_TBL
select *
from XXPBSA_ITEM_LOAD_TBL_TEMP;

create table XXPBSA_ITEM_LOAD_TBL_TEMP
as
select *
from XXPBSA_ITEM_LOAD_TBL;

delete from XXPBSA_ITEM_LOAD_TBL;
/
--PROCEDURES
--1. Item Create and assign to orgs
begin
for cur_rec in (select inventory_item_id from mtl_system_items_b where creation_date between sysdate-1 and sysdate+1)
loop
INSERT INTO mtl_system_items_interface
(inventory_item_id,
organization_id,
process_flag,
set_process_id,
transaction_type
)
values
( 
cur_rec.inventory_item_id,
102,
1,
1,
'CREATE'
);
commit;
end loop;
end;
--2. Item assign to categories
--XXPBSA_PROCESS_ITEMS
--XXPBSA_AssignItmToCat
begin
for rec in (
select ITEM_NUMBER, ITEM_CAT_SEG
from XXPBSA_ITEM_CATEGORIES_STG
)
loop
XXPBSA_ASSIGNITMTOCAT (p_segment1 => rec.ITEM_NUMBER, p_category_set_name => 'Inventory', p_category_name => rec.ITEM_CAT_SEG);
end loop;
end;
/
select msi.segment1, msi.inventory_item_id, cat.category_id
from mtl_system_items_b msi
    ,mtl_item_categories cat
where msi.inventory_item_id = cat.inventory_item_id
     and msi.organization_id = 101
     and msi.inventory_item_id in (
                                    select distinct inventory_item_id
                                    from mtl_system_items_b
                                    where organization_id = 101
    );

select *
from mtl_item_categories;



select distinct msi.segment1, msi.inventory_item_id
from mtl_system_items_b msi
where msi.inventory_item_id in (
        select inventory_item_id
        from (
        select inventory_item_id
        from mtl_item_categories
        where inventory_item_id = 31427
        group by inventory_item_id
        having count(organization_id) = 1
        )
)