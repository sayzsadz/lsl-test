select *
from mtl_lot_numbers;

select *
from MTL_SYSTEM_ITEMS_B;

SELECT *
FROM mtl_categories_b;

select *
from ORG_ORGANIZATION_DEFINITIONS;

select *
from MTL_ITEM_TEMPLATES;

select *
from MTL_UNITS_OF_MEASURE;

INSERT
INTO MTL_SYSTEM_ITEMS_INTERFACE
  (
    ORGANIZATION_CODE ,
    template_name ,
    item_SEGMENT1 ,
    DESCRIPTION ,
    PRIMARY_UOM_CODE ,
    LIST_PRICE_PER_UNIT ,
    AUTO_LOT_ALPHA_PREFIX ,
    START_AUTO_LOT_NUMBER ,
    LOT_CONTROL_CODE ,
    LOT_DIVISIBLE_FLAG ,
    PROCESS_FLAG
  )
  VALUES
  (
    'SIO',
    '@Product Family',
    '281133E000',
    'FILTER-AIR CLEANER',
    'EA',
    NULL ,
    'SP',
    1 ,
    2,
    'Y',
    'N'
  );
