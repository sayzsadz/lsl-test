create or replace view XXSAGT_REQUESTION_V
as
SELECT prh.requisition_header_id,
  prl.requisition_line_id,
  pda.req_distribution_id,
  --PRL.LINE_NUM,
  prh.segment1 PR_NUMBER,
  prh.creation_date,
  prh.created_by,
  poh.segment1 PO_NUMBER,
  ppx.full_name REQUESTER_NAME,
  prh.description PR_DESCRIPTION,
  --prh.authorization_status,
  --prh.note_to_authorizer,
  --prh.type_lookup_code,
  prl.line_num,
  prl.line_type_id,
  prl.item_description,
  prl.unit_meas_lookup_code,
  prl.unit_price,
  prl.quantity,
  prl.need_by_date,
  prl.note_to_agent,
  prl.currency_code,
  prl.item_id,
  prl.VENDOR_ID,
  prl.VENDOR_SITE_ID,
  prl.VENDOR_CONTACT_ID
FROM po_requisition_headers_all prh,
  po_requisition_lines_all prl,
  po_req_distributions_all prd,
  per_people_x ppx,
  po_headers_all poh,
  po_distributions_all pda
WHERE prh.requisition_header_id = prl.requisition_header_id
AND ppx.person_id               = prh.preparer_id
AND prh.type_lookup_code        = 'PURCHASE'
AND prd.requisition_line_id     = prl.requisition_line_id
AND pda.req_distribution_id     = prd.distribution_id
AND pda.po_header_id            = poh.po_header_id
--AND PRL.LINE_NUM > 
AND prh.requisition_header_id = 3126
AND rownum < 10;

select *
from XXSAGT_RP_V
;

select *
from XXSAGT_REQUESTION_V;


  CREATE TABLE "XX_REQUESTION_STAGING" 
   (	REQ_HEADER_ID NUMBER, 
	STATUS VARCHAR2(10 BYTE), 
	RESPONSE VARCHAR2(1000 BYTE), 
  CREATED_DATE DATE, 
  SEQUENCE_ID NUMBER,
  FLOW_ID NUMBER)
  ;
select *
from XX_REQUESTION_STAGING;

select *
from po_requisition_lines_all


;

drop table PURCHASE_REQUESTS_HEADER;

CREATE TABLE "APEX"."PURCHASE_REQUESTS_HEADER" 
   (	"PURCHASEREQUESTID" VARCHAR2(100), 
	"DATEREQUIRED" VARCHAR2(100), 
	"STOREID" VARCHAR2(100), 
	"STREET" VARCHAR2(100), 
	"CITY" VARCHAR2(100), 
	"STATE" VARCHAR2(100), 
	"POSTCODE" VARCHAR2(100), 
	"COUNTRY" VARCHAR2(100), 
	"CONTACTNAME" VARCHAR2(100), 
	"PHONE" VARCHAR2(100), 
	"EMAIL" VARCHAR2(100)
   ) ;