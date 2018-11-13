SELECT USER_NAME,paf2.PERSON_ID APPROVER_PERSONID,PAF2.FULL_NAME 
APPROVER_FULLNAME,RECIPIENT_ROLE USER_NAME,wn.begin_date, 
WN.STATUS,wn.subject,WN.MESSAGE_NAME 
from per_all_assignments_f paaf, 
per_all_people_f paf1, 
per_jobs pjb, 
per_positions ppo, 
per_all_people_f paf2, 
FND_USER FU, 
WF_NOTIFICATIONS WN 
where paaf.person_id=paf1.person_id 
and paaf.supervisor_id=paf2.person_id 
and paaf.job_id=pjb.job_id(+) 
and paaf.position_id=ppo.position_id(+) 
and paaf.date_probation_end is not null 
and (sysdate between paaf.effective_start_date and 
paaf.effective_end_date) 
and (sysdate between paf1.effective_start_date and 
paf1.effective_end_date) 
and (sysdate between paf2.effective_start_date and 
paf2.effective_end_date) 
AND FU.employee_id=paf2.PERSON_ID 
AND WN.RECIPIENT_ROLE=FU.USER_NAME