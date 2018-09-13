select *
from PO_REQUISITIONS_INTERFACE_ALL;

select *
from PO_INTERFACE_ERRORS;

select *
from PO_REQUISITION_HEADERS_ALL;

select *
from PO_REQUISITION_LINES_ALL;

select *
from PO_REQ_DISTRIBUTIONS_ALL;

Error while inserting into interface table ORA-0000: normal, successful completion
Error while inserting into interface table ORA-0000: normal, successful completion
Error while inserting into interface table ORA-0000: normal, successful completion
Error while inserting into interface table ORA-0000: normal, successful completion
Error while inserting into interface table ORA-0000: normal, successful completion
Error while inserting into interface table ORA-0000: normal, successful completion
Error occure while retreiving requestor_id :ORA-01403: no data foundError while inserting into interface table ORA-0000: normal, successful completion
Error occure while retreiving requestor_id :ORA-01403: no data foundError while inserting into interface table ORA-0000: normal, successful completion

INSERT
        INTO PO_REQUISITIONS_INTERFACE_ALL
          (
            batch_id ,
            TRANSACTION_ID ,
            interface_source_code ,
            source_type_code ,
            requisition_type ,
            destination_type_code ,
            item_id
            --,item_description
            -- ,CATEGORY_ID
            ,
            quantity ,
            authorization_status ,
            preparer_id
            --,category_id
            ,
            uom_code ,
            destination_organization_id ,
            deliver_to_location_id ,
            deliver_to_requestor_id ,
            charge_account_id ,
            need_by_date ,
            org_id ,
            unit_price ,
            autosource_flag ,
            suggested_vendor_id ,
            suggested_vendor_site_id
            --   ,req_number_segment1
            --  ,multi_distributions
            ,
            req_dist_sequence_id
          )
          VALUES
          (
            123 ,
            PO_REQUISITIONS_INTERFACE_S.nextval ,
            'TEST' ,
            'VENDOR' ,
            'PURCHASE' ,
            'EXPENSE' ,
            2
            --   ,v_requistion_rec.item_description
            --   ,ln_category_id
            ,
            3 ,
            'APPROVED' ,
            62 ,
            'ECH' ,
            102 ,
            102 ,
            62 ,
            2021 ,
            '31-JUL-18' ,
            102 ,
            100,
            'Y' ,
            1 ,
            14
            --    ,lv_req_number_segment1
            --  ,v_requistion_rec.multiple_lines   -- Added column for multi lines   --'Y'
            ,
            PO_REQ_DIST_INTERFACE_S.nextval
          );
          
          
DECLARE
   lc_user_name                          VARCHAR2(100)   := 'CLERK';
   lc_user_password                  VARCHAR2(100)   := 'Oracle123';
   ld_user_start_date                  DATE                      := SYSDATE - 1;
   ld_user_end_date                   VARCHAR2(100)  := NULL;
   ld_password_date                  VARCHAR2(100)  := SYSDATE - 1;
   ld_password_lifespan_days  NUMBER              := 90;
   ln_person_id                             NUMBER              := 62;
   --lc_email_address                     VARCHAR2(100) := 'PRAJ_TEST@abc.com';

BEGIN
  fnd_user_pkg.createuser
  (  x_user_name                            => lc_user_name,
     x_owner                                    => NULL,
     x_unencrypted_password     => lc_user_password,
     x_start_date                              => ld_user_start_date,
     x_end_date                               => ld_user_end_date,
     x_password_date                    => ld_password_date,
     x_password_lifespan_days   => ld_password_lifespan_days,
     x_employee_id                        => ln_person_id--,
--     x_email_address                     => lc_email_address
 );
 
 COMMIT;


EXCEPTION
       WHEN OTHERS THEN
                       ROLLBACK;
                       DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/