select attribute10, segment1, vendor_name
from ap_suppliers
where segment1 = '2';

select organization_id, attribute10
from mtl_system_items_b
where segment1 = '000002';

begin
XXPBSA_UPDATE_SUP_GUID('
{
"supplier":[{"SupplierId":"test-guid","Name":"Test-Anchor","BillToAddress":[{"Street":"Galle face","PostCode":"01400","Country":"SRI LANKA","ContactName":"Test-Anchor"}],"ShipToAddress":[{"Street":"Galle face","PostCode":"01400","Country":"SRI LANKA","ContactName":"Test-Anchor"}],"Active":true}]
}
');
end;
create or replace procedure XXPBSA_UPDATE_SUP_GUID(p_data varchar2)
as
    l_vendor_rec ap_vendor_pub_pkg.r_vendor_rec_type;
    l_return_status VARCHAR2(10);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(1000);
    l_vendor_id NUMBER;
    l_party_id NUMBER;
    
    cursor cur is
    
                        SELECT SUPPLIER_NAME
                             , SUPPLIERID
                        FROM 
                             JSON_TABLE(
                             p_data
--                             '
--                             {
--"supplier":[{"SupplierId":"test-guid","Name":"Test-Anchor","BillToAddress":[{"Street":"Galle face","PostCode":"01400","Country":"SRI LANKA","ContactName":"Test-Anchor"}],"ShipToAddress":[{"Street":"Galle face","PostCode":"01400","Country":"SRI LANKA","ContactName":"Test-Anchor"}],"Active":true}]
--}
--                             '
                             , '$.supplier[*]' COLUMNS (
                              supplier_name varchar2(30) PATH '$.Name',
                              SupplierId    varchar2(100) PATH '$.SupplierId'
                              )
                        ) JT;

BEGIN

    --
    -- Required
    --
    for cur_rec in cur
    loop
    begin
    SELECT vendor_id
    INTO   l_vendor_rec.vendor_id
    FROM   pos_po_vendors_v
    WHERE  vendor_name = cur_rec.SUPPLIER_NAME;

--   _______________________________________________________ 
--  |                                                       |
--  | NOTE: Name and Alt Name Cannot Be Updated By This API |
--  |_______________________________________________________|
--
    
    --
    -- Optional
    --
    l_vendor_rec.attribute10 := cur_rec.SUPPLIERID;

    -- etc.. --

    pos_vendor_pub_pkg.update_vendor(
        p_vendor_rec => l_vendor_rec,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data);

    
  exception
    when others then
      dbms_output.put_line(''||sqlerrm);
    end;
    end loop;

COMMIT;    

    dbms_output.put_line('return_status: '||l_return_status);
    dbms_output.put_line('msg_data: '||l_msg_data);
END;
/
