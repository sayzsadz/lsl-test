CREATE OR REPLACE PROCEDURE XXPBSA_PR_LINES( errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2 )
AS
        cursor cur
        is

            SELECT distinct prh_outter.PURCHASEREQUESTID BATCH_ID
                      ,stg.REQUISITION_TYPE
                      ,prh_outter.PURCHASEREQUESTID INTERFACE_SOURCE_CODE--stg.INTERFACE_SOURCE_CODE
                      ,stg.DESTINATION_TYPE_CODE
                      ,msi.SEGMENT1 PRODUCTID--ITEM_NAME
                      ,prl_outter.QUANTITY--QUANTITY
                      ,stg.AUTHORIZATION_STATUS
                      ,stg.PREPARER_FULL_NAME
                      ,REPLACE(prl_outter.UNIT, 'ECH') UOM_CODE
                      ,DESTINATION_ORGANIZATION
                      ,DELIVER_TO_LOCATION
                      ,DELIVER_TO_REQUESTOR
                      ,COST_CENTER
                      ,NATURAL_ACCOUNT
                      ,SUB_ANALYSIS_1
                      ,INTER_COMPANY
                      ,NEED_BY_DATE
                      ,OU_NAME
                      ,(prl_outter.LINETOTALCOST + prl_outter.LINETOTALCOSTTAX + prl_outter.PERUNITPRICE * prl_outter.QUANTITY) LINETOTALCOST
                      ,sup.VENDOR_NAME--SUGGESTED_VENDOR_NAME
                      ,sup.VENDOR_SITE_CODE--SUGGESTED_VENDOR_SITE
                      ,prh_outter.PURCHASEREQUESTID
                    ,prl_outter.PERUNITCOST--9
                    ,prl_outter.PERUNITCOSTTAX--8
                    ,prl_outter.LINETOTALCOST LINETOTALCOST_1--7
                    ,prl_outter.LINETOTALCOSTTAX--6
                    ,prl_outter.PERUNITPRICE--5
                    ,prl_outter.PERUNITPRICETAX--4
            FROM PURCHASE_REQUESTS_HEADER@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG prh_outter,
              PURCHASE_REQUESTS_LINES@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG prl_outter,
              (SELECT APS.VENDOR_NAME ,
                      apss.VENDOR_SITE_CODE,
                      prl.PURCHASEREQUESTID
              FROM PURCHASE_REQUESTS_LINES@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG prl ,
                AP_SUPPLIERS aps ,
                AP_SUPPLIER_SITES_ALL apss
              WHERE 1            = 1
              AND prl.SUPPLIERID = aps.attribute10
              AND apss.VENDOR_ID = aps.VENDOR_ID
              ) sup,
              mtl_system_items_b msi,
              (SELECT * FROM xx_req_po_stg xrps WHERE rownum = 1 and batch_id = 0) stg
            WHERE prl_outter.PURCHASEREQUESTID = prh_outter.PURCHASEREQUESTID
                  and sup.PURCHASEREQUESTID = prh_outter.PURCHASEREQUESTID
                  and msi.attribute10 = prl_outter.PRODUCTID
                  and prh_outter.STATUS_FLAG is null;

BEGIN
for cur_rec in cur
loop
INSERT
INTO xx_req_po_stg
  (
    BATCH_ID,
    REQUISITION_TYPE,
    INTERFACE_SOURCE_CODE,
    DESTINATION_TYPE_CODE,
    ITEM_NAME,
    QUANTITY,
    AUTHORIZATION_STATUS,
    PREPARER_FULL_NAME,
    UOM_CODE,
    DESTINATION_ORGANIZATION,
    DELIVER_TO_LOCATION,
    DELIVER_TO_REQUESTOR,
    COST_CENTER,
    NATURAL_ACCOUNT,
    SUB_ANALYSIS_1,
    INTER_COMPANY,
    NEED_BY_DATE,
    OU_NAME,
    UNIT_PRICE,
    SUGGESTED_VENDOR_NAME,
    SUGGESTED_VENDOR_SITE,
    ATTRIBUTE9,
    ATTRIBUTE8,
    ATTRIBUTE7,
    ATTRIBUTE6,
    ATTRIBUTE5,
    ATTRIBUTE4
  )
values
(
                   cur_rec.BATCH_ID
                  ,cur_rec.REQUISITION_TYPE
                  ,cur_rec.INTERFACE_SOURCE_CODE
                  ,cur_rec.DESTINATION_TYPE_CODE
                  ,cur_rec.PRODUCTID
                  ,cur_rec.QUANTITY
                  ,cur_rec.AUTHORIZATION_STATUS
                  ,cur_rec.PREPARER_FULL_NAME
                  ,cur_rec.UOM_CODE
                  ,cur_rec.DESTINATION_ORGANIZATION
                  ,cur_rec.DELIVER_TO_LOCATION
                  ,cur_rec.DELIVER_TO_REQUESTOR
                  ,cur_rec.COST_CENTER
                  ,cur_rec.NATURAL_ACCOUNT
                  ,cur_rec.SUB_ANALYSIS_1
                  ,cur_rec.INTER_COMPANY
                  ,cur_rec.NEED_BY_DATE
                  ,cur_rec.OU_NAME
                  ,(cur_rec.PERUNITPRICE * cur_rec.QUANTITY)
                  ,cur_rec.VENDOR_NAME
                  ,cur_rec.VENDOR_SITE_CODE
                  ,cur_rec.PERUNITCOST
                  ,cur_rec.PERUNITCOSTTAX
                  ,cur_rec.LINETOTALCOST_1
                  ,cur_rec.LINETOTALCOSTTAX
                  ,cur_rec.PERUNITPRICE
                  ,cur_rec.PERUNITPRICETAX
);
        update PURCHASE_REQUESTS_HEADER@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG h
        set STATUS_FLAG = 'P'
        where h.PURCHASEREQUESTID = cur_rec.PURCHASEREQUESTID;
end loop;
END;
/