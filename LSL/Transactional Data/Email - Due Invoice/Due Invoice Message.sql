SELECT hca.account_number
      ,hp.party_name
      ,rct.trx_number invoice_number
      ,rct.purchase_order
      ,aps.class
      ,to_char(aps.due_date, 'DD-MON-YY') due_date
      ,to_char(aps.trx_date, 'DD-MON-YY') trx_date
      ,SUM(aps.amount_due_remaining) amount_due_original
      ,to_date(sysdate)-to_date(aps.due_date) days_late
      ,(to_date(aps.due_date) - to_date(aps.trx_date) ||' '|| 'Days Due') due_name
INTO &account_number
    ,&party_name
    ,&account_number
    ,&invoice_number
    ,&purchase_order
    ,&class
    ,&due_date
    ,&trx_date
    ,&amount_due_original
    ,&days_late
    ,&due_name
FROM ar_payment_schedules_all aps
    ,ra_customer_trx_all rct
    ,hz_cust_accounts_all hca
    ,hz_parties hp
WHERE aps.trx_number = rct.trx_number
      AND rct.bill_to_customer_id = hca.cust_account_id
      AND hca.party_id = hp.party_id
      AND aps.amount_due_remaining <> 0
      AND hca.account_number = '007528'
      AND to_date(aps.due_date) <= to_date(sysdate)
GROUP BY hp.party_name
        ,hca.account_number 
        ,rct.trx_number
        ,rct.purchase_order
        ,to_char(aps.due_date, 'DD-MON-YY')
        ,to_char(aps.trx_date, 'DD-MON-YY')
        ,aps.class,to_date(sysdate)-to_date(aps.due_date)
        ,to_date(aps.due_date) - to_date(aps.trx_date)
order by to_date(sysdate)-to_date(aps.due_date) desc;


--MESSAGE
Dear &party_name

Your invoice &invoice_number is due in amount &amount_due_original by &due_date for &days_late days as of today.

Yours Sincerely
LSL Finance