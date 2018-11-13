create or replace function xxpbsa_inv_rank(p_sup_id number, p_item_id number)
return number
as

inv_amount       number;
ret_quantity     number;
ret_unit_price   number;
l_invoice_id     number;
cnt_invoice_id   number;

i              number;
j              number;

cursor cur_rec
is
select INV_AMOUNT, RET_QUANTITY, RET_UNIT_PRICE
from
(
SELECT distinct inv.amount inv_amount
          ,dsl.quantity*10000 ret_quantity
          ,prl.PERUNITPRICE ret_unit_price, inv.invoice_id
    FROM po_headers_all ph
        ,po_lines_all pl
        ,PO_DISTRIBUTIONS_ALL PD
        ,PO_REQ_DISTRIBUTIONS_ALL PRDA
        ,PO_REQUISITION_LINES_ALL PRLA
        ,PO_REQUISITION_HEADERS_ALL PRHA
        ,deliverysummary@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ds
        ,deliverysummaryline@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG dsl
        ,PURCHASE_REQUESTS_HEADER@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG prh
        ,PURCHASE_REQUESTS_LINES@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG prl
        ,mtl_system_items_b msi
        ,(
            SELECT invoice_id, amount, po_distribution_id
            FROM ap_invoice_distributions_all
            order by invoice_id desc
         ) inv
         ,ap_invoices_all apia--needs to get the last invice rank
    WHERE   1 = 1   
           AND pd.po_distribution_id = inv.po_distribution_id     
           AND apia.vendor_id = p_sup_id
           AND msi.inventory_item_id = p_item_id
           AND apia.invoice_id = inv.invoice_id
           AND ph.po_header_id = pl.po_header_id
           AND pd.po_line_id = pl.po_line_id
           AND ds.DeliveryId = dsl.DeliveryId
           --AND ds.status_flag is null
           --AND prh.PURCHASEREQUESTID = PRHA.INTERFACE_SOURCE_CODE
           AND msi.inventory_item_id = pl.item_id
           AND msi.segment1 = dsl.PARTNUMBER
           --AND ds.EXTERNALREFERENCENUMBER = ph.SEGMENT1
           AND pd.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID
           AND PRDA.REQUISITION_LINE_ID = PRLA.REQUISITION_LINE_ID
           AND PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID
           --AND NVL(ds.PurchaseOrderID, 0) = NVL(prl.PurchaseOrderID, 0)
           order by invoice_id desc
           )
           where 1 = 1
                 AND ((ret_quantity-(ret_quantity*ret_unit_price-inv_amount)/ret_unit_price) <= ret_quantity)
           ;

begin

select count(invoice_id)
into cnt_invoice_id
from 
 (SELECT distinct inv.amount inv_amount
          ,dsl.quantity*10 ret_quantity
          ,prl.PERUNITPRICE ret_unit_price
          ,inv.invoice_id
    FROM po_headers_all ph
        ,po_lines_all pl
        ,PO_DISTRIBUTIONS_ALL PD
        ,PO_REQ_DISTRIBUTIONS_ALL PRDA
        ,PO_REQUISITION_LINES_ALL PRLA
        ,PO_REQUISITION_HEADERS_ALL PRHA
        ,deliverysummary@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG ds
        ,deliverysummaryline@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG dsl
        ,PURCHASE_REQUESTS_HEADER@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG prh
        ,PURCHASE_REQUESTS_LINES@DATABASE_LINK_EBS_APEX.LANKASATHOSA.ORG prl
        ,mtl_system_items_b msi
        ,(
            SELECT invoice_id, amount, po_distribution_id
            FROM ap_invoice_distributions_all
            order by invoice_id desc
         ) inv
         ,ap_invoices_all apia--needs to get the last invice rank
    WHERE   1 = 1   
           AND pd.po_distribution_id = inv.po_distribution_id     
           AND apia.vendor_id = p_sup_id
           AND msi.inventory_item_id = p_item_id
           AND apia.invoice_id = inv.invoice_id
           AND ph.po_header_id = pl.po_header_id
           AND pd.po_line_id = pl.po_line_id
           AND ds.DeliveryId = dsl.DeliveryId
           --AND ds.status_flag is null
           --AND prh.PURCHASEREQUESTID = PRHA.INTERFACE_SOURCE_CODE
           AND msi.inventory_item_id = pl.item_id
           AND msi.segment1 = dsl.PARTNUMBER
           --AND ds.EXTERNALREFERENCENUMBER = ph.SEGMENT1
           AND pd.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID
           AND PRDA.REQUISITION_LINE_ID = PRLA.REQUISITION_LINE_ID
           AND PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID
           --AND NVL(ds.PurchaseOrderID, 0) = NVL(prl.PurchaseOrderID, 0)
           )
           where 1 = 1
           AND ((ret_quantity-(ret_quantity*ret_unit_price-inv_amount)/ret_unit_price) <= ret_quantity)
        order by invoice_id desc
           ;

for cur in cur_rec
loop
loop
i := 0;
cnt_invoice_id := cnt_invoice_id - 1;
j := i + 1;
exit when (cnt_invoice_id = 1 AND (cur.ret_quantity-(cur.ret_quantity*cur.ret_unit_price-cur.inv_amount)/cur.ret_unit_price) <= cur.ret_quantity);
end loop;
end loop;
return j;
end;