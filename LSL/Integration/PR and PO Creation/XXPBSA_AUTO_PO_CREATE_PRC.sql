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
      -------------------------------------------------------------------------------
      -- Auto create the PO
      -------------------------------------------------------------------------------
      CREATE OR REPLACE PROCEDURE XXPBSA_AUTO_CREATE_PO_PRC
      (
        p_requisition_number            IN VARCHAR2
      , p_po_header_id                    IN NUMBER
      , x_po_number                        OUT VARCHAR2
      , x_po_header_id                    OUT NUMBER      
      , x_error_msg                        OUT VARCHAR2
      )
      IS

  cursor c_po_header (cp_header_id number)
  is
  select    distinct porl.vendor_id
           ,porl.vendor_site_id
           ,poa.agent_id
           ,pod.org_id
           ,NVL(PORL.CURRENCY_CODE, 'LKR') CURRENCY_CODE
           ,PORL.DELIVER_TO_LOCATION_ID BILL_TO_LOCATION_ID
  from PO_AGENTS poa  INNER JOIN PO_REQUISITION_HEADERS_ALL porh ON PORH.PREPARER_ID = POA.AGENT_ID
                      INNER JOIN PO_REQUISITION_LINES_ALL porl ON PORH.REQUISITION_HEADER_ID = PORL.REQUISITION_HEADER_ID
                      INNER JOIN PO_VENDOR_SITES_ALL povs on PORL.VENDOR_ID = POVS.VENDOR_ID and POVS.VENDOR_SITE_ID = PORL.VENDOR_SITE_ID
                      INNER JOIN per_all_people_f papf ON POA.AGENT_ID = PAPF.PERSON_ID
                      INNER JOIN PO_DOCUMENT_TYPES_ALL_B  POD ON  POD.ORG_ID = POVS.ORG_ID and PORL.ORG_ID = POD.ORG_ID
                      INNER JOIN per_all_assignments_f paaf ON PAAF.PERSON_ID = PAPF.PERSON_ID
    where 1 = 1
          --AND porh.segment1 = '500003' -- for testing purpose
          AND TRUNC(SYSDATE) BETWEEN papf.effective_start_date AND papf.effective_end_date
          AND papf.person_id=paaf.person_id
          and POD.DOCUMENT_TYPE_CODE = 'PO'
          and pod.DOCUMENT_SUBTYPE = 'STANDARD'
          and porh.REQUISITION_HEADER_ID = cp_header_id;

                
            cursor c_req_lines
            is
            select             prha.segment1 req_num
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
            and             prha.segment1 = p_requisition_number
            order by         hla.ship_to_location_id
            ,                prla.creation_date desc
            ;        
            
   
            l_vendor_id             PO_HEADERS_ALL.vendor_id%type;
            l_vendor_site_id        PO_HEADERS_ALL.vendor_site_id%type;
            l_agent_id              PO_HEADERS_ALL.agent_id%type;
            l_org_id                PO_HEADERS_ALL.org_id%type;
            l_currency_code         PO_HEADERS_ALL.currency_code%type;
            l_bill_to_location_id   PO_HEADERS_ALL.bill_to_location_id%type;

TYPE l_po_header IS RECORD
   (
            vendor_id l_vendor_id%type
           ,vendor_site_id l_vendor_site_id%type
           ,agent_id l_agent_id%type
           ,org_id l_org_id%type
           ,currency_code l_currency_code%type
           ,bill_to_location_id l_bill_to_location_id%type

   );

            l_line_num number;
            l_nr_of_lines number := 0;
            l_shipment_num number;
            l_prev_deliver_to_location_id po_requisition_lines_all.deliver_to_location_id%type;
            l_prev_ship_to_location_id hr_locations_all.ship_to_location_id%type;
            l_prev_blanket_po_header_id po_headers_all.po_header_id%type;
            l_prev_blanket_po_line_num po_lines_all.line_num%type;
            l_interface_header_id po_headers_interface.interface_header_id%type;
            l_batch_id po_headers_interface.batch_id%type;
            
            l_document_num po_headers_all.segment1%type;
            l_last_updated_by po_headers_all.last_updated_by%type;
            l_created_by po_headers_all.created_by%type;
            l_interface_line_id po_lines_interface.interface_line_id%type;
            l_promised_date po_line_locations_all.promised_date%type;
            l_from_line_id po_lines_all.from_line_id%type;
            l_consolidate ap_supplier_sites_all.attribute12%type;
            x_return_status varchar2(1);
            x_msg_count number;
            x_msg_data fnd_new_messages.message_text%type;
            x_document_num po_headers_all.segment1%type;
            x_autocreated_doc_id po_headers_all.po_header_id%type;
            x_num_lines_processed number;
            l_po_header_rec l_po_header;
            l_header_created boolean := false;
        
      BEGIN  
      
        x_error_msg := null;
        l_line_num := 0;
        dbms_output.put_line ('For all requisition lines ...' || p_requisition_number);
      <<req>>
      FOR i IN c_req_lines
       LOOP
       
            l_nr_of_lines := l_nr_of_lines + 1;
            mo_global.init ('PO');
            mo_global.set_policy_context ('S', i.org_id);
            
            IF NOT l_header_created
            THEN
              l_header_created := true;
              
              
              
            OPEN  C_PO_Header (cp_header_id => p_po_header_id);
            FETCH C_PO_Header INTO l_po_header_rec;
            CLOSE C_PO_Header;
            
            l_vendor_id             := l_po_header_rec.vendor_id;
            l_vendor_site_id        := l_po_header_rec.vendor_site_id;
            l_agent_id              := l_po_header_rec.agent_id;
            l_org_id                := l_po_header_rec.org_id;
            l_currency_code         := l_po_header_rec.currency_code;
            l_bill_to_location_id   := l_po_header_rec.bill_to_location_id;

            select po_headers_interface_s.nextval
            ,po_core_sv1.default_po_unique_identifier ('PO_HEADERS',l_org_id)
            into l_interface_header_id
            ,l_document_num
            from dual;
            
            l_batch_id := l_interface_header_id;
            
            dbms_output.put_line ('Interface header id is ' || l_interface_header_id || ' and org id is ' || l_org_id || ' and batch id is ' || l_batch_id);
            
            insert into po_headers_interface
            ( 
            interface_header_id
            , interface_source_code
            , org_id
            , batch_id
            , process_code
            , action
            , document_type_code
            , document_subtype
            , document_num
            , group_code
            , vendor_id
            , vendor_site_id
            , agent_id
            , currency_code
            , creation_date
            , created_by
            , last_update_date
            , last_updated_by
            , style_id
            , Comments
            )
            values
            (
             l_interface_header_id
            , 'PO'
            , l_org_id
            , l_batch_id
            , 'NEW'
            , 'NEW'
            , 'PO'
            , 'STANDARD'
            , l_document_num
            , 'REQUISITION' -- 'DEFAULT'
            , l_vendor_id
            , l_vendor_site_id
            , l_agent_id
            , l_currency_code
            , sysdate
            , fnd_global.user_id
            , sysdate
            , fnd_global.user_id
            , 1
            , 'My description'
            );
            
            END IF; -- Only first time
            
            select po_lines_interface_s.nextval
            into   l_interface_line_id
            from   dual;

            l_shipment_num     := 1;
            l_line_num        := l_line_num + 1;
            --l_from_line_id    := i.blanket_po_line_num;
            l_promised_date    := null;
            
            IF i.blanket_po_line_num IS NOT NULL 
            THEN 
            BEGIN
              SELECT PO_Line_Id 
              INTO   l_from_line_id
              FROM   PO_LINES_ALL L 
              WHERE  L.Line_Num = i.blanket_po_line_num 
              AND    L.PO_header_Id = i.blanket_po_header_id 
              ;
              
              EXCEPTION 
                WHEN Others THEN 
                  l_from_line_id := null;
            END;
            END IF;
            
            dbms_output.put_line ('Link to blanket ' || i.blanket_po_header_id || ' line ' || i.blanket_po_line_num || ' with id ' || l_from_line_id);
            
            insert into po_lines_interface
            ( interface_header_id
            , interface_line_id
            , requisition_line_id
            , from_header_id
            , from_line_id
            , promised_date
            , creation_date
            , created_by
            , last_update_date
            , last_updated_by
            , line_num
            , shipment_num
            )
            values
            ( l_interface_header_id
            , l_interface_line_id
            , i.requisition_line_id
            , i.blanket_po_header_id
            , l_from_line_id
            , l_promised_date
            , sysdate
            , fnd_global.user_id
            , sysdate
            , fnd_global.User_id
            , l_line_num
            , l_shipment_num
            );
            
                        
            COMMIT;
        END LOOP Req;
        
        dbms_output.put_line ('Auto create PO nr of lines ' || l_nr_of_lines);
        
        IF l_nr_of_lines = 0
        THEN 
           dbms_output.put_line ('ERROR: Requisition not approved.');
          x_error_msg := 'Cannot find lines on requisition ' || p_requisition_number || ' that are OPEN and APPROVED.';
          x_return_status := fnd_api.g_ret_Sts_error;
        ELSE
            
            po_interface_s.create_documents(p_api_version              => 1.0
                                   ,x_return_status            => x_return_status
                                   ,x_msg_count                => x_msg_count
                                   ,x_msg_data                 => x_msg_data
                                   ,p_batch_id                 => l_batch_id
                                   ,p_req_operating_unit_id    => l_org_id
                                   ,p_purch_operating_unit_id  => l_org_id
                                   ,x_document_id              => x_autocreated_doc_id
                                   ,x_number_lines             => x_num_lines_processed
                                   ,x_document_number          => x_document_num
                                   ,p_document_creation_method => 'AUTOCREATE'
                                   ,p_orig_org_id              => l_org_id);
                                   
            x_po_number         := x_document_num;
            x_po_header_id    := x_autocreated_doc_id;
            
            dbms_output.put_line ('Auto create PObatch ' || l_batch_id || ' and org id ' || l_org_id);
            dbms_output.put_line ('Auto create PO' || x_document_num || ' status ' || x_return_status);
            
            IF x_return_status <> fnd_api.g_ret_sts_success
            THEN
              x_error_msg := x_msg_data;
              dbms_output.put_line ('Error creating PO: ' ||x_msg_data);
              DELETE FROM PO_HEADERS_INTERFACE WHERE INterface_Header_Id = l_batch_id;
              DELETE FROM PO_LINES_INTERFACE WHERE Interface_Header_Id = l_batch_id;
            
            END IF;
            
        END IF;
        
        dbms_output.put_line ('');
        
        END XXPBSA_AUTO_CREATE_PO_PRC;