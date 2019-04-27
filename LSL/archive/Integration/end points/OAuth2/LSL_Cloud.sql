select *
from PO_REQUISITIONS_INTERFACE_ALL;

select *
from PO_REQ_DIST_INTERFACE_ALL;

select *
from xx_req_po_stg;

delete from PO_REQUISITIONS_INTERFACE_ALL;
delete from PO_REQ_DIST_INTERFACE_ALL;
delete from xx_req_po_stg where batch_id != 0;
--Note: Include trunc int. tables
