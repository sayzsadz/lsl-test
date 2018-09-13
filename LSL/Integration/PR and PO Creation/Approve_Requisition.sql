-------------------------------------------------------------------------------
      -- Approve the requisition
      -------------------------------------------------------------------------------
      PROCEDURE Approve_Requisition
      (
        p_requisition_number            VARCHAR2
      , x_msg                            OUT VARCHAR2
      )
      IS
      l_msg  WF_NOTIFICATIONS.Subject%TYPE;
      
      CURSOR C_Wfl_Msg 
      (
        p_item_key        IN VARCHAR2
      )
      IS 
      SELECT Subject 
      FROM   WF_NOTIFICATIONS 
      WHERE  Item_Key = p_item_key 
      AND    Message_Type = 'REQAPPRV'
      ;
      
      CURSOR c_req_details
       IS
          SELECT prh.requisition_header_id,
                 prh.org_id,
                 prh.preparer_id,
                 prh.segment1,
                 pdt.document_subtype,
                 pdt.document_type_code,
                 prh.authorization_status
            FROM apps.po_requisition_headers_all prh,
                 apps.po_document_types_all pdt
           WHERE     prh.type_lookup_code = pdt.document_subtype
                 AND prh.org_id = pdt.org_id
                 AND pdt.document_type_code = 'REQUISITION'
                 AND NVL (authorization_status, 'INCOMPLETE') = 'INCOMPLETE'
                 AND prh.segment1 = p_requisition_number;     -- Enter The Requisition Number

        v_item_key VARCHAR2(240);
        
      BEGIN  
      
       <<req>>
      FOR p_rec IN c_req_details
       LOOP
       
        mo_global.init ('PO');
        mo_global.set_policy_context ('S', p_rec.org_id);


      
      SELECT    p_rec.requisition_header_id
                 || '-'
                 || TO_CHAR (po_wf_itemkey_s.NEXTVAL)
            INTO v_item_key
            FROM DUAL;
            
            p_l ('Start Requisition approval ' || v_item_key);

             po_reqapproval_init1.start_wf_process (
             itemtype                 => NULL,
             itemkey                  => v_item_key,
             workflowprocess          => 'POAPPRV_TOP',
             actionoriginatedfrom     => 'PO_FORM',
             documentid               => p_rec.requisition_header_id, -- requisition_header_id
             documentnumber           => p_rec.segment1,     -- Requisition Number
             preparerid               => p_rec.preparer_id,
             documenttypecode         => p_rec.document_type_code,  -- REQUISITION
             documentsubtype          => p_rec.document_subtype,       -- PURCHASE
             submitteraction          => 'APPROVE',
             forwardtoid              => NULL,
             forwardfromid            => NULL,
             defaultapprovalpathid    => NULL,
             note                     => NULL,
             printflag                => 'N',
             faxflag                  => 'N',
             faxnumber                => NULL,
             emailflag                => 'N',
             emailaddress             => NULL,
             createsourcingrule       => 'N',
             releasegenmethod         => 'N',
             updatesourcingrule       => 'N',
             massupdatereleases       => 'N',
             retroactivepricechange   => 'N',
             orgassignchange          => 'N',
             communicatepricechange   => 'N',
             p_background_flag        => 'N',
             p_initiator              => NULL,
             p_xml_flag               => NULL,
             fpdsngflag               => 'N',
             p_source_type_code       => NULL);
            
             COMMIT;
        
         END LOOP Req;
        
               
         -- Check workflow 
         OPEN  C_WFL_Msg (p_item_key => v_item_key);
         FETCH C_WFL_Msg INTO l_msg;
         IF C_Wfl_Msg%FOUND 
         THEN 
           p_l ('Requisition Approval: ' || l_msg);
         END IF;
         CLOSE C_WFL_Msg;
        
        END Approve_Requisition;