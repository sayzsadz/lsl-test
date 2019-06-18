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

declare
    p_category_name     varchar2(500);
    l_seg1              varchar2(500);
    l_seg2              varchar2(500);
    l_seg3              varchar2(500);
    l_seg4              varchar2(500);
    L_CATEGORY_ID       number;
    L_ITEM_ID           number;
    l_old_category_id   number;
begin
for rec in (
            select ITEM_NUMBER, ITEM_CAT_SEG
            from XXPBSA_ITEM_CATEGORIES_STG
            --where ITEM_NUMBER like '000001'
            --where rownum < 10
)
loop
begin
    --XXPBSA_ASSIGNITMTOCAT (p_segment1 => rec.ITEM_NUMBER, p_category_set_name => 'Inventory', p_category_name => rec.ITEM_CAT_SEG);
 
 p_category_name := rec.ITEM_CAT_SEG;
 
 select r1, r2--,r3, r4
 ,
 (
 case when r3 = 'Unspecified' and r4 = 'Unspecified'
        then r2
      when r3 != 'Unspecified' and r4 = 'Unspecified'
        then r3
      when r3 != 'Unspecified' and r4 != 'Unspecified'
        then r3
 end
 ) r5
  ,
 (
 case when r3 = 'Unspecified' and r4 = 'Unspecified'
        then r2
      when r3 != 'Unspecified' and r4 = 'Unspecified'
        then r3
      when r3 != 'Unspecified' and r4 != 'Unspecified'
        then r4
 end
 ) r6
 into l_seg1, l_seg2, l_seg3, l_seg4
        from
        (
        
                    select max(decode(rn,1,set_of_rows)) r1, max(decode(rn,2,set_of_rows)) r2, max(decode(rn,3,set_of_rows)) r3, max(decode(rn,4,set_of_rows)) r4
                    from
                    (
                    SELECT nvl(trim(REGEXP_SUBSTR (p_category_name||(
                    case when REGEXP_COUNT(p_category_name, '>') =  1
                        then 
                            ' > > '
                        when REGEXP_COUNT(p_category_name, '>') =  2
                        then 
                            ' > '
                        when REGEXP_COUNT(p_category_name, '>') =  3
                        then 
                            ''
                        else
                            ' > > > '
                    end
                    ),'[^>]+',1,LEVEL)),'Unspecified') as set_of_rows, rownum rn
                    FROM   DUAL
                    CONNECT BY REGEXP_SUBSTR (p_category_name||(
                    case when REGEXP_COUNT(p_category_name, '>') =  1
                        then 
                            ' > > '
                        when REGEXP_COUNT(p_category_name, '>') =  2
                        then 
                            ' > '
                        when REGEXP_COUNT(p_category_name, '>') =  3
                        then 
                            ''
                        else
                            ' > > > '
                    end
                    )
                    ,'[^>]+',1,LEVEL) IS NOT NULL
                    )
        );
        
        --DBMS_OUTPUT.put_line(l_seg1||l_seg2||l_seg3||l_seg4||' - '||L_CATEGORY_ID);
        
        select CATEGORY_ID
        into L_CATEGORY_ID
        from mtl_categories_b
        where upper(segment1) = upper(l_seg1)
              and upper(segment2) = upper(l_seg2)
              and upper(segment3) = upper(l_seg3)
              and upper(segment4) = upper(l_seg4);
              
        update XXPBSA_ITEM_CATEGORIES_STG 
        set NEW_ITEM_CAT_ID = L_CATEGORY_ID
        where item_number = rec.ITEM_NUMBER;
              
--              DBMS_OUTPUT.put_line(l_seg1||l_seg2||l_seg3||l_seg4||' - '||L_CATEGORY_ID);
              
        select distinct INVENTORY_ITEM_ID
        into L_ITEM_ID
        from mtl_system_items_b
        where segment1 = rec.ITEM_NUMBER;
        
            SELECT distinct mc.category_id
            into l_old_category_id
            FROM  mtl_item_categories mic,
                  mtl_category_sets_tl mcst,
                  mtl_category_sets_b mcs,
                  mtl_categories_b_kfv mc,
                  mtl_system_items_b msi
            WHERE mic.category_set_id = mcs.category_set_id
                  AND mcs.category_set_id   = mcst.category_set_id
                  --AND mcst.LANGUAGE         = USERENV ('LANG')
                  AND mic.category_id       = mc.category_id     
                  AND msi.organization_id = mic.organization_id    
                  AND msi.inventory_item_id = mic.inventory_item_id
                  AND msi.organization_id = 101
                  AND msi.segment1 = rec.ITEM_NUMBER;
        
        INSERT INTO mtl_item_categories_interface
       ( 
         category_set_id
        ,category_id
        ,last_update_date
        ,ORGANIZATION_id
        ,process_flag
        ,inventory_item_id
        ,old_category_id  
        ,transaction_type
        ,set_process_id  
       )  
       VALUES  
       ( 
         1   -- category_set_id  
        ,L_CATEGORY_ID         -- new category_id  
        ,SYSDATE    -- last_udate_date datatype DATETIME  
        ,101         -- ORGANIZATION_CODE (should be master_orgaization_id if category set is controlled at master level)  
        ,1            -- always 1  
        ,L_ITEM_ID       -- Item name  Note: for performance consideration use inventory_item_id in place of item_number  
        ,l_old_category_id         -- old category_id  
        ,'UPDATE'  
        ,99          -- set_process_id can be any positive number  
       );
       
       commit;
exception
    when others
        then
            DBMS_OUTPUT.put_line(l_seg1||l_seg2||l_seg3||l_seg4);
            --null;
end;
end loop;
end;
/