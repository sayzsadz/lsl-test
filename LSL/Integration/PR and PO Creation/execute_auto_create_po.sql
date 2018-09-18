create or replace procedure XXPBSA_PRPO_CREATION(errbuf VARCHAR2, retcode NUMBER)
as
      l_po_number                        VARCHAR2(10);
      l_po_header_id                     NUMBER;
      l_error_msg                        VARCHAR2(2000);
      l_errbuf                           VARCHAR2(1000);
      l_retcode                          NUMBER;  
      v_pr_number                        VARCHAR2(10);
      v_pr_header_id                     NUMBER;
      
      cursor cur is
      select distinct BATCH_ID
      from xx_req_po_stg
      where ERROR_FLAG is null;
begin
    
       for cur_rec in cur
          loop
            req_po_load_pkg.MAIN(
               l_errbuf
              ,l_retcode
              ,cur_rec.BATCH_ID
              ,cur_rec.BATCH_ID
              );
      
      select distinct REQUISITION_HEADER_ID
           , SEGMENT1
      into v_pr_header_id
          ,v_pr_number
      from PO_REQUISITION_HEADERS_ALL
      where INTERFACE_SOURCE_CODE = TO_CHAR(cur_rec.BATCH_ID);
      
      XXPBSA_AUTO_CREATE_PO_PRC
      (
        p_requisition_number  => v_pr_number
      , p_po_header_id        => v_pr_header_id
      , x_po_number           => l_po_number
      , x_po_header_id        => l_po_header_id    
      , x_error_msg           => l_error_msg
      );
      
      end loop;
      dbms_output.put_line(l_po_number||'-'||l_po_header_id||'-'||l_error_msg);
end;
/