exec mo_global.init('SQLAP');
exec mo_global.set_policy_context('S',81);

select *
from ap_suppliers
where vendor_name  = 'Lanka Sathosa - Uduwana';

update ap_suppliers
set attribute10 = (select SUPPLIERID from XXLSL_SUPPLIERS_TEMP where name = vendor_name)
where vendor_name = (select name from XXLSL_SUPPLIERS_TEMP where name = vendor_name)
      and vendor_name in (
      'Lanka Sathosa - Hettipola',
      'Lanka Sathosa - Katunayake 01',
      'Lanka Sathosa - Uduwana'
      );

alter session set nls_language = 'AMERICAN';

-- API to Create Supplier

DECLARE
   l_vendor_rec       ap_vendor_pub_pkg.r_vendor_rec_type;
   l_return_status    VARCHAR2(10);
   l_msg_count        NUMBER;
   l_msg_data         VARCHAR2(20000);
   l_vendor_id        NUMBER;
   l_party_id         NUMBER;

cursor sup_cur is
  select  SEGMENT1 
         ,VENDOR_NAME
         ,PAY_GROUP_LOOKUP_CODE
         ,PAY_TYPE TERMS_NAME
         ,AUTO_TAX_CALC_FLAG
  from xxpbsa_sup_stg
  where STATUS is null;


BEGIN

  
   FOR c1 in sup_cur
   LOOP

   -- --------------
   -- Required
   -- --------------
   
   l_vendor_rec.segment1                := c1.segment1;
   l_vendor_rec.vendor_name             := c1.vendor_name;
   l_vendor_rec.PAY_GROUP_LOOKUP_CODE   := c1.PAY_GROUP_LOOKUP_CODE;
   l_vendor_rec.TERMS_NAME              := c1.TERMS_NAME;
   l_vendor_rec.AUTO_TAX_CALC_FLAG      := NVL(c1.AUTO_TAX_CALC_FLAG,'N');
 
   -- -------------
   -- Optional
   -- --------------
   --l_vendor_rec.match_option  :='R';
   -- l_vendor_rec.vendor_name_alt := 'DEMO00145234';
   -- l_vendor_rec.start_date_active := sysdate - 1;
    
   pos_vendor_pub_pkg.create_vendor
   (    -- -------------------------
        -- Input Parameters
        -- -------------------------
        p_vendor_rec          => l_vendor_rec,
        -- ----------------------------
        -- Output Parameters
        -- ----------------------------
        x_return_status       => l_return_status,
        x_msg_count           => l_msg_count,
        x_msg_data            => l_msg_data,
        x_vendor_id           => l_vendor_id,
        x_party_id            => l_party_id
   );
   
   update xxpbsa_sup_stg
   set status = 'P', ERROR_CODE = l_msg_data||l_vendor_id||l_party_id
   where vendor_name = c1.vendor_name;
   
   COMMIT;
   
   END LOOP;

END;
/