CREATE OR REPLACE PROCEDURE xxpbsa_Item_Master_Org_Api
(errbuf out varchar2, rectcode out varchar2)
AS


L_VERIFY_FLAG VARCHAR2(3);
L_ERROR_MESSAGE VARCHAR2(2500);
L_COUNT NUMBER(2);
L_CATEGORY_SET_ID NUMBER(20);
L_CATEGORY_ID NUMBER(20);
L_ORG_ID NUMBER(4);
L_TEMPLATE_NAME VARCHAR2(250);
L_UOM VARCHAR2(20);
L_ITEM_TYPE VARCHAR2(20);
L_ORGANIZATION_ID NUMBER(10);
L_ORGANIZATION_CODE VARCHAR2(10);


CURSOR C1 IS
SELECT *
FROM
xxpbsa_items_staging;

BEGIN

FOR C_REC IN C1 LOOP


L_VERIFY_FLAG:='Y';
L_ERROR_MESSAGE:= NULL;
L_COUNT := 0;


BEGIN
SELECT ORGANIZATION_ID,ORGANIZATION_CODE
INTO L_ORGANIZATION_ID,L_ORGANIZATION_CODE
FROM ORG_ORGANIZATION_DEFINITIONS
WHERE ORGANIZATION_CODE = TRIM(UPPER(C_REC.ORGANIZATION_CODE));
EXCEPTION
WHEN OTHERS THEN
L_VERIFY_FLAG := 'N';
L_ERROR_MESSAGE := 'INVALID ORGANIZATION' ;
END ;



BEGIN
SELECT COUNT(*)
INTO L_COUNT
FROM MTL_SYSTEM_ITEMS_B
WHERE SEGMENT1||'.'||SEGMENT2
||'.'||SEGMENT3||'.'||SEGMENT4 =
C_REC.SEGMENT1||'.'||C_REC.SEGMENT2
||'.'||C_REC.SEGMENT3||'.'||C_REC.SEGMENT4
AND ORGANIZATION_ID = L_ORGANIZATION_ID;
IF L_COUNT > 0 THEN
L_VERIFY_FLAG:= 'N';
L_ERROR_MESSAGE:=L_ERROR_MESSAGE|| 'ITEM ALREADY EXISTING' ;
END IF;
EXCEPTION
WHEN OTHERS THEN
NULL;
END;


IF ((TRIM(C_REC.SEGMENT1) IS NULL) OR
(TRIM(C_REC.SEGMENT2) IS NULL) OR
(TRIM(C_REC.SEGMENT3) IS NULL) OR
(TRIM(C_REC.SEGMENT4) IS NULL)) THEN
L_VERIFY_FLAG:= 'N';
L_ERROR_MESSAGE:= L_ERROR_MESSAGE|| 'ITEM SEGMENT SHOULD NOT BE NULL';
END IF;


IF TRIM(C_REC.DESCRIPTION) IS NULL THEN
L_VERIFY_FLAG:= 'N';
L_ERROR_MESSAGE:= L_ERROR_MESSAGE|| 'INVALID DESCRIPTION';
END IF;


BEGIN
SELECT TEMPLATE_NAME
INTO L_TEMPLATE_NAME
FROM MTL_ITEM_TEMPLATES
WHERE UPPER(TRIM(TEMPLATE_NAME)) = UPPER(TRIM(C_REC.TEMPLATE_NAME));
EXCEPTION
WHEN OTHERS THEN
L_VERIFY_FLAG:= 'N';
L_ERROR_MESSAGE := L_ERROR_MESSAGE||'INVALID TEMPLATE NAME';
END ;


BEGIN
SELECT UNIT_OF_MEASURE
INTO L_UOM
FROM MTL_UNITS_OF_MEASURE
WHERE UPPER(TRIM(UOM_CODE)) = UPPER(TRIM(C_REC.PRIMARY_UNIT_OF_MEASURE));
EXCEPTION
WHEN OTHERS THEN
L_VERIFY_FLAG:= 'N';
L_ERROR_MESSAGE := L_ERROR_MESSAGE||'INVALID UOM';
END;



IF L_VERIFY_FLAG <> 'N' THEN

BEGIN

INSERT INTO MTL_SYSTEM_ITEMS_INTERFACE
(
PROCESS_FLAG
, SEGMENT1
, SEGMENT2
, SEGMENT3
, SEGMENT4
, DESCRIPTION
, PRIMARY_UNIT_OF_MEASURE
, SET_PROCESS_ID
, TEMPLATE_NAME
, ORGANIZATION_ID
, ORGANIZATION_CODE
, TRANSACTION_TYPE
, ATTRIBUTE_CATEGORY
, ATTRIBUTE1
, ATTRIBUTE2
, ATTRIBUTE3
, ATTRIBUTE4
, ATTRIBUTE8
, ATTRIBUTE9
)
VALUES
(
1
, TRIM(C_REC.SEGMENT1)
, TRIM(C_REC.SEGMENT2)
, TRIM(C_REC.SEGMENT3)
, TRIM(C_REC.SEGMENT4)
, TRIM(C_REC.DESCRIPTION)
, L_UOM
, 1
, L_TEMPLATE_NAME
, L_ORGANIZATION_ID
, L_ORGANIZATION_CODE
, 'CREATE'
, C_REC.ATTRIBUTE_CATEGORY
, C_REC.ATTRIBUTE1
, C_REC.ATTRIBUTE2
, C_REC.ATTRIBUTE3
, C_REC.ATTRIBUTE4
, C_REC.ATTRIBUTE8
, C_REC.ATTRIBUTE9
);


UPDATE xxx_ITEM_MASTER_STG
SET VERIFY_FLAG = 'Y'
WHERE SEGMENT1||'.'||SEGMENT2
||'.'||SEGMENT3||'.'||SEGMENT4 =
C_REC.SEGMENT1||'.'||C_REC.SEGMENT2
||'.'||C_REC.SEGMENT3||'.'||C_REC.SEGMENT4;

EXCEPTION
WHEN OTHERS THEN
L_ERROR_MESSAGE:= SQLERRM;
UPDATE xxx_ITEM_MASTER_STG
SET VERIFY_FLAG = 'N',
ERROR_MESSAGE = L_ERROR_MESSAGE
WHERE SEGMENT1||'.'||SEGMENT2
||'.'||SEGMENT3||'.'||SEGMENT4 =
C_REC.SEGMENT1||'.'||C_REC.SEGMENT2||'.'||
C_REC.SEGMENT3||'.'||C_REC.SEGMENT4;
END;

COMMIT;

ELSE

UPDATE xxx_ITEM_MASTER_STG
SET VERIFY_FLAG = 'N'
,ERROR_MESSAGE = L_ERROR_MESSAGE
WHERE SEGMENT1||'.'||SEGMENT2||'.'||
SEGMENT3||'.'||SEGMENT4 =
C_REC.SEGMENT1||'.'||C_REC.SEGMENT2
||'.'||C_REC.SEGMENT3||'.'||C_REC.SEGMENT4;

COMMIT;

END IF;



END LOOP;

COMMIT;

END xxpbsa_Item_Master_Org_Api;
/