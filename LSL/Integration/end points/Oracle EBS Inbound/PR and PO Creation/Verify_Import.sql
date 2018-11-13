
 -------------------------------------------------------------------------------
      -- Verify requisition import
      -------------------------------------------------------------------------------
      PROCEDURE Verify_Import (
          p_requisition_number         IN VARCHAR  
        , x_req_header_id            OUT NUMBER
        , x_error_msg                 OUT VARCHAR2
        )
        IS
          CURSOR C_Interface
          IS
          SELECT M.Segment1
          ,         I.Item_Description
          ,      I.Transaction_Id
          FROM      PO_REQUISITIONS_INTERFACE_ALL I
          ,         MTL_SYSTEM_ITEMS_B M
          WHERE  I.Req_Number_Segment1 = p_requisition_number
          AND    I.Process_Flag = 'ERROR'
          AND    I.Item_Id = M.Inventory_Item_Id (+)
          AND    I.Destination_Organization_Id = NVL (M.Organization_Id,I.Destination_Organization_Id)
          ;
          
          CURSOR C_Actual_ID 
          IS
          SELECT Requisition_Header_Id
          FROM   PO_REQUISITION_HEADERS_ALL 
          WHERE  Segment1 = p_requisition_number 
          ;
          
          
          CURSOR C_Errors
          (
            p_transaction_id NUMBER
            )
          IS
          SELECT E.Error_Message
          FROM   PO_INTERFACE_ERRORS E
          WHERE  E.Interface_Transaction_Id = p_transaction_id
          ;
          
          l_concat_msg VARCHAR2(240);
          l_id        NUMBER;
          
        BEGIN
        
          OPEN  C_Actual_ID;
          FETCH C_Actual_Id INTO l_id;
          CLOSE C_Actual_Id;
          
          IF l_id IS NOT NULL 
          THEN
            -- Update some error record
            null; 
         END IF;
          
          <<interface>>
          FOR I IN C_Interface
          LOOP
             x_error_msg := 'Error during import Req ' || p_requisition_number;
             l_concat_msg := null;
             <<Errors>>
             FOR E IN C_Errors (p_transaction_id => I.Transaction_id)
             LOOP
               -- Print error message based on E.Error_message and item number
                -- for example
                NULL;
             END LOOP Errors;
                          
          END LOOP Interface;
          COMMIT;
        END Verify_Import;