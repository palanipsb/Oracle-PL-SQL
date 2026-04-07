declare
v_job_code varchar2(10) := 'IT-PROG';
v_salary_inc number;
begin
    v_salary_inc := case v_job_code when 'SAP' then 0.2
                                    when 'IT-PROG' then 0.3
                    else 0 end;
    dbms_output.put_line('Your salary increase: '||v_salary_inc);
end;

declare
v_job_code varchar2(10) := 'HR';
v_department varchar2(10) := 'IT';
v_salary_inc number;
begin
    case when v_job_code = 'SAP' then 
        v_salary_inc := 0.2;
        dbms_output.put_line('The salary inscrease for '||v_job_code|| ' is '||v_salary_inc);
        when v_department = 'IT' and v_job_code = 'IT-PROG' then
        v_salary_inc :=0.3;
        dbms_output.put_line('The salary inscrease for '||v_job_code|| ' is '||v_salary_inc);
        else
        v_salary_inc :=0.5;
         dbms_output.put_line('The salary inscrease for '||v_job_code|| ' is '||v_salary_inc);
    end case;         
end;