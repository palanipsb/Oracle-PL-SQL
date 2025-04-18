DECLARE
V_NAME VARCHAR2(6);
V_DEPARTMENT_NAME VARCHAR2(100);
DEPT_ID NUMBER;
BEGIN
        SELECT FIRST_NAME,DEPARTMENT_ID INTO V_NAME,DEPT_ID FROM EMPLOYEES_COPY WHERE EMPLOYEE_ID = 100;
        SELECT DEPARTMENT_NAME INTO V_DEPARTMENT_NAME FROM DEPARTMENTS WHERE DEPARTMENT_ID = DEPT_ID;
        DBMS_OUTPUT.PUT_LINE('HELLO ' ||V_NAME|| ' YOUR DEPARTMENT IS: '||V_DEPARTMENT_NAME);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('NO DATA'); 
                DBMS_OUTPUT.PUT_LINE(SQLCODE|| '---->'|| SQLERRM);
            WHEN TOO_MANY_ROWS THEN
                DBMS_OUTPUT.PUT_LINE('TOO MAN RECORDS');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('AN ERROR OCCURED');
                DBMS_OUTPUT.PUT_LINE(SQLCODE|| '---->'|| SQLERRM);
END;
/

SET SERVEROUTPUT ON

SELECT * FROM EMPLOYEES_COPY;

SELECT * FROM DEPARTMENTS;

DECLARE
TOO_HIGH_SALARY EXCEPTION;
V_SALARY_CHECK PLS_INTEGER;
BEGIN
    SELECT SALARY INTO V_SALARY_CHECK FROM EMPLOYEES WHERE EMPLOYEE_ID=100;
    IF V_SALARY_CHECK>20000 THEN
        RAISE TOO_HIGH_SALARY;
    END IF;
    DBMS_OUTPUT.PUT_LINE('THE SALARY IS IN AN ACCEPTEBALE RANGE');
    EXCEPTION
        WHEN TOO_HIGH_SALARY THEN
            DBMS_OUTPUT.PUT_LINE('THE SALARY IS TOO HIGH, YOU NEED TO DECREASE IT');
END;

DECLARE
V_SALARY_CHECK PLS_INTEGER;
ERROR_TOO_HIGH_SALARY EXCEPTION;
BEGIN
    SELECT SALARY INTO V_SALARY_CHECK FROM EMPLOYEES_COPY WHERE EMPLOYEE_ID=100;
    IF V_SALARY_CHECK > 20000 THEN
       RAISE ERROR_TOO_HIGH_SALARY;
    END IF;
    EXCEPTION
        WHEN ERROR_TOO_HIGH_SALARY THEN
            DBMS_OUTPUT.PUT_LINE('THE SALARY IS TOO HIGH. YOU NEED TO DECREASE IT.');
            RAISE_APPLICATION_ERROR(-20243, 'THE SALARY OF THE SELECTED EMPLOYEE US TOO HIGH!',TRUE);
END;
/