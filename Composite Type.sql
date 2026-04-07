declare
v_emp_record employees%rowtype;
begin
    select * into v_emp_record from employees where employee_id = 101;
    insert into employees_copy(EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, JOB_ID, SALARY, COMMISSION_PCT, MANAGER_ID, DEPARTMENT_ID) 
    values(v_emp_record.EMPLOYEE_ID, v_emp_record.FIRST_NAME, v_emp_record.LAST_NAME, v_emp_record.EMAIL, v_emp_record.PHONE_NUMBER, v_emp_record.HIRE_DATE, 
    v_emp_record.JOB_ID, v_emp_record.SALARY, v_emp_record.COMMISSION_PCT, v_emp_record.MANAGER_ID, v_emp_record.DEPARTMENT_ID);
    dbms_output.put_line(v_emp_record.employee_id || '--' ||v_emp_record.first_name);
end;

select * from employees;

    select *  from departments;

declare
type t_emp_rd is record(emp_id employees.employee_id%type,
                        fname employees.first_name%type,
                        lname employees.last_name%type,
                        salary employees.salary%type);
v_emp t_emp_rd;
begin
    select employee_id,first_name,last_name,salary into v_emp
    from employees where employee_id = 101;
    dbms_output.put_line( v_emp.emp_id ||v_emp.fname||v_emp.lname||v_emp.salary);
end;

declare
type t_edu is record(school varchar2(50),
                        under_g varchar(50),
                        post_g varchar(50),
                        over_all_gpa number);
type v_emp_rd is record(emp_id employees.employee_id%type,
                        fname employees.first_name%type,
                        lname employees.last_name%type,
                        dept_id employees.department_id%type,
                        department departments%rowtype,
                        hire_date employees.hire_date%type,
                        salary employees.salary%type,
                        edu_details t_edu);
emp_details v_emp_rd;                        
begin
    select employee_id,first_name,last_name, hire_date, salary, department_id into emp_details.emp_id,
    emp_details.fname,emp_details.lname,emp_details.hire_date,emp_details.salary, emp_details.dept_id
    from employees where employee_id = 101;
    emp_details.edu_details.school := 'Govt.Higher.Seconday.School';
    emp_details.edu_details.under_g := 'SVM College';
    emp_details.edu_details.post_g := 'Anna Univerisity';
    emp_details.edu_details.over_all_gpa := 7.8;
    
    select * into emp_details.department from departments where department_id = emp_details.dept_id;
    
    dbms_output.put_line(emp_details.emp_id ||
    emp_details.fname||emp_details.lname||emp_details.hire_date||emp_details.salary|| emp_details.department.department_name||
    emp_details.edu_details.school||emp_details.edu_details.under_g||emp_details.edu_details.post_g||emp_details.edu_details.over_all_gpa);
end;



CREATE TABLE retired_employees 
AS SELECT * FROM employees WHERE 1=2;

declare
rt_emp employees%rowtype;
begin
    select * into rt_emp from employees where employee_id=100;
    rt_emp.salary := 0.0;
    insert into retired_employees values rt_emp;
    dbms_output.put_line(rt_emp.first_name||rt_emp.salary);
    rt_emp.salary := 100.0;
    update retired_employees set row = rt_emp where employee_id=100;
    dbms_output.put_line(rt_emp.first_name||rt_emp.salary);
end;


--------------Collections

declare
type e_list is varray(5) of varchar2(20);
emp_lst e_list;
begin
    emp_lst := e_list('Palani','Ashwin','Karthick','John','Nila');
    for i in 1..5 loop
        dbms_output.put_line(emp_lst(i));
    end loop;
end;

declare
type e_list is varray(5) of varchar2(20);
emp_lst e_list;
begin
    emp_lst := e_list('Palani','Ashwin','Karthick','John');
    for i in emp_lst.first()..emp_lst.last() loop
        dbms_output.put_line(emp_lst(i));
    end loop;
end;

declare
type t_elist is varray(20) of varchar2(10);
emp_list t_elist :=t_elist();
idx number :=1;
begin
    for i in 100..110 loop
        emp_list.extend;
        select first_name into emp_list(idx) from employees where employee_id = i;
        idx := idx+1;
    end loop;
    for i in emp_list.first..emp_list.last loop
        dbms_output.put_line(emp_list(i));
    end loop;
end;

declare
type e_list is table of varchar2(20);
emps e_list;
begin
    emps := e_list('Palani','Priya');
    emps.extend();
    emps(3):= 'Ashwin';
    for i in 1..emps.count() loop
        dbms_output.put_line(emps(i));
    end loop;
end;



declare
type e_list is table of employees.first_name%type;
emps e_list := e_list();
idx pls_integer :=1;
begin
    for i in 100..110 loop
        emps.extend();
        select first_name into emps(idx) from employees where employee_id = i;
        idx := idx+1;
    end loop;
    emps.delete(3);
    for i in 1..emps.count() loop
        if emps.exists(i) then
            dbms_output.put_line(emps(i));
        end if;
    end loop;
end;
        

declare
type e_list is table of employees.first_name%type index by pls_integer;
emps e_list;
begin
    for x in 100..110 loop
        select first_name into emps(x) from employees where employee_id = x;
    end loop;
    for i in emps.first..emps.last loop
        dbms_output.put_line(emps(i));
    end loop;
end;



declare
type e_list is table of employees.first_name%type index by pls_integer;
emps e_list;
idx number;
begin
    for i in 100..110 loop
        select first_name into emps(i) from employees where employee_id = i;
    end loop;
    idx := emps.first();
    while idx is not null loop
        dbms_output.put_line(emps(idx));
        idx :=emps.next(idx);
    end loop;
end;

declare
type e_list is table of employees%rowtype index by pls_integer;
idx pls_integer;
emps e_list;
begin
    for i in 100..110 loop
        select * into emps(i) from employees where employee_id = i;
    end loop;
    idx := emps.first;
    while idx is not null loop
        dbms_output.put_line(emps(idx).employee_id||emps(idx).first_name);
        idx := emps.next(idx);
    end loop;
end;

declare
type t_emp_record is record(fname employees.first_name%type,
                            lname employees.last_name%type,
                            email employees.email%type,
                            hire_date employees.hire_date%type);
type e_list is table of t_emp_record index by pls_integer;
emps e_list;
idx pls_integer;
begin
    for i in 100..110 loop
        select first_name,last_name,email,hire_date into emps(i) from employees where employee_id = i;
    end loop;
    idx := emps.first;
    while idx is not null loop
        dbms_output.put_line(emps(idx).fname || ' ' || emps(idx).lname ||' '||emps(idx).email||' '||emps(idx).hire_date);
        idx := emps.next(idx);
    end loop;    
end;

create table employees_salary_history as select * from employees where 1=2;
alter table employees_salary_history add insert_date date;
