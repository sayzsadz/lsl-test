declare
      l_po_number                        VARCHAR2(10);
      l_po_header_id                     NUMBER;
      l_error_msg                        VARCHAR2(2000);
      
      begin
      XXPBSA_AUTO_CREATE_PO_PRC
      (
        p_requisition_number  => '500011'
      , p_po_header_id  => 2007
      , x_po_number     => l_po_number
      , x_po_header_id  => l_po_header_id    
      , x_error_msg => l_error_msg
      );
      dbms_output.put_line(l_po_number||'-'||l_po_header_id||'-'||l_error_msg);
end;
/