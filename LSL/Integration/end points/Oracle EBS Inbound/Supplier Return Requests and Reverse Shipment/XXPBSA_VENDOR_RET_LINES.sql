create or replace procedure XXPBSA_VENDOR_RET_LINES(p_errbuf OUT VARCHAR2, p_retcode OUT VARCHAR2)
as
     v_request_id         number;
     
     lv_status            VARCHAR2(10);
     lv_dev_status        VARCHAR2(10);
     lv_message           VARCHAR2(100);
     ln_interval          NUMBER;
     lv_dev_phase         VARCHAR2(10);
     lv_phase             VARCHAR2(10);
     callv_status         BOOLEAN ;
     wait_status          BOOLEAN ;
BEGIN
apps.mo_global.init ('PO');
apps.mo_global.set_policy_context ('S',204);
apps.fnd_global.apps_initialize ( user_id => 0, resp_id => 20707, resp_appl_id => 201 );
--------CALLING STANDARD RECEIVING TRANSACTION PROCESSOR ---------------------------------

  v_request_id   := apps.fnd_request.submit_request ( application => 'PO', 
                                                      PROGRAM => 'RVCTP', 
                                                      argument1 => 'BATCH', 
                                                      argument2 => apps.rcv_interface_groups_s.currval, 
                                                      argument3 => 81);
                                                      commit;
    dbms_output.put_line('Request Id '||v_request_id);                                                 

   wait_status := fnd_concurrent.wait_for_request (v_request_id, 60 , 0, lv_phase , lv_status , lv_dev_phase, lv_dev_status, lv_message);
    -- callv_status :=fnd_concurrent.get_request_status(ln_request_id, '', '',
    --          rphase,rstatus,dphase,dstatus, message);
    fnd_file.put_line(fnd_file.log,'dphase = '||lv_dev_phase||'and '||'dstatus ='||lv_dev_status) ;
    IF UPPER(lv_dev_phase)='COMPLETE' AND UPPER(lv_dev_status)= 'NORMAL' THEN
      dbms_output.put_line ('Return to Vendor program completed successfully');
      fnd_file.put_line(fnd_file.log,'Return to Vendor program completed successfully');
    END IF;


END;
    /