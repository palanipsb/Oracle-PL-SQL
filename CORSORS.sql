--CURSORS
DECLARE
CURSOR C_EMPS IS SELECT * FROM EMPLOYEES_COPY FOR UPDATE;
EMP_LIST EMPLOYEES_COPY%ROWTYPE;
BEGIN
    IF NOT C_EMPS%ISOPEN THEN
        OPEN C_EMPS;
    END IF;
    LOOP
        FETCH C_EMPS INTO EMP_LIST;
        EXIT WHEN C_EMPS%NOTFOUND;
        UPDATE EMPLOYEES_COPY SET SALARY = EMP_LIST.SALARY*0.1 + EMP_LIST.SALARY WHERE CURRENT OF C_EMPS;
    END LOOP;
    CLOSE C_EMPS;
    COMMIT;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('NO RECORDS FOUND');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('AN ERROR OCCURED');
END;
/

SELECT * FROM EMPLOYEES_COPY;

DECLARE
CURSOR C_EMPS(DEPT_ID EMPLOYEES.DEPARTMENT_ID%TYPE) IS SELECT * FROM EMPLOYEES_COPY WHERE DEPARTMENT_ID = DEPT_ID;
V_EMP_LIST EMPLOYEES_COPY%ROWTYPE;
BEGIN
    IF NOT C_EMPS%ISOPEN THEN
        OPEN C_EMPS(:DEPT_ID);
    END IF;
    LOOP
        FETCH C_EMPS INTO V_EMP_LIST;
        EXIT WHEN C_EMPS%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('FIRS_NAME: '||V_EMP_LIST.FIRST_NAME);
    END LOOP;
    CLOSE C_EMPS;
END;
/

DECLARE
CURSOR C_EMPS(DEPT_ID EMPLOYEES.DEPARTMENT_ID%TYPE) IS SELECT * FROM EMPLOYEES_COPY WHERE DEPARTMENT_ID = DEPT_ID FOR UPDATE OF EMPLOYEES_COPY.SALARY NOWAIT;
V_EMP_LIST EMPLOYEES_COPY%ROWTYPE;
BEGIN
    IF NOT C_EMPS%ISOPEN THEN
        OPEN C_EMPS(:DEPT_ID);
    END IF;
    LOOP
        FETCH C_EMPS INTO V_EMP_LIST;
        EXIT WHEN C_EMPS%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('FIRS_NAME: '||V_EMP_LIST.FIRST_NAME);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('ROW COUNT: '||C_EMPS%ROWCOUNT);
    CLOSE C_EMPS;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
END;
/

DECLARE
TYPE C_EMPS IS REF CURSOR;
EMP_LIST C_EMPS;
V_EMP_LIST EMPLOYEES_COPY%ROWTYPE;
V_DEPT_LIST DEPARTMENTS%ROWTYPE;
Q VARCHAR2(1000);
BEGIN
    Q := 'SELECT * FROM EMPLOYEES_COPY WHERE DEPARTMENT_ID =:B';
    OPEN EMP_LIST FOR Q USING '50';
    LOOP
        FETCH EMP_LIST INTO V_EMP_LIST;
        EXIT WHEN EMP_LIST%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('NAME: '||V_EMP_LIST.FIRST_NAME);
    END LOOP;
    CLOSE EMP_LIST;
    
    Q := 'SELECT * FROM DEPARTMENTS WHERE DEPARTMENT_ID =:B';
    OPEN EMP_LIST FOR Q USING '60';
    LOOP
        FETCH EMP_LIST INTO V_DEPT_LIST;
        EXIT WHEN EMP_LIST%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('NAME: '||V_DEPT_LIST.DEPARTMENT_NAME);
    END LOOP;
    CLOSE EMP_LIST;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('AN ERROR OCCURED');
END;
/