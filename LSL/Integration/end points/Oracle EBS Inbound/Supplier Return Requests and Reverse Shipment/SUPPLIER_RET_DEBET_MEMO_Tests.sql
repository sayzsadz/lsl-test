select *
from XXPBSA_AP_INVOICE_HEADERS;

update XXPBSA_AP_INVOICE_HEADERS
set INVOICE_NUM = 'INV_10021';

select *
from XXPBSA_AP_INVOICE_LINES;

select *
from XXPBSA_AP_INVOICE_DIST;

select distinct LINE_TYPE_LOOKUP_CODE
from ap_invoice_distributions

update XXPBSA_AP_INVOICE_HEADERS
set ERR_FLAG = null;

update XXPBSA_AP_INVOICE_LINES
set ERR_FLAG = null;

update XXPBSA_AP_INVOICE_DIST
set ERR_FLAG = null;

select *
from AP.ap_invoice_lines_all
order by invoice_id desc;

select *
from ap_invoices_all
order by invoice_id desc;

select *
from AP.ap_invoice_distributions_all
order by invoice_id desc;

SELECT xep.legal_entity_id, xep.party_id,
xep.legal_entity_identifier,xep.NAME,hp.party_name
FROM xle_entity_profiles xep,hz_parties hp
WHERE xep.party_id = hp.party_id

;

