create or replace function XXPBSA_CRUD_EBS_SUPPLIERS
return varchar2
as
  l_cursor SYS_REFCURSOR;
  l_msg    varchar2(20000);
  
  cursor cur 
    is
    select aps.vendor_id, apsa.vendor_site_id, vendor_name
    from ap_suppliers@DATABASE_LINK_APEX_EBS aps
        ,ap_supplier_sites_all@DATABASE_LINK_APEX_EBS apsa
    where 1 = 1
          --and aps.rowid in (p_row_id);
          --and aps.rowid in (select max(rowid) from ap_suppliers@DATABASE_LINK_APEX_EBS)
          AND aps.vendor_id = apsa.vendor_id
          and aps.attribute11 is null
          and rownum = 1
    order by aps.last_update_date desc, apsa.last_update_date desc;
BEGIN

  for cur_rec in cur
  loop

    SELECT json_object(
                                   'SupplierId'     VALUE NVL(apsl.attribute10,NULL),
                                   'Name'           VALUE apsl.vendor_name,
                                   'BillToAddress'  VALUE (
                                                             json_object('Street'    VALUE BillToAddress.Street,
                                                                         'City'             VALUE BillToAddress.City,
                                                                         'State'                VALUE BillToAddress.State,
                                                                         'PostCode'                 VALUE BillToAddress.PostCode,
                                                                         'Country'                     VALUE BillToAddress.Country,
                                                                         'ContactName'              VALUE BillToAddress.ContactName,
                                                                         'Phone'           VALUE BillToAddress.phone,
                                                                         'Email'            VALUE BillToAddress.email
                                                                         )
                                                                         ),
                                  'ShipToAddress'  VALUE (
                                                             json_object('Street'    VALUE ShipToAddress.Street,
                                                                         'City'             VALUE ShipToAddress.City,
                                                                         'State'                VALUE ShipToAddress.State,
                                                                         'PostCode'                 VALUE ShipToAddress.PostCode,
                                                                         'Country'                     VALUE ShipToAddress.Country,
                                                                         'ContactName'              VALUE ShipToAddress.ContactName,
                                                                         'Phone'           VALUE ShipToAddress.Phone,
                                                                         'Email'            VALUE ShipToAddress.Email
                                                                         )
                                                                         ),
                                  'Active'         VALUE dummy.Active
                                  FORMAT JSON)
    into l_msg
    from (select 'true' as Active from dual) dummy,
         ap_suppliers@DATABASE_LINK_APEX_EBS apsl,
         ap_supplier_sites_all@DATABASE_LINK_APEX_EBS apssl,
         (
          select apss.ADDRESS_LINE1 as Street
          ,apss.ADDRESS_LINE2 as  City
          ,apss.STATE as State
          ,apss.zip PostCode
          ,ftl.NLS_TERRITORY AS Country
          ,NVL(apsc.first_name || apsc.last_name, aps.vendor_name) as ContactName
          ,apsc.phone as Phone
          ,apsc.email_address as Email
          ,apss.vendor_site_id
          ,aps.vendor_id
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
          
         ) BillToAddress,
         (
         select apss.ADDRESS_LINE1 as Street
          ,apss.ADDRESS_LINE2 as  City
          ,apss.STATE as State
          ,apss.zip as PostCode
          ,ftl.NLS_TERRITORY AS Country
          ,NVL(apsc.first_name || apsc.last_name, aps.vendor_name) as ContactName
          ,apsc.phone as Phone
          ,apsc.email_address as Email
          ,apss.vendor_site_id
          ,aps.vendor_id
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
          
         ) ShipToAddress
    where 1 = 1 
          AND BillToAddress.vendor_id = apsl.vendor_id
          AND ShipToAddress.vendor_id = apsl.vendor_id
          AND BillToAddress.vendor_site_id = apssl.vendor_site_id
          AND ShipToAddress.vendor_site_id = apssl.vendor_site_id
          AND apsl.vendor_id = apssl.vendor_id
          AND apsl.vendor_id = cur_rec.vendor_id
          AND apssl.vendor_site_id = cur_rec.vendor_site_id
          ;
  
  end loop;
  
  return l_msg;
  
END;
/

begin
DBMS_OUTPUT.put_line(XXPBSA_CRUD_EBS_SUPPLIERS);
--XXPBSA_UPDATE_SUP_GUID@DATABASE_LINK_APEX_EBS(XXPBSA_CRUD_EBS_SUPPLIERS('AABgJKAGSAAAKnEAAA'));
end;