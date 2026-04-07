declare
    v_text varchar2(10) :=2+5*10;
begin
    dbms_output.put_line(v_text);
end;

declare
    v_number number := 20;
    v_number2 number(2) := 20.50;
    v_number3 number(4,2) := 20.50;
    v_DATE2 timestamp := systimestamp;
    v_date3 timestamp WITH time zone := systimestamp;
    v_DATE4 interval day(4) to second (3) := '124 02:05:21.012 ';
    v_DATE5 interval year to month := '12-3';
begin
    dbms_output.put_line('The value is: '|| v_number);
    dbms_output.put_line('The value is: '|| v_number2);
    dbms_output.put_line('The value is: '|| v_number3);
    dbms_output.put_line(v_DATE2);
    dbms_output.put_line(v_date3);
    dbms_output.put_line(v_date5);
    dbms_output.put_line(v_DATE4);
end;

declare
v_boolean boolean :=true;
begin
    dbms_output.put_line(sys.diutil.bool_to_int(v_boolean));
end;

declare
v_ename employees.first_name%TYPE;
v_first_name v_ename%TYPE;
v_last_name employees.last_name%TYPE;
begin
    v_first_name := 'Palanivel';
    v_last_name := null;
    dbms_output.put_line(v_first_name);
    dbms_output.put_line('HELLO: '||v_last_name);
end;

begin <<outer>>
declare
    v_outer varchar2(20) := 'Outer variable';
    v_text varchar2(20) := 'Outer Text';
    begin
        declare
            v_inner varchar2(20) := 'Inner variable';
            v_text varchar2(20) :='inner text';
            begin
                dbms_output.put_line('inside-->'||v_outer);
                dbms_output.put_line('inside-->'||v_text);
                dbms_output.put_line('inside-->'||v_inner);
            end;
        dbms_output.put_line('inside-->'||v_outer);
        dbms_output.put_line('inside-->'||v_text);
        --dbms_output.put_line('inside-->'||v_inner); 
    end;
end outer;
