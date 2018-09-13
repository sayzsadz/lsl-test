DECLARE
        l_vendor_site_rec         ap_vendor_pub_pkg.r_vendor_site_rec_type;
        l_vendor_id               NUMBER;
        l_msg                    VARCHAR2(200);
        x_return_status          VARCHAR2(10);
        x_msg_count              NUMBER;
        x_msg_data               VARCHAR2(1000);
        x_vendor_site_id         NUMBER;
        x_party_site_id          NUMBER;
        x_location_id            NUMBER;
        ln_api_version           NUMBER;
        lv_init_msg_list         VARCHAR2(200);
        lv_commit                VARCHAR2(200);
        ln_validation_level      NUMBER;
        
  cursor sup_cur is
  select  VENDOR_NAME
  from xxpbsa_sup_stg;
  
  cursor sup_site_cur(p_vendor_name varchar2) is
  select COUNTRY
        ,ADDRESS_LINE1
        ,ADDRESS_LINE2
        ,ADDRESS_LINE3
  from xxpbsa_sup_site_stg
  where vendor_name = p_vendor_name;

BEGIN

FOR c in sup_cur
LOOP
   FOR c1 in sup_site_cur(c.vendor_name)
   LOOP
      
        select vendor_id
        into l_vendor_id
        from AP_SUPPLIERS
        where vendor_name = c.vendor_name;
  
  ln_api_version      := 1.0;
  
  lv_init_msg_list    := fnd_api.g_true;
  lv_commit           := fnd_api.g_true;
  ln_validation_level := fnd_api.g_valid_level_full;
  -- Initialize apps session
  fnd_global.apps_initialize(0, 20639, 200);
  mo_global.init('SQLAP');
  fnd_client_info.set_org_context(81);
  
        select location_id
        into  l_vendor_site_rec.bill_to_location_id
        from HR_LOCATIONS_ALL
        where LOCATION_CODE = 'Sri Lanka';
        
        select SHIP_TO_LOCATION_ID
        into l_vendor_site_rec.ship_to_location_id
        from HR_LOCATIONS_ALL
        where  LOCATION_CODE = 'LSL Main Warehouse';
        
        select LOCATION_ID
        into l_vendor_site_rec.location_id
        from HZ_LOCATIONS
        where LOCATION_ID = 182;
        
  l_vendor_site_rec.vendor_site_id                := NULL;
  l_vendor_site_rec.last_update_date              := SYSDATE;
  l_vendor_site_rec.last_updated_by               := 0;
  l_vendor_site_rec.vendor_id                     := l_vendor_id;
  l_vendor_site_rec.org_id                        := 81;
  l_vendor_site_rec.vendor_site_code              := 'SupplierSite-'||l_vendor_id;

  l_vendor_site_rec.address_style                 := 'POSTAL_ADDR_DEF';
  l_vendor_site_rec.country                       := c1.country;
  l_vendor_site_rec.address_line1                 := c1.address_line1;
  l_vendor_site_rec.address_line2                 := '345fgh';
  l_vendor_site_rec.address_line3                 := '134';
  l_vendor_site_rec.address_line4                 := 'Colombo';
  l_vendor_site_rec.city                          := 'Colombo 8';
  
  ap_vendor_pub_pkg.create_vendor_site(p_api_version      => ln_api_version,
                                       p_init_msg_list    => lv_init_msg_list,
                                       p_commit           => lv_commit,
                                       p_validation_level => ln_validation_level,
                                       x_return_status    => x_return_status,
                                       x_msg_count        => x_msg_count,
                                       x_msg_data         => x_msg_data,
                                       p_vendor_site_rec  => l_vendor_site_rec,
                                       x_vendor_site_id   => x_vendor_site_id,
                                       x_party_site_id    => x_party_site_id,
                                       x_location_id      => x_location_id);
  
  DBMS_OUTPUT.put_line('X_RETURN_STATUS = ' || x_return_status);
  DBMS_OUTPUT.put_line('X_MSG_COUNT = ' || x_msg_count);
  DBMS_OUTPUT.put_line('X_MSG_DATA = ' || x_msg_data);
  DBMS_OUTPUT.put_line('X_VENDOR_SITE_ID = ' || x_vendor_site_id);
  DBMS_OUTPUT.put_line('X_PARTY_SITE_ID = ' || x_party_site_id);
  DBMS_OUTPUT.put_line('X_LOCATION_ID = ' || x_location_id);


        IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
            FOR i IN 1 .. fnd_msg_pub.count_msg LOOP
              l_msg := fnd_msg_pub.get(p_msg_index => i,
                                       p_encoded   => fnd_api.g_false);
              DBMS_OUTPUT.put_line('The API call failed with error ' || l_msg);
            END LOOP;
        ELSE
            DBMS_OUTPUT.put_line('The API call ended with SUCESSS status');
            END IF;

  END LOOP;  
END LOOP;
END;
/