exec DBMS_SCHEDULER.STOP_JOB('LSDEMO.xxpbsaxpos_job1',force=>TRUE);

exec DBMS_SCHEDULER.STOP_JOB('xxpbsaxpos_job1');

BEGIN
  sys.DBMS_SCHEDULER.DROP_JOB(
     job_name         => 'xxpbsaxpos_job1',
     commit_semantics => 'ABSORB_ERRORS');
END;
/


BEGIN
  DBMS_SCHEDULER.DISABLE('xxpbsaxpos_job1');
END;
/