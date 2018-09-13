DECLARE
    l_vendor_contact_rec ap_vendor_pub_pkg.r_vendor_contact_rec_type;
    l_return_status VARCHAR2(10);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(1000);
    l_vendor_contact_id NUMBER;
    l_per_party_id NUMBER;
    l_rel_party_id NUMBER;
    l_rel_id NUMBER;
    l_org_contact_id NUMBER;
    l_party_site_id NUMBER;
    
  cursor sup_cur is
  select  VENDOR_NAME
  from xxpbsa_sup_stg;
  
  cursor sup_con_cur(p_vendor_name varchar2) is
  select  VENDOR_NAME
         ,FIRST_NAME
         ,PHONE
         ,FAX
  from xxpbsa_sup_con_stg
  where VENDOR_NAME = p_vendor_name;
  
BEGIN

FOR c in sup_cur
  LOOP
    FOR c1 in sup_con_cur(c.vendor_name)
      LOOP
        -- Assign Contact Details
        
        select vendor_id
        into  l_vendor_contact_rec.vendor_id
        from AP_SUPPLIERS
        where vendor_name = c.vendor_name;

    --
    -- Required
    --

    l_vendor_contact_rec.org_id := 81;  
    l_vendor_contact_rec.person_first_name := c1.first_name;  
    l_vendor_contact_rec.person_last_name := c1.first_name;  


    pos_vendor_pub_pkg.create_vendor_contact(
        p_vendor_contact_rec => l_vendor_contact_rec,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data,
        x_vendor_contact_id => l_vendor_contact_id,
        x_per_party_id => l_per_party_id,
        x_rel_party_id => l_rel_party_id,
        x_rel_id => l_rel_id,
        x_org_contact_id => l_org_contact_id,
        x_party_site_id => l_party_site_id);

    COMMIT;

    dbms_output.put_line('return_status: '||l_return_status);
    dbms_output.put_line('msg_data: '||l_msg_data);
    dbms_output.put_line('vendor_contact_id: '||l_vendor_contact_id);
    dbms_output.put_line('party_site_id: '||l_party_site_id);
    dbms_output.put_line('per_party_id: '||l_per_party_id);
    dbms_output.put_line('rel_party_id: '||l_rel_party_id);
    dbms_output.put_line('rel_id: '||l_rel_id);
    dbms_output.put_line('org_contact_id: '||l_org_contact_id);
    
  END LOOP;
END LOOP;
END;
/