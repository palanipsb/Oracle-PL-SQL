# fucntion return type:

with
    function fp_square_cube(
    pin_num IN NUMBER,
    pout_num OUT NUMBER
    )RETURN NUMBER
        AS
     BEGIN
        pout_num := pin_num * pin_num * pin_num;
        return pin_num * pin_num;
     END;
     
     function fn_square_cube_caller (
        pin_num IN NUMBER
     ) RETURN NUMBER
            AS
        lv_sq number;
        lv_cb number;
        BEGIN
            lv_sq := fp_square_cube(pin_num, lv_cb);
            return lv_sq;
        END;
        
select fn_square_cube_caller(2) from dual;

create or replace function fn_square_cube(
    pin_num NUMBER
)RETURN SYS_REFCURSOR AS
    lv_ret_cursor SYS_REFCURSOR;
BEGIN
    OPEN lv_ret_CURSOR FOR
    select 'SQUARE' as name, pin_num * pin_num as num from dual
    union
    select 'CUBE', pin_num * pin_num * pin_num from dual;
    
    return lv_ret_cursor;
END;
/

select fn_square_cube(3) from dual;

variable x refcursor;

exec :x := fn_square_cube(3);

print :x;

select * from course;

select * from student where rownum<=5;

create index idx1_btree_cource_id on course(id);

create bitmap index idx1_bitmap_id on course(is_deleted);

create index idx2_fn_name on course(upper(name));

create index idx1_reverse_student_id on student(id) reverse;

create index idx1_comp_student_id on student(name,passport_id);

select * from user_indexes where table_name in ('COURSE','STUDENT');

select * from user_ind_columns where table_name in ('COURSE','STUDENT');

select * from user_ind_statistics where table_name in ('COURSE','STUDENT');

select * from user_ind_expressions where table_name in ('COURSE','STUDENT');

alter index idx1_reverse_student_id nomonitoring usage;

select * from dba_object_usage;

# Collections

set serveroutput on

declare
v_stdrec student%rowtype;
begin
    select * into v_stdrec from student where id=10005;
    dbms_output.put_line('id = '||v_stdrec.id);
    dbms_output.put_line('Name = '||v_stdrec.name);
    dbms_output.put_line('passport_id = '||v_stdrec.passport_id);
end;

declare
v_stdrec student.name%type;
begin
    select name into v_stdrec from student where id=10005;
    --dbms_output.put_line('id = '||v_stdrec.id);
    dbms_output.put_line('Name = '||v_stdrec);
    --dbms_output.put_line('passport_id = '||v_stdrec.passport_id);
end;

declare
type std_rec_type is record (stdname varchar2(100), passport_id number);
std_rec std_rec_type;
begin
std_rec.stdname :='Palani';
std_rec.passport_id := 1000;
dbms_output.put_line('Name = '||std_rec.stdname);
dbms_output.put_line('Name = '||std_rec.passport_id);
end;

declare
type std_rec_type is record (stdname varchar2(100), passport_id number);
std_rec std_rec_type := std_rec_type('Priya',1001);
begin
dbms_output.put_line('Name = '||std_rec.stdname);
dbms_output.put_line('Name = '||std_rec.passport_id);

std_rec.stdname :='Ashwin';
std_rec.passport_id := 1003;

dbms_output.put_line('Name = '||std_rec.stdname);
dbms_output.put_line('Name = '||std_rec.passport_id);
end;

declare
type std_rec_type is record (stdname varchar2(100) not null :='Subramani', passport_id number);
std_rec std_rec_type;
begin
std_rec.passport_id := 1004;
dbms_output.put_line('Name = '||std_rec.stdname);
dbms_output.put_line('Name = '||std_rec.passport_id);
end;

declare
type std_rec_type is record(stdname student.name%type, passport_id student.passport_id%type);
std_rec std_rec_type;
begin
   std_rec.stdname :='Ashwin';
std_rec.passport_id := 1003;

dbms_output.put_line('Name = '||std_rec.stdname);
dbms_output.put_line('Name = '||std_rec.passport_id); 
end;

declare
type namelist_varray is varray(2) of varchar2(30);
n_list namelist_varray :=namelist_varray(null, null);
begin
    n_list(1) := 'Palani';
    n_list(2) := 'Priya';
    dbms_output.put_line('First name = '||n_list(1));
    dbms_output.put_line('Second name = '||n_list(2));
end;

declare
type namelist_varray is varray(2) of varchar2(30);
n_list namelist_varray;
begin
    n_list(1) := 'Palani';
    n_list(2) := 'Priya';
    dbms_output.put_line('First name = '||n_list(1));
    dbms_output.put_line('Second name = '||n_list(2));
end;

declare
type namelist_varray is varray(2) of varchar2(30);
n_list namelist_varray :=namelist_varray();
begin
    n_list(1) := 'Palani';
    n_list(2) := 'Priya';
    dbms_output.put_line('First name = '||n_list(1));
    dbms_output.put_line('Second name = '||n_list(2));
end;

declare
type namelist_varray is varray(2) of varchar2(30);
n_list namelist_varray :=namelist_varray();
begin
    n_list.extend(2);
    n_list(1) := 'Palani';
    n_list(2) := 'Priya';
    dbms_output.put_line('First name = '||n_list(1));
    dbms_output.put_line('Second name = '||n_list(2));
end;

declare
type namelist_varray is varray(2) of varchar2(30);
n_list namelist_varray :=namelist_varray();
begin
    n_list.extend(3);
    n_list(1) := 'Palani';
    n_list(2) := 'Priya';
    dbms_output.put_line('First name = '||n_list(1));
    dbms_output.put_line('Second name = '||n_list(2));
end;

declare
type namelist_varray is varray(4) of varchar2(30);
n_list namelist_varray :=namelist_varray();
begin
    n_list.extend(3);
    n_list(1) := 'Palani';
    n_list(2) := 'Priya';
    dbms_output.put_line('Limit = '||n_list.LIMIT);
    dbms_output.put_line('Count = '||n_list.COUNT);
    dbms_output.put_line('FIRST = '||n_list.FIRST);
    dbms_output.put_line('LAST = '||n_list.LAST);
    dbms_output.put_line('PRIOR = '||n_list.PRIOR(3));
    dbms_output.put_line('NEXT = '||n_list.NEXT(3));
end;

declare
type std_varray_type is varray(7) of varchar2(20);

set serveroutput on
declare
type matrix_elem_type is varray(3) of number;
type matrix_type is varray(3) of matrix_elem_type;
lv_matrix_elem matrix_elem_type := matrix_elem_type(null,null,null);
lv_matrix1 matrix_type := matrix_type(null,null,null);
lv_matrix2 matrix_type := matrix_type(null,null,null);
lv_matrix_total matrix_type := matrix_type(null,null,null);
procedure print_array(pin_array matrix_type, pin_desc varchar2) as
begin
dbms_output.put_line('Printing the '||pin_desc||'...');
for i in pin_array.first..pin_array.last loop
    for j in pin_array.first..pin_array.last loop
        dbms_output.put(pin_array(i)(j)||'    ');
    end loop;
        dbms_output.put_line ('');
end loop;
end;
begin
    lv_matrix_elem := matrix_elem_type(1,2,3);
    lv_matrix1(1) := lv_matrix_elem;
    lv_matrix_elem := matrix_elem_type(4,5,6);
    lv_matrix1(2) := lv_matrix_elem;
    lv_matrix_elem := matrix_elem_type(7,8,9);
    lv_matrix1(3) := lv_matrix_elem;
    
    print_array(lv_matrix1, 'First Array');
    
    lv_matrix_elem := matrix_elem_type(11,12,13);
    lv_matrix2(1) := lv_matrix_elem;
    lv_matrix_elem := matrix_elem_type(14,15,16);
    lv_matrix2(2) := lv_matrix_elem;
    lv_matrix_elem := matrix_elem_type(17,18,19);
    lv_matrix2(3) := lv_matrix_elem;
    
    print_array(lv_matrix2, 'Second Array');
    
    for i in lv_matrix1.first..lv_matrix1.last loop
        for j in lv_matrix1(i).first..lv_matrix1(i).last loop
            lv_matrix_elem(j) := lv_matrix1(i)(j)+ lv_matrix2(i)(j);
        end loop;
        lv_matrix_total(i) := lv_matrix_elem;
    end loop;
    print_array(lv_matrix_total, 'Totals of Array');
end;

declare
type v_nested_tab_type is table of varchar2(30);
v_day v_nested_tab_type :=v_nested_tab_type(null, null,null);
begin
v_day(1) := 'Monday';
v_day(2) := 'Tuesday';
v_day(3) := 'Wed';

dbms_output.put_line('v_day.First: ' ||v_day(1));
dbms_output.put_line('v_day.Second: ' ||v_day(2));

end;

create or replace function fn_division(a int, b int) return number
as
lv_temp number;
begin
    lv_temp := a/b;
    return lv_temp;
end;

select * from user_errors;

set serveroutput on
begin
dbms_output.put_line(fn_division(2,0));
exception when others then 
    dbms_output.put_line('An error occured');
end;

declare
v_stds student%rowtype;
begin
select * into v_stds from student where id = 1001;
EXCEPTION when
    NO_DATA_FOUND then
        dbms_output.put_line('No Data');
end;

select * from employees where salary = (select max(salary) from employees)

select * from employees where department_id in (
select department_id from departments where location_id in (select location_id from locations where country_id='US'))

select * from departments

select * from locations where country_id='US'

select * from employees e1 where 1 = (select count(*) from employees e2 where e2.salary>=e1.salary);

select * from employees e1
where e1.employee_id in (select manager_id from employees where manager_id is not null)

select * from employees e1
where 1<=(select count(*) from employees e2 where e1.employee_id = e2.manager_id)

select * from employees e1
where not exists  (select count(*) from employees e2 where e1.employee_id = e2.manager_id)

spool "C://Users//palan//Desktop//Matiz//EDU//ORACLE PL-SQL//PLSQL-Practice//SQL Loader//file.csv";
select /*csv*/ *
from employees;
spool off;

create or replace directory ext_data_dir as 'C:\Users\palan\Desktop\Matiz\EDU\ORACLE PL-SQL\PLSQL-Practice\SQL Loader';

select * from external(
EMPLOYEE_ID	NUMBER(6,0),
FIRST_NAME	VARCHAR2(20 BYTE),
LAST_NAME	VARCHAR2(25 BYTE),
EMAIL	VARCHAR2(25 BYTE),
PHONE_NUMBER	VARCHAR2(20 BYTE),
HIRE_DATE	DATE,
JOB_ID	VARCHAR2(10 BYTE),
SALARY	NUMBER(8,2),
COMMISSION_PCT	NUMBER(2,2),
MANAGER_ID	NUMBER(6,0),
DEPARTMENT_ID	NUMBER(4,0),
) type oracle_loader
deafult directory ext_data_dir
access paramaters(
records delimited by newline
fields terminated by ','
)
location('file.csv') reject limit unlimited employee;


select employee_id,first_name,last_name,salary,rank() over(order by salary desc) rnk ,
dense_rank() over(order by salary desc) densk_rnk 
from employees;