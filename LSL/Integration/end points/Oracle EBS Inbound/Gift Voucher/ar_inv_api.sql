CREATE OR REPLACE procedure xxpbsa_ar_invoice_api
is
        l_return_status         varchar2(1);
        l_msg_count             number;
        l_msg_data              varchar2(2000);
        l_batch_source_rec      ar_invoice_api_pub.batch_source_rec_type;
        l_trx_header_tbl        ar_invoice_api_pub.trx_header_tbl_type;
        l_trx_lines_tbl         ar_invoice_api_pub.trx_line_tbl_type;
        l_trx_dist_tbl          ar_invoice_api_pub.trx_dist_tbl_type;
        l_trx_salescredits_tbl  ar_invoice_api_pub.trx_salescredits_tbl_type;
        l_cust_trx_id           number;

BEGIN
       
 begin
  MO_GLOBAL.SET_POLICY_CONTEXT('S',81);
end;
       
  fnd_global.apps_initialize(0,20678,222);

  l_batch_source_rec.batch_source_id :=  1001;
  l_trx_header_tbl(1).trx_header_id  :=  9896;
  l_trx_header_tbl(1).trx_date       := sysdate;
  l_trx_header_tbl(1).trx_currency   :=  'LKR';
  l_trx_header_tbl(1).cust_trx_type_id :=  1;
  l_trx_header_tbl(1).bill_to_customer_id :=  1040;
  l_trx_header_tbl(1).term_id    :=  5;
  l_trx_header_tbl(1).finance_charges  :=  'N';
  l_trx_header_tbl(1).status_trx   :=  'OP';
  l_trx_header_tbl(1).printing_option :=  'PRI';
  l_trx_header_tbl(1).reference_number :=  '1111';
  
 -- l_trx_header_tbl(1).default_tax_exempt_flag := 'Y';
  --l_trx_lines_tbl(1).TAX_CLASSIFICATION_CODE := NULL;
  l_trx_lines_tbl(1).taxable_flag := 'N';
  
  
  l_trx_lines_tbl(1).trx_header_id :=  9896;
  l_trx_lines_tbl(1).trx_line_id   :=  102;
  l_trx_lines_tbl(1).line_number   :=  1;
  l_trx_lines_tbl(1).inventory_item_id  :=  1291;
  --l_trx_lines_tbl(1).description :=  'CAST IRON'; 
                                             --GRILL-325*485MM';
 l_trx_lines_tbl(1).quantity_invoiced   :=  3;
 l_trx_lines_tbl(1).unit_selling_price :=  525;   --Price
 l_trx_lines_tbl(1).uom_code    :=  null;--'ECH';
 l_trx_lines_tbl(1).line_type   :=  'LINE';
 l_trx_dist_tbl(1).trx_dist_id  :=  102;
 l_trx_dist_tbl(1).trx_line_id  :=  102;
 l_trx_dist_tbl(1).ACCOUNT_CLASS := 'REV';
 l_trx_dist_tbl(1).percent     := 100;
 l_trx_dist_tbl(1).CODE_COMBINATION_ID := 6130;
 
 
 l_trx_header_tbl(1).primary_salesrep_id := -3;

       
--Here we call the API to create Invoice with the stored values


    AR_INVOICE_API_PUB.create_invoice
    (p_api_version          => 1.0
    ,p_commit               => 'T'
    ,p_batch_source_rec     => l_batch_source_rec
    ,p_trx_header_tbl       => l_trx_header_tbl
    ,p_trx_lines_tbl        => l_trx_lines_tbl
    ,p_trx_dist_tbl         => l_trx_dist_tbl
    ,p_trx_salescredits_tbl => l_trx_salescredits_tbl
    ,x_return_status        => l_return_status
    ,x_msg_count            => l_msg_count
    ,x_msg_data             => l_msg_data
    );
   
    dbms_output.put_line('Created:'||l_msg_data||l_return_status);

    IF l_return_status = fnd_api.g_ret_sts_error OR
       l_return_status = fnd_api.g_ret_sts_unexp_error THEN

        dbms_output.put_line(l_return_status||':'||sqlerrm);
    Else
        dbms_output.put_line(l_return_status||':'||sqlerrm);
        If (ar_invoice_api_pub.g_api_outputs.batch_id IS NOT NULL) Then
            Dbms_output.put_line('Invoice(s) suceessfully created!') ;
            Dbms_output.put_line('Batch ID: ' || ar_invoice_api_pub.g_api_outputs.batch_id);
            Dbms_output.put_line('customer_trx_id: ' || l_cust_trx_id);
        Else
            Dbms_output.put_line(sqlerrm);
        End If;
    end if;
    commit;
End;
/

exec xxpbsa_ar_invoice_api;