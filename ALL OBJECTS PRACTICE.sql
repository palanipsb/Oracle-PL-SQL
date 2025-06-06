SET SERVEROUTPUT ON
DECLARE
EMP_NAMES EMPLOYEES%ROWTYPE;
CURSOR C1 IS SELECT * FROM EMPLOYEES;
BEGIN
    IF NOT C1%ISOPEN THEN
        OPEN C1;
    END IF;
    LOOP
        FETCH C1 INTO EMP_NAMES;
        EXIT WHEN C1%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(EMP_NAMES.FIRST_NAME);
    END LOOP;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA AVAILABLE');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('AN ERROR OCCURED');
END;
/

SET SERVEROUTPUT ON
DECLARE
TYPE EMP_LIST_TYPE IS TABLE OF EMPLOYEES%ROWTYPE;
EMP_LIST EMP_LIST_TYPE;
EMP_NAMES EMPLOYEES%ROWTYPE;
FAILED_RECORDS NUMBER :=0;
BEGIN
    SELECT * BULK COLLECT INTO EMP_LIST FROM EMPLOYEES;
    FORALL i IN 1..EMP_LIST.COUNT SAVE EXCEPTIONS
        MERGE INTO EMP_COPY E
        USING (SELECT EMP_LIST(i).EMPLOYEE_ID AS EMPLOYEE_ID FROM DUAL) SRC ON (E.EMPLOYEE_ID = SRC.EMPLOYEE_ID)
        WHEN MATCHED THEN
        UPDATE SET SALARY = SYSDATE WHERE E.DEPARTMENT_ID=90
        WHEN NOT MATCHED THEN
        INSERT (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) VALUES 
        (EMP_LIST(i).EMPLOYEE_ID,EMP_LIST(i).FIRST_NAME,EMP_LIST(i).LAST_NAME,EMP_LIST(i).EMAIL,EMP_LIST(i).PHONE_NUMBER,EMP_LIST(i).HIRE_DATE,EMP_LIST(i).JOB_ID,EMP_LIST(i).SALARY
        ,EMP_LIST(i).COMMISSION_PCT,EMP_LIST(i).MANAGER_ID,EMP_LIST(i).DEPARTMENT_ID);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            FAILED_RECORDS :=SQL%BULK_EXCEPTIONS.COUNT;
            FOR j IN 1..FAILED_RECORDS LOOP
                DBMS_OUTPUT.PUT_LINE('FAILED RECORD: EMPLOYEE ID = '|| EMP_LIST(SQL%BULK_EXCEPTIONS(j).ERROR_INDEX).EMPLOYEE_ID);
                DBMS_OUTPUT.PUT_LINE('ERROR CODE: '|| SQL%BULK_EXCEPTIONS(j).ERROR_CODE || ', ERROR MESSAGE: '|| SQLERRM(-SQL%BULK_EXCEPTIONS(j).ERROR_CODE));
                ROLLBACK;
            END LOOP;
END;
/