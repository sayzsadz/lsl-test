
-- Create Employee
 -- -------------------------

DECLARE

             lc_employee_number                       PER_ALL_PEOPLE_F.EMPLOYEE_NUMBER%TYPE ;
             ln_person_id                             PER_ALL_PEOPLE_F.PERSON_ID%TYPE;
             ln_assignment_id                         PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID%TYPE;
             ln_object_ver_number                     PER_ALL_ASSIGNMENTS_F.OBJECT_VERSION_NUMBER%TYPE;
             ln_asg_ovn                               NUMBER;
             
             ld_per_effective_start_date              PER_ALL_PEOPLE_F.EFFECTIVE_START_DATE%TYPE;
             ld_per_effective_end_date                PER_ALL_PEOPLE_F.EFFECTIVE_END_DATE%TYPE;
             lc_full_name                             PER_ALL_PEOPLE_F.FULL_NAME%TYPE;
             ln_per_comment_id                        PER_ALL_PEOPLE_F.COMMENT_ID%TYPE;
             ln_assignment_sequence                   PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_SEQUENCE%TYPE;
             lc_assignment_number                     PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_NUMBER%TYPE;
             
             lb_name_combination_warning              BOOLEAN;
             lb_assign_payroll_warning                BOOLEAN;
             lb_orig_hire_warning                     BOOLEAN;

BEGIN 
           hr_employee_api.create_employee
           (   -- Input data elements 
               -- ------------------------------
               p_hire_date                                  => TO_DATE('08-JUN-2011'),
               p_business_group_id                          => fnd_profile.value_specific('PER_BUSINESS_GROUP_ID'),
               p_last_name                                  => 'TEST',
               p_first_name                                 => 'PRAJKUMAR',
               p_middle_names                               => NULL,
               p_sex                                        => 'M',
               p_national_identifier                        => '183-09-6723',
               p_date_of_birth                              => TO_DATE('03-DEC-1988'),
               p_known_as                                   => 'PRAJ', 
               -- Output data elements 
               -- --------------------------------
               p_employee_number                            => lc_employee_number,
               p_person_id                                  => ln_person_id,
               p_assignment_id                              => ln_assignment_id,
               p_per_object_version_number                  => ln_object_ver_number,
               p_asg_object_version_number                  => ln_asg_ovn,
               p_per_effective_start_date                   => ld_per_effective_start_date,
               p_per_effective_end_date                     => ld_per_effective_end_date,
               p_full_name                                  => lc_full_name,
               p_per_comment_id                             => ln_per_comment_id,
               p_assignment_sequence                        => ln_assignment_sequence,
               p_assignment_number                          => lc_assignment_number,
               p_name_combination_warning                   => lb_name_combination_warning,
               p_assign_payroll_warning                     => lb_assign_payroll_warning,
               p_orig_hire_warning                          => lb_orig_hire_warning 
        );
 
    COMMIT;

 

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
            dbms_output.put_line(SQLERRM);
END;
/

SHOW ERR;