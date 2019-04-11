--Supplier return summary				
--SUPPLIER_CODE	REFERENCE	RETURN_DATE	RETURN_NO	AMOUNT
select SEGMENT1 SUPPLIER_CODE
     , INTERFACE_SOURCE_CODE REFERENCE
     , INVOICE_DATE RETURN_DATE
     , INVOICE_NUM RETURN_NO
     , abs(INVOICE_AMOUNT) AMOUNT
from  (
        select distinct apia.invoice_num
              ,poh.po_header_id
              ,apia.INVOICE_AMOUNT
              ,apia.INVOICE_DATE
        from ap_invoices_all apia
            ,po_headers_all poh
            ,ap_invoice_distributions_all apida
            ,po_distributions_all pod
            ,po_lines_all pol 
        WHERE apia.invoice_id=apida.invoice_id
              and poh.po_header_id=pol.po_header_id(+)
              and poh.po_header_id(+)=pod.po_header_id
              and pol.po_line_id=pod.po_line_id 
              and apida.po_distribution_id=pod.po_distribution_id(+)
              and INVOICE_TYPE_LOOKUP_CODE = 'DEBIT'
     ) aia
    ,(
      SELECT asa.segment1
            ,pha.po_header_id
            ,pha.INTERFACE_SOURCE_CODE
      FROM ap_suppliers asa ,
           po_vendor_sites_all pvs ,
           po_headers_all pha ,
           po_lines_all pol ,
           po_distributions_all pda ,
           po_line_locations_all pll
    WHERE 1 = 1
        AND pvs.vendor_site_id = pha.vendor_site_id
        AND asa.vendor_id = pha.vendor_id
        AND pha.type_lookup_code = 'STANDARD'
        AND pha.po_header_id = pol.po_header_id
        AND pda.po_header_id = pha.po_header_id
        AND pll.po_header_id = pll.po_header_id
        AND pll.po_line_id = pol.po_line_id
        ) sr
where 1=1
      and sr.po_header_id = aia.po_header_id
;