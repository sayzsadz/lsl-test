
SELECT rcv.ORGANIZATION_ID ,
      rsl.ITEM_ID rcv_item,
      pol.iTEM_ID po_item,
      poh.ORG_ID,
      to_number(rcv.ATTRIBUTE1) rcv_qty,
      pol.QUANTITY              *.625 po_qty,
      (to_number(rcv.ATTRIBUTE1)-pol.QUANTITY*.625) qty_diff,
      item.PRIMARY_UOM_CODE,
      rcv.TRANSACTION_DATE,
      rcv.SUBINVENTORY,
      rsh.RECEIPT_NUM,
      rsh.SHIPMENT_HEADER_ID,
      rcv.SHIPMENT_LINE_ID,
      NVL(rsl.ATTRIBUTE15,'.') update_status,
      rcv.TRANSACTION_TYPE,
      pol.PO_HEADER_ID,
      pol.PO_LINE_ID
      --    rsl.*
    FROM RCV_SHIPMENT_headers rsh,
      RCV_SHIPMENT_LINES rsl,
      rcv_transactions rcv,
      po_headers_all poh,
      po_lines_all pol,
      mtl_system_items_b item
    WHERE rsh.SHIPMENT_HEADER_ID=rsl.SHIPMENT_HEADER_ID
    AND rsh.SHIPMENT_HEADER_ID  =rcv.SHIPMENT_HEADER_ID
    AND rsl.SHIPMENT_LINE_ID    =rcv.SHIPMENT_LINE_ID
    --AND rcv.TRANSACTION_TYPE    ='DELIVER'
    --AND rsh.RECEIPT_NUM         = 14 --v_rec_no
    AND poh.PO_HEADER_ID        =pol.PO_HEADER_ID
    AND poh.ORG_ID              =pol.ORG_ID
    AND poh.PO_HEADER_ID        =rcv.PO_HEADER_ID
    AND pol.PO_LINE_ID          =rcv.PO_LINE_ID
    AND item.inventory_item_id  =rsl.ITEM_ID;
    --AND item.organization_id    =81
    AND rcv.ORGANIZATION_ID    IN
      (SELECT ORGANIZATION_ID
      FROM mtl_system_items_b
      WHERE inventory_item_id= 2
        /*Only for this item attached orgs*/
      )
  AND item.inventory_item_id=2;
  
  select *
  from RCV_SHIPMENT_headers;
  
  select *
  from RCV_SHIPMENT_LINES;
  
  select *
  from rcv_transactions;
  
  select *
  from po_headers_all;
  
  select *
  from po_lines_all;
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  select *
  from PO_AGENTS;
  
  select *
  from per_all_people_f;
  
  select *
  from PO_DOCUMENT_TYPES_ALL_B;
  
  select *
  from HR_ALL_ORGANIZATION_UNITS;
  
  select *
  from FND_CURRENCIES;
  
  select *
  from HR_LOCATIONS_ALL;

    
    select *
    from PO_DOCUMENT_TYPES_ALL_B;
    
    select *
    from PO_REQ_DISTRIBUTIONS_ALL;
    
  ,PO_AGENTS
  ,per_all_people_f
  ,PO_DOCUMENT_TYPES_ALL_B
  ,HR_ALL_ORGANIZATION_UNITS
  ,FND_CURRENCIES
  ,FND_CURRENCIES
  
  select    vendor_id
           ,vendor_site_id
           ,agent_id
           ,org_id
           ,currency_code
           ,bill_to_location_id
          -- ,consolidate
  from PO_HEADERS_ALL;
  
  
            select             distinct prha.segment1 req_num
            ,                hla.ship_to_location_id
            ,                prla.*
            from              po_requisition_headers_all prha
            inner join         po_requisition_lines_all prla
            on                 prha.requisition_header_id = prla.requisition_header_id
            inner join         hr_locations_all hla
            on                 prla.deliver_to_location_id = hla.location_id
            where             1=1
            and             prha.authorization_status = 'APPROVED' 
            and             nvl(prla.reqs_in_pool_flag,'N') = 'Y'      
            and             nvl(prla.cancel_flag,'N') = 'N'
            and             nvl(prla.closed_code,'OPEN') = 'OPEN'
            and             prha.segment1 = '500003'
            order by         hla.ship_to_location_id
            ,                prla.creation_date desc
            ;        