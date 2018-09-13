DECLARE
  ln_api_version           NUMBER;
  lv_init_msg_list         VARCHAR2(200);
  lv_commit                VARCHAR2(200);
  ln_validation_level      NUMBER;
  x_return_status          VARCHAR2(200);
  x_msg_count              NUMBER;
  x_msg_data               VARCHAR2(200);
  lr_sp_st              apps.ap_vendor_pub_pkg.r_vendor_site_rec_type;
  lr_ex_sp_st           ap_supplier_sites_all%ROWTYPE;
  x_vendor_site_id         NUMBER;
  x_party_site_id          NUMBER;
  x_location_id            NUMBER;
  ln_new_org_id            NUMBER DEFAULT 81;
  l_msg                    VARCHAR2(200);
  pin_exist_vendor_site_id NUMBER DEFAULT '2040';
BEGIN
  ln_api_version      := 1.0;
  lv_init_msg_list    := fnd_api.g_true;
  lv_commit           := fnd_api.g_true;
  ln_validation_level := fnd_api.g_valid_level_full;
  -- Initialize apps session
  fnd_global.apps_initialize(0, 20639, 200);
  mo_global.init('SQLAP');
  fnd_client_info.set_org_context(81);

  BEGIN
      SELECT *
      INTO lr_ex_sp_st
      FROM ap_supplier_sites_all assa
      WHERE assa.vendor_site_id = 11;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.put_line('Unable to derive the supplier site information for site id:' ||
                           pin_exist_vendor_site_id);
  END;

  lr_sp_st.vendor_site_id                := NULL;
  lr_sp_st.last_update_date              := SYSDATE;
  lr_sp_st.last_updated_by               := 0;
  lr_sp_st.vendor_id                     := lr_ex_sp_st.vendor_id;
  lr_sp_st.org_id                        := ln_new_org_id;
  lr_sp_st.vendor_site_code              := SUBSTR('_NEW1' ||
                                                      lr_ex_sp_st.vendor_site_code,
                                                      1,
                                                      15);
--  lr_sp_st.vendor_site_code_alt          := NULL;
--  lr_sp_st.area_code                     := lr_ex_sp_st.area_code;
--  lr_sp_st.phone                         := lr_ex_sp_st.phone;
  --lr_sp_st.customer_num                  := lr_ex_sp_st.customer_num;
  lr_sp_st.ship_to_location_id           := lr_ex_sp_st.ship_to_location_id;
  lr_sp_st.bill_to_location_id           := lr_ex_sp_st.bill_to_location_id;
  --lr_sp_st.ship_via_lookup_code          := lr_ex_sp_st.ship_via_lookup_code;
--  lr_sp_st.freight_terms_lookup_code     := lr_ex_sp_st.freight_terms_lookup_code;
--  lr_sp_st.fob_lookup_code               := lr_ex_sp_st.fob_lookup_code;
--  lr_sp_st.inactive_date                 := lr_ex_sp_st.inactive_date;
--  lr_sp_st.fax                           := lr_ex_sp_st.fax;
--  lr_sp_st.fax_area_code                 := lr_ex_sp_st.fax_area_code;
--  lr_sp_st.telex                         := lr_ex_sp_st.telex;
--  lr_sp_st.terms_date_basis              := lr_ex_sp_st.terms_date_basis;
--  lr_sp_st.distribution_set_id           := lr_ex_sp_st.distribution_set_id;
--  lr_sp_st.accts_pay_code_combination_id := lr_ex_sp_st.accts_pay_code_combination_id;
--  lr_sp_st.prepay_code_combination_id    := lr_ex_sp_st.prepay_code_combination_id;
--  lr_sp_st.pay_group_lookup_code         := lr_ex_sp_st.pay_group_lookup_code;
--  lr_sp_st.payment_priority              := lr_ex_sp_st.payment_priority;
--  lr_sp_st.terms_id                      := lr_ex_sp_st.terms_id;
--  lr_sp_st.invoice_amount_limit          := lr_ex_sp_st.invoice_amount_limit;
--  lr_sp_st.pay_date_basis_lookup_code    := lr_ex_sp_st.pay_date_basis_lookup_code;
--  lr_sp_st.always_take_disc_flag         := lr_ex_sp_st.always_take_disc_flag;
--  lr_sp_st.invoice_currency_code         := lr_ex_sp_st.invoice_currency_code;
--  lr_sp_st.payment_currency_code         := lr_ex_sp_st.payment_currency_code;
--  lr_sp_st.purchasing_site_flag          := lr_ex_sp_st.purchasing_site_flag;
--  lr_sp_st.rfq_only_site_flag            := lr_ex_sp_st.rfq_only_site_flag;
--  lr_sp_st.pay_site_flag                 := lr_ex_sp_st.pay_site_flag;
--  lr_sp_st.attention_ar_flag             := lr_ex_sp_st.attention_ar_flag;
--  lr_sp_st.hold_all_payments_flag        := lr_ex_sp_st.hold_all_payments_flag;
--  lr_sp_st.hold_future_payments_flag     := lr_ex_sp_st.hold_future_payments_flag;
--  lr_sp_st.hold_reason                   := lr_ex_sp_st.hold_reason;
--  lr_sp_st.hold_unmatched_invoices_flag  := lr_ex_sp_st.hold_unmatched_invoices_flag;
--  lr_sp_st.tax_reporting_site_flag       := lr_ex_sp_st.tax_reporting_site_flag;
--  lr_sp_st.attribute_category            := lr_ex_sp_st.attribute_category;
--  lr_sp_st.attribute1                    := lr_ex_sp_st.attribute1;
--  lr_sp_st.attribute2                    := lr_ex_sp_st.attribute2;
--  lr_sp_st.attribute3                    := lr_ex_sp_st.attribute3;
--  lr_sp_st.attribute4                    := lr_ex_sp_st.attribute4;
--  lr_sp_st.attribute5                    := lr_ex_sp_st.attribute5;
--  lr_sp_st.attribute6                    := lr_ex_sp_st.attribute6;
--  lr_sp_st.attribute7                    := lr_ex_sp_st.attribute7;
--  lr_sp_st.attribute8                    := lr_ex_sp_st.attribute8;
--  lr_sp_st.attribute9                    := lr_ex_sp_st.attribute9;
--  lr_sp_st.attribute10                   := lr_ex_sp_st.attribute10;
--  lr_sp_st.attribute11                   := lr_ex_sp_st.attribute11;
--  lr_sp_st.attribute12                   := lr_ex_sp_st.attribute12;
--  lr_sp_st.attribute13                   := lr_ex_sp_st.attribute13;
--  lr_sp_st.attribute14                   := lr_ex_sp_st.attribute14;
--  lr_sp_st.attribute15                   := lr_ex_sp_st.attribute15;
--  lr_sp_st.validation_number             := NULL;
--  lr_sp_st.exclude_freight_from_discount := lr_ex_sp_st.exclude_freight_from_discount;
--  lr_sp_st.bank_charge_bearer            := lr_ex_sp_st.bank_charge_bearer;
--  lr_sp_st.check_digits                  := lr_ex_sp_st.check_digits;
--  lr_sp_st.allow_awt_flag                := lr_ex_sp_st.allow_awt_flag;
--  lr_sp_st.awt_group_id                  := NULL;
--  lr_sp_st.pay_awt_group_id              := NULL;
--  lr_sp_st.default_pay_site_id           := NULL;
--  lr_sp_st.pay_on_code                   := lr_ex_sp_st.pay_on_code;
--  lr_sp_st.pay_on_receipt_summary_code   := lr_ex_sp_st.pay_on_receipt_summary_code;
--  lr_sp_st.global_attribute_category     := lr_ex_sp_st.global_attribute_category;
--  lr_sp_st.global_attribute1             := lr_ex_sp_st.global_attribute1;
--  lr_sp_st.global_attribute2             := lr_ex_sp_st.global_attribute2;
--  lr_sp_st.global_attribute3             := lr_ex_sp_st.global_attribute3;
--  lr_sp_st.global_attribute4             := lr_ex_sp_st.global_attribute4;
--  lr_sp_st.global_attribute5             := lr_ex_sp_st.global_attribute5;
--  lr_sp_st.global_attribute6             := lr_ex_sp_st.global_attribute6;
--  lr_sp_st.global_attribute7             := lr_ex_sp_st.global_attribute7;
--  lr_sp_st.global_attribute8             := lr_ex_sp_st.global_attribute8;
--  lr_sp_st.global_attribute9             := lr_ex_sp_st.global_attribute9;
--  lr_sp_st.global_attribute10            := lr_ex_sp_st.global_attribute10;
--  lr_sp_st.global_attribute11            := lr_ex_sp_st.global_attribute11;
--  lr_sp_st.global_attribute12            := lr_ex_sp_st.global_attribute12;
--  lr_sp_st.global_attribute13            := lr_ex_sp_st.global_attribute13;
--  lr_sp_st.global_attribute14            := lr_ex_sp_st.global_attribute14;
--  lr_sp_st.global_attribute15            := lr_ex_sp_st.global_attribute15;
--  lr_sp_st.global_attribute16            := lr_ex_sp_st.global_attribute16;
--  lr_sp_st.global_attribute17            := lr_ex_sp_st.global_attribute17;
--  lr_sp_st.global_attribute18            := lr_ex_sp_st.global_attribute18;
--  lr_sp_st.global_attribute19            := lr_ex_sp_st.global_attribute19;
--  lr_sp_st.global_attribute20            := lr_ex_sp_st.global_attribute20;
--  lr_sp_st.tp_header_id                  := NULL;
--  lr_sp_st.ece_tp_location_code          := lr_ex_sp_st.ece_tp_location_code;
--  lr_sp_st.pcard_site_flag               := lr_ex_sp_st.pcard_site_flag;
--  lr_sp_st.match_option                  := lr_ex_sp_st.match_option;
--  lr_sp_st.country_of_origin_code        := lr_ex_sp_st.country_of_origin_code;
--  lr_sp_st.future_dated_payment_ccid     := lr_ex_sp_st.future_dated_payment_ccid;
--  lr_sp_st.create_debit_memo_flag        := lr_ex_sp_st.create_debit_memo_flag;
--  lr_sp_st.supplier_notif_method         := lr_ex_sp_st.supplier_notif_method;
--  lr_sp_st.email_address                 := lr_ex_sp_st.email_address;
--  lr_sp_st.primary_pay_site_flag         := lr_ex_sp_st.primary_pay_site_flag;
--  lr_sp_st.shipping_control              := lr_ex_sp_st.shipping_control;
--  lr_sp_st.selling_company_identifier    := lr_ex_sp_st.selling_company_identifier;
--  lr_sp_st.gapless_inv_num_flag          := lr_ex_sp_st.gapless_inv_num_flag;
  lr_sp_st.location_id                   := lr_ex_sp_st.location_id;
  --lr_sp_st.party_site_id                 := lr_ex_sp_st.party_site_id;
--  lr_sp_st.duns_number                   := lr_ex_sp_st.duns_number;
  lr_sp_st.address_style                 := lr_ex_sp_st.address_style;
  lr_sp_st.LANGUAGE                      := lr_ex_sp_st.LANGUAGE;
  lr_sp_st.province                      := lr_ex_sp_st.province;
  lr_sp_st.country                       := lr_ex_sp_st.country;
  lr_sp_st.address_line1                 := lr_ex_sp_st.address_line1;
  lr_sp_st.address_line2                 := lr_ex_sp_st.address_line2;
  lr_sp_st.address_line3                 := lr_ex_sp_st.address_line3;
  lr_sp_st.address_line4                 := lr_ex_sp_st.address_line4;
--  lr_sp_st.address_lines_alt             := lr_ex_sp_st.address_lines_alt;
  lr_sp_st.county                        := lr_ex_sp_st.county;
  lr_sp_st.city                          := lr_ex_sp_st.city;
--  lr_sp_st.state                         := lr_ex_sp_st.state;
--  lr_sp_st.zip                           := lr_ex_sp_st.zip;
--  lr_sp_st.terms_name                    := NULL; --AP_TERMS_TL.NAME;
--  lr_sp_st.default_terms_id              := NULL;
--  lr_sp_st.awt_group_name                := NULL; --AP_AWT_GROUPS.NAME;
--  lr_sp_st.pay_awt_group_name            := NULL; --AP_AWT_GROUPS.NAME;
--  lr_sp_st.distribution_set_name         := NULL;
--  --AP_DISTRIBUTION_SETS_ALL.DISTRIBUTION_SET_NAME;
--  lr_sp_st.ship_to_location_code := NULL;
--  --HR_LOCATIONS_ALL_TL.LOCATION_CODE;
--  lr_sp_st.bill_to_location_code := NULL;
--  --HR_LOCATIONS_ALL_TL.LOCATION_CODE;
--  lr_sp_st.default_dist_set_id        := NULL;
--  lr_sp_st.default_ship_to_loc_id     := NULL;
--  lr_sp_st.default_bill_to_loc_id     := NULL;
--  lr_sp_st.tolerance_id               := lr_ex_sp_st.tolerance_id;
--  lr_sp_st.vendor_interface_id        := NULL;
--  lr_sp_st.vendor_site_interface_id   := NULL;
--  lr_sp_st.retainage_rate             := lr_ex_sp_st.retainage_rate;
--  lr_sp_st.services_tolerance_id      := lr_ex_sp_st.services_tolerance_id;
--  lr_sp_st.shipping_location_id       := NULL;
--  lr_sp_st.vat_code                   := lr_ex_sp_st.vat_code;
--  lr_sp_st.vat_registration_num       := lr_ex_sp_st.vat_registration_num;
--  lr_sp_st.remittance_email           := lr_ex_sp_st.remittance_email;
--  lr_sp_st.edi_id_number              := lr_ex_sp_st.edi_id_number;
--  lr_sp_st.edi_payment_format         := lr_ex_sp_st.edi_payment_format;
--  lr_sp_st.edi_transaction_handling   := lr_ex_sp_st.edi_transaction_handling;
--  lr_sp_st.edi_payment_method         := lr_ex_sp_st.edi_payment_method;
--  lr_sp_st.edi_remittance_method      := lr_ex_sp_st.edi_remittance_method;
--  lr_sp_st.edi_remittance_instruction := lr_ex_sp_st.edi_remittance_instruction;
--  lr_sp_st.offset_tax_flag            := lr_ex_sp_st.offset_tax_flag;
--  lr_sp_st.auto_tax_calc_flag         := lr_ex_sp_st.auto_tax_calc_flag;
--  lr_sp_st.cage_code                  := lr_ex_sp_st.cage_code;
--  lr_sp_st.legal_business_name        := lr_ex_sp_st.legal_business_name;
--  lr_sp_st.doing_bus_as_name          := lr_ex_sp_st.doing_bus_as_name;
--  lr_sp_st.division_name              := lr_ex_sp_st.division_name;
--  lr_sp_st.small_business_code        := lr_ex_sp_st.small_business_code;
--  lr_sp_st.ccr_comments               := lr_ex_sp_st.ccr_comments;
--  lr_sp_st.debarment_start_date       := lr_ex_sp_st.debarment_start_date;
--  lr_sp_st.debarment_end_date         := lr_ex_sp_st.debarment_end_date;
  --ZX_PARTY_TAX_PROFILE
  --lr_sp_st.ap_tax_rounding_rule := lr_ex_sp_st.ap_tax_rounding_rule;
  --ZX_PARTY_TAX_PROFILE
  --lr_sp_st.amount_includes_tax_flag := lr_ex_sp_st.amount_includes_tax_flag;
  --lr_sp_st.TOLERANCE_NAME              AP_TOLERANCE_TEMPLATES.TOLERANCE_NAME;
  --lr_sp_st.ORG_NAME                    HR_OPERATING_UNITS.NAME;
  --lr_sp_st.EXT_PAYEE_REC               IBY_DISBURSEMENT_SETUP_PUB.EXTERNAL_PAYEE_REC_TYPE;
  --lr_sp_st.SERVICES_TOLERANCE_NAME     AP_TOLERANCE_TEMPLATES.TOLERANCE_NAME;
  --lr_sp_st.PARTY_SITE_NAME             HZ_PARTY_SITES.PARTY_SITE_NAME ;
  --Not available in Supplier Sites all table
  --lr_sp_st.REMIT_ADVICE_DELIVERY_METHOD AP_SUPPLIER_SITES_INT.REMIT_ADVICE_DELIVERY_METHOD  ;
  --lr_sp_st.REMIT_ADVICE_FAX             AP_SUPPLIER_SITES_INT.REMIT_ADVICE_FAX ;
  ap_vendor_pub_pkg.create_vendor_site(p_api_version      => ln_api_version,
                                       p_init_msg_list    => lv_init_msg_list,
                                       p_commit           => lv_commit,
                                       p_validation_level => ln_validation_level,
                                       x_return_status    => x_return_status,
                                       x_msg_count        => x_msg_count,
                                       x_msg_data         => x_msg_data,
                                       p_vendor_site_rec  => lr_sp_st,
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
END;
/