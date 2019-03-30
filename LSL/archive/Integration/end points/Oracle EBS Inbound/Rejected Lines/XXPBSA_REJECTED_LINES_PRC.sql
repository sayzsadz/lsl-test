create or replace function XXPBSA_REJECTED_LINES_PRC
return varchar2
as
    v_cnt number;
begin
        
        SELECT (count (PRLA.REQUISITION_LINE_ID) - count(pol.PO_LINE_ID)) NO_OF_REJECTED_LINES
        INTO v_cnt
        FROM PO_HEADERS_ALL POH, 
               PO_LINES_ALL POL,
               PO_DISTRIBUTIONS_ALL PDA ,
               PO_REQ_DISTRIBUTIONS_ALL PRDA ,
               PO_REQUISITION_LINES_ALL PRLA ,
               PO_REQUISITION_HEADERS_ALL PRHA
        WHERE POH.PO_HEADER_ID = PDA.PO_HEADER_ID 
              AND POH.PO_HEADER_ID = POL.PO_HEADER_ID 
              AND PDA.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID
              AND PRDA.REQUISITION_LINE_ID = PRLA.REQUISITION_LINE_ID
              AND PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID
              --AND POH.ROWID in (:p_row_id)--from Oracle Alert
              AND rownum = 1
        GROUP BY POH.SEGMENT1
                ,PRHA.SEGMENT1
                ,PRHA.REQUISITION_HEADER_ID
        ORDER BY PRHA.REQUISITION_HEADER_ID desc;

    return v_cnt;
    
end;