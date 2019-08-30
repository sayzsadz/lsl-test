      alter session set nls_language = 'AMERICAN';
      
      declare
        a varchar2(10);
        b varchar2(10);
      begin
        XXPBSA_PR_LINES(a,b);
      end;
      
      exec req_po_load_pkg.SUBMIT_REQUEST (2246,2246);
      
      select *
      from xx_req_po_stg
      where ERROR_FLAG is null
            and batch_id != 0;
            
      declare
        a varchar2(10);
        b varchar2(10);
      begin
        XXPBSA_PRPO_CREATION(a,b);
      end;
      /
      
      
      
      select po_header_id, to_char(LAST_UPDATE_DATE, 'DD-MON-RRRR HH24:MI:SS'), segment1 , authorization_status
      from po_headers_all
      order by 1 desc;
      
      select *
      from po_lines_all
      where PO_HEADER_ID = 2247
      order by 1 desc;
      
      SELECT distinct pha_outer.SEGMENT1, PRLA_outer.attribute15
            FROM   PO_HEADERS_ALL pha_outer
                  ,PO_LINES_ALL pla_outer
                  ,ap_suppliers aps
                  ,PO_DISTRIBUTIONS_ALL PDA_outer
                  ,PO_REQ_DISTRIBUTIONS_ALL PRDA_outer
                  ,PO_REQUISITION_LINES_ALL PRLA_outer
                  ,PO_REQUISITION_HEADERS_ALL PRHA_outer
            WHERE  1 = 1
                   AND PDA_outer.REQ_DISTRIBUTION_ID = PRDA_outer.DISTRIBUTION_ID
                   AND PRDA_outer.REQUISITION_LINE_ID = PRLA_outer.REQUISITION_LINE_ID
                   AND PRLA_outer.REQUISITION_HEADER_ID = PRHA_outer.REQUISITION_HEADER_ID
                   AND pda_outer.po_line_id = pla_outer.po_line_id
                   AND PDA_outer.REQ_DISTRIBUTION_ID = PRDA_outer.DISTRIBUTION_ID
                   AND pha_outer.po_header_id = pla_outer.po_header_id
                   and aps.vendor_id = pha_outer.vendor_id
                   AND pha_outer.attribute13 is null
                   AND pha_outer.authorization_status = 'APPROVED'
                   and PRLA_outer.attribute15 = PRHA_outer.INTERFACE_SOURCE_CODE
            order by 1 desc;
            
            declare
                l_response varchar2(20000);
            begin
                XXPBSA_HO_EXECUTE_IMPORT_PRC@DATABASE_LINK_EBS_APEX.LANKASATHOSA.LK('purchase-orders', '100638', NULL, l_response);
            end;
            
        update PO_HEADERS_ALL
        set attribute13 = 'Approval Sent'
        where segment1 = '100638';
        
        select *
        from PO_HEADERS_ALL
        where segment1 = '100637';
        
        select *
        from po_lines_all
        where PO_HEADER_ID = 26193;

        
        update PURCHASE_REQUESTS_LINES@DATABASE_LINK_EBS_APEX.LANKASATHOSA.LK
        set status_flag = 'A'
        where PURCHASEREQUESTLINEID = 2243;
        
        exec XXPBSA_EXECUTE_DEL_IMPORT_PRC;
        
      declare
        a varchar2(10);
        b varchar2(10);
      begin
        XXPBSA_DELIVERY_SUMMARY(a,b);
      end;
      /