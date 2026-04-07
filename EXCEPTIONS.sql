declare
v_name varchar2(10);
begin
    select first_name into v_name from employees where employee_id =0;
    dbms_output.put_line(v_name);
end;

declare
v_name varchar2(10);
begin
    select first_name into v_name from employees where employee_id =0;
    dbms_output.put_line(v_name);
    exception
        when no_data_found then
            dbms_output.put_line('No employee found');
end;

declare
v_name varchar2(20);
v_department_name varchar2(50);
begin
    select first_name into v_name from employees where employee_id = 10003;
    select department_id into v_department_name from employees where first_name = v_name;
    dbms_output.put_line(v_name||' is department of :'|| v_department_name);
    exception
        when no_data_found then
            dbms_output.put_line('No employee/department found');
        when too_many_rows then
            dbms_output.put_line('Too many employees/departments found');
        when others then
            dbms_output.put_line('try with different employee');
            dbms_output.put_line(sqlcode ||'-->'||sqlerrm);
end;

declare
cannot_update_null exception;
pragma exception_init(cannot_update_null,-01407);
begin
    update employees_copy set email = null where employee_id=100;
    exception
        when cannot_update_null then
            dbms_output.put_line('Can not update to null');
end;

declare
too_high_salary exception;
v_salary_check number;
begin
    select salary into v_salary_check from employees where employee_id =101;
    if v_salary_check>20000 then
        raise too_high_salary;
    end if;
    dbms_output.put_line('You salary with in the range. updated');
   exception
    when too_high_salary then
                dbms_output.put_line('Your salary is too high can not be increased');
end;

declare
error_msg varchar2(50) :='Salary is too high to be updated';
v_salary_check number;
begin
    select salary into v_salary_check from employees where employee_id = 100;
    if v_salary_check>20000 then
        raise_application_error(-20123,error_msg);
    end if;
    dbms_output.put_line('Salary is updated');
end;

