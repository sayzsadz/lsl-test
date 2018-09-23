create or replace function XXPBSA_CRUD_EBS_SUPPLIERS(p_row_id in varchar2)
return varchar2
as
  l_cursor SYS_REFCURSOR;
  
  cursor cur 
    is
    select vendor_id
    from ap_suppliers@DATABASE_LINK_APEX_EBS aps
    where 1 = 1
          and aps.rowid in (p_row_id);
          --and aps.rowid in (select max(rowid) from ap_suppliers@DATABASE_LINK_APEX_EBS);
BEGIN

  for cur_rec in cur
  loop
  
  OPEN l_cursor FOR
  select  NVL(apsl.attribute10,'test-guid') as "SupplierId"
          ,apsl.vendor_name as "Name"
          ,CURSOR(
          select apss.ADDRESS_LINE1 as "Street"
          ,apss.ADDRESS_LINE2 as  "City"
          ,apss.STATE as "State"
          ,apss.zip "PostCode"
          ,ftl.NLS_TERRITORY AS "Country"
          ,NVL(apsc.first_name || apsc.last_name, aps.vendor_name) as "ContactName"
          ,apsc.phone as "Phone"
          ,apsc.email_address as "Email"
    from ap_suppliers@DATABASE_LINK_APEX_EBS aps
        ,ap_supplier_sites_all@DATABASE_LINK_APEX_EBS apss
        ,ap_supplier_contacts@DATABASE_LINK_APEX_EBS apsc        
        ,hr_locations@DATABASE_LINK_APEX_EBS hla
        ,apps.fnd_territories_vl@DATABASE_LINK_APEX_EBS ftl
    where 1 = 1 
          AND aps.vendor_id = apss.vendor_id
          AND apss.bill_to_location_id = hla.location_id
          AND apss.vendor_site_id = apsc.vendor_site_id(+)
          AND hla.COUNTRY = ftl.TERRITORY_CODE
          AND aps.vendor_id = cur_rec.vendor_id
           ) AS "BillToAddress"
        ,CURSOR(
          select apss.ADDRESS_LINE1 as "Street"
          ,apss.ADDRESS_LINE2 as  "City"
          ,apss.STATE as "State"
          ,apss.zip "PostCode"
          ,ftl.NLS_TERRITORY AS "Country"
          ,NVL(apsc.first_name || apsc.last_name, aps.vendor_name) as "ContactName"
          ,apsc.phone as "Phone"
          ,apsc.email_address as "Email"
    from ap_suppliers@DATABASE_LINK_APEX_EBS aps
        ,ap_supplier_sites_all@DATABASE_LINK_APEX_EBS apss
        ,ap_supplier_contacts@DATABASE_LINK_APEX_EBS apsc        
        ,hr_locations@DATABASE_LINK_APEX_EBS hla
        ,fnd_territories_vl@DATABASE_LINK_APEX_EBS ftl
    where 1 = 1 
          AND aps.vendor_id = apss.vendor_id
          AND apss.ship_to_location_id = hla.location_id
          AND apss.vendor_site_id = apsc.vendor_site_id(+)
          AND hla.COUNTRY = ftl.TERRITORY_CODE
          AND aps.vendor_id = cur_rec.vendor_id
           ) AS "ShipToAddress"
          ,'true' as "Active"
    from ap_suppliers@DATABASE_LINK_APEX_EBS apsl
    where 1 = 1 
          and apsl.vendor_id = cur_rec.vendor_id;

  
  APEX_JSON.initialize_clob_output;

  APEX_JSON.open_object;
  APEX_JSON.write('supplier', l_cursor);
  APEX_JSON.close_object;

  DBMS_OUTPUT.put_line(APEX_JSON.get_clob_output);
  APEX_JSON.free_output;
  end loop;
  
  return APEX_JSON.get_clob_output;
  
END;
/

begin
DBMS_OUTPUT.put_line(XXPBSA_CRUD_EBS_SUPPLIERS('AABgJKAGSAAAKnEAAA'));
XXPBSA_UPDATE_SUP_GUID@DATABASE_LINK_APEX_EBS(XXPBSA_CRUD_EBS_SUPPLIERS('AABgJKAGSAAAKnEAAA'));
end;