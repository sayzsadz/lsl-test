      SELECT *
      FROM xx_req_po_stg
      WHERE batch_id           =123
      AND interface_source_code='TEST'
      AND authorization_status ='APPROVED'
      AND NVL(error_flag,'N')  = 'N';
      
          SELECT DISTINCT inventory_item_id
          FROM mtl_system_items_b
          WHERE UPPER(segment1)=UPPER('MILO');
          
          SELECT DISTINCT per.person_id, per.email_address
          FROM per_all_people_f per,
            per_all_assignments_f paaf
          WHERE 1=1
          --AND UPPER(per.full_name)=UPPER('Clerk, Miss')
          AND TRUNC(SYSDATE) BETWEEN paaf.effective_start_date AND paaf.effective_end_date
          AND per.person_id=paaf.person_id;
          
          SELECT organization_id
          FROM ORG_ORGANIZATION_DEFINITIONS OOD
          WHERE UPPER(ORGANIZATION_NAME)=UPPER('Outlet Inventory Organization');

          SELECT *
          FROM HR_LOCATIONS
          WHERE UPPER(location_code)=UPPER('LSL Main Warehouse');
          
          SELECT DISTINCT per.person_id, fu.user_name
          FROM per_all_people_f per,
            per_all_assignments_f paaf,
            fnd_user fu
          WHERE  1 = 1
          AND UPPER(fu.user_name)=UPPER('CLERK')
          AND TRUNC(SYSDATE) BETWEEN paaf.effective_start_date AND paaf.effective_end_date
          AND per.person_id =paaf.person_id
          AND fu.employee_id=per.person_id;

        SELECT gcc.segment1
        FROM gl_sets_of_books sob,
          gl_code_combinations gcc,
          org_organization_definitions ood
        WHERE sob.set_of_books_id    = ood.set_of_books_id
        AND gcc.chart_of_accounts_id = sob.chart_of_accounts_id
        AND ood.organization_code    = 'OIN'
        AND gcc.segment2             = '09100'			
        AND gcc.segment3             = '00'
        AND gcc.segment4             = '00000'
        AND gcc.segment6             = '150100';
          
          SELECT '11'
          ||'-'
          ||'09100'
          ||'-'
          || '00'
          ||'-'
          || '00000'
          ||'-'
          || '000'
          ||'-'
          || '150100'
          ||'-'
          || '00000'
          ||'-'
          || '000'
          ||'-'
          || '000'
        FROM dual;
          
        SELECT '11'
          ||'-'
          ||'09100'
          ||'-'
          ||'00'
          ||'-'
          || '00000'
          ||'-'
          || '000'
          ||'-'
          || '150100'
          ||'-'
          || '00000'
          ||'-'
          || '000'
          ||'-'
          || '000'
        FROM dual;
        
          SELECT DISTINCT code_combination_id
          FROM gl_code_combinations_kfv a,
            GL_SETS_OF_BOOKS gl
          WHERE  1 = 1
          AND TO_CHAR(concatenated_segments)=TO_CHAR('11-09100-00-00000-000-150100-00000-000-000')
          AND gl.chart_of_accounts_id         =a.chart_of_accounts_id ;
          
          SELECT ho.organization_id
          FROM org_organization_definitions ood,
            hr_operating_units ho,
            --apps.tncus_customizations tc,
            gl_sets_of_books sb
          WHERE ood.operating_unit = ho.organization_id
          AND TRUNC (SYSDATE) BETWEEN NVL (ho.date_from, TRUNC (SYSDATE)) AND NVL (ho.date_to, TRUNC (SYSDATE))
          --AND tc.org_id                   = ho.organization_id
          AND upper(ood.organization_code)=UPPER('OIN')
          AND ood.set_of_books_id         = sb.set_of_books_id;       
          
          SELECT vendor_id
          FROM po_vendors
          WHERE UPPER(vendor_name)=UPPER('Nandana Enterprises');
          
          
          SELECT vendor_site_id
          FROM po_vendor_sites_all
          WHERE UPPER(vendor_site_code)=UPPER('Supplier_Site1')
          AND vendor_id                = 7
          AND org_id                   = 81;
          
DECLARE
    errbuf  VARCHAR2(1000);
    retcode NUMBER;
BEGIN
    
  req_po_load_pkg.MAIN(
     errbuf
    ,retcode
    ,1003
    ,'TEST'
    );
    
    DBMS_OUTPUT.PUT_LINE('errbuf'|| errbuf);
    DBMS_OUTPUT.PUT_LINE('retcode' || retcode);
END;

BEGIN
  req_po_load_pkg.SUBMIT_REQUEST
    (
      123
    ,'TEST'
    );
END;