  create or replace PROCEDURE XXPBSA_REQ_JE_IMPORT (p_source_name varchar2)
  IS
 
   l_conc_id          NUMBER;
   l_int_run_id       NUMBER;
   l_access_set_id    NUMBER;
   l_org_id           NUMBER := 81;
   l_sob_id           NUMBER := 2021;
   l_user_id          NUMBER := 0;
   l_resp_id          NUMBER := 20475;
   l_resp_app_id      NUMBER := 101;
   l_source_name      varchar2(100);
 
BEGIN
   l_source_name := p_source_name;
  
   fnd_global.apps_initialize
   (
      user_id       => l_user_id       --User Id
      ,resp_id      => l_resp_id       --Responsibility Id
      ,resp_appl_id => l_resp_app_id   --Responsibility Application Id
   );
 
   mo_global.set_policy_context('S',l_org_id);
 
   SELECT   gl_journal_import_s.NEXTVAL
     INTO   l_int_run_id
     FROM   dual;
 
   SELECT   ACCESS_SET_ID
   INTO   l_access_set_id
     FROM   gl_access_sets
    WHERE   name = 'LSL Ledger' ;
 
   INSERT INTO gl_interface_control
   (
      je_source_name
      ,interface_run_id
      ,status
      ,set_of_books_id
   )
   VALUES
   (
      l_source_name
      ,l_int_run_id
      ,'S'
      ,l_sob_id
   );
 
   l_conc_id := fnd_request.submit_request
                   ( application   => 'SQLGL'
                    ,program       => 'GLLEZL'
                    ,description   => NULL
                    ,start_time    => SYSDATE
                    ,sub_request   => FALSE
                    ,argument1     => l_int_run_id    --interface run id
                    ,argument2     => l_access_set_id --data access set_id
                    ,argument3     => 'N'             --post to suspense
                    ,argument4     => NULL            --from date
                    ,argument5     => NULL            --to date
                    ,argument6     => 'N'             --summary mode
                    ,argument7     => 'N'             --import DFF
                    ,argument8     => 'Y'             --backward mode
                   );
 
   COMMIT;
 
   DBMS_OUTPUT.PUT_LINE('GL Import Submitted. Request Id : '||l_conc_id);
 
EXCEPTION
   WHEN OTHERS THEN
 
      DBMS_OUTPUT.PUT_LINE('Error while submitting the GL Import Program.');
      DBMS_OUTPUT.PUT_LINE('Error : '||SQLCODE||'-'||SUBSTR(SQLERRM,1,200));
END;
/