
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
   job_name                 =>  'xxpbsapos_job1', 
   job_type                 =>  'PLSQL_BLOCK',
   job_action               =>  'BEGIN IMPORT_SALES_SUMMARY; END;',
   schedule_name            =>  'xxpbsapos_daily_schedule',
   enabled                  =>  TRUE
   );
END;
/

BEGIN
 DBMS_SCHEDULER.CREATE_SCHEDULE (
  schedule_name     => 'xxpbsapos_daily_schedule',
  start_date        => SYSTIMESTAMP,
  end_date          => SYSTIMESTAMP + INTERVAL '30' day,
  repeat_interval   => 'FREQ=SECONDLY; INTERVAL=30',
  comments          => 'Every 30 seconds');
END;
/


exec DBMS_SCHEDULER.STOP_JOB('xxpbsaxpos_job1',force=>TRUE);


BEGIN
  DBMS_SCHEDULER.SET_ATTRIBUTE (
   name         =>  'xxpbsaxpos_job1',
   attribute    =>  'repeat_interval',
   value        =>  'freq=weekly; byday=wed');
END;
/

BEGIN
dbms_scheduler.drop_job(
     job_name => 'xxpbsaxpos_job');
END;

exec DBMS_SCHEDULER.DROP_JOB (schedule_name    => 'xxpbsapos_job1',force            => TRUE);

begin
DBMS_SCHEDULER.DROP_JOB (
   job_name                => 'xxpbsapos_job1');
end;

exec DBMS_SCHEDULER.DROP_SCHEDULE (schedule_name    =>'xxpbsapos_daily_schedule', force            =>TRUE);

select *
from v$session_longops
where opname like '%xx%';

select JOB_NAME, STATE
from user_scheduler_jobs;