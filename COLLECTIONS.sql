CREATE OR REPLACE TYPE T_PHONE_NUMBER AS OBJECT (P_TYPE VARCHAR2(10), P_NUMBER VARCHAR2(50));
/

CREATE OR REPLACE TYPE V_PHONE_NUMBER AS VARRAY(3) OF T_PHONE_NUMBER;
/

CREATE OR REPLACE TYPE N_PHONE_NUMBER AS TABLE OF T_PHONE_NUMBER;
/

CREATE TABLE EMPS_WITH_PHONES(
    EMPLOYEE_ID NUMBER, 
    FIRST_NAME VARCHAR2(50),
    LAST_NAME VARCHAR2(50),
    PHONE_NUMBER V_PHONE_NUMBER);
/

CREATE TABLE EMPS_WITH_PHONES2(
    EMPLOYEE_ID NUMBER, 
    FIRST_NAME VARCHAR2(50),
    LAST_NAME VARCHAR2(50),
    PHONE_NUMBER N_PHONE_NUMBER)
    NESTED TABLE PHONE_NUMBER STORE AS PHONE_NUMBERS_TABLE;
/

SELECT * FROM EMPS_WITH_PHONES2;

INSERT INTO EMPS_WITH_PHONES2 VALUES (1000, 'PALANIVEL', 'SUBRAMANI', N_PHONE_NUMBER(T_PHONE_NUMBER('HOME','464-455-465-4'),
                                                                                    T_PHONE_NUMBER('MOBILE','7896-455-465-4'),
                                                                                    T_PHONE_NUMBER('WORK','387-455-465-4')));
/                                                                                    

INSERT INTO EMPS_WITH_PHONES2 VALUES (1001, 'ASHWIN', 'PALANIVEL', N_PHONE_NUMBER(T_PHONE_NUMBER('HOME','3544-455-465-4'),
                                                                                    T_PHONE_NUMBER('MOBILE','684-455-465-4'),
                                                                                    T_PHONE_NUMBER('WORK','6792-455-465-4')));
/

INSERT INTO EMPS_WITH_PHONES2 VALUES (1002, 'THARA', 'PALANIVEL', N_PHONE_NUMBER(T_PHONE_NUMBER('HOME','752-455-465-4'),
                                                                                    T_PHONE_NUMBER('MOBILE','384-455-465-4'),
                                                                                    T_PHONE_NUMBER('WORK','7156-455-465-4')));
/

INSERT INTO EMPS_WITH_PHONES2 VALUES (1003, 'AARADHYA', 'PALANIVEL', N_PHONE_NUMBER(T_PHONE_NUMBER('HOME','636-455-465-4'),
                                                                                    T_PHONE_NUMBER('MOBILE','7742-455-465-4'),
                                                                                    T_PHONE_NUMBER('WORK','284-455-465-4')));
/

UPDATE EMPS_WITH_PHONES2 SET PHONE_NUMBER = N_PHONE_NUMBER (T_PHONE_NUMBER('HOME','7875-455-465-4'),
                                                            T_PHONE_NUMBER('MOBILE','356-455-465-4'),
                                                            T_PHONE_NUMBER('WORK','1235-455-465-4')) WHERE EMPLOYEE_ID = 1003;

SELECT E.EMPLOYEE_ID, E.FIRST_NAME, E.LAST_NAME, P.P_TYPE, P.P_NUMBER FROM EMPS_WITH_PHONES E, TABLE(E.PHONE_NUMBER) P;

SELECT E.EMPLOYEE_ID, E.FIRST_NAME, E.LAST_NAME, P.P_TYPE, P.P_NUMBER FROM EMPS_WITH_PHONES2 E, TABLE(E.PHONE_NUMBER) P;

DECLARE
P_NUM N_PHONE_NUMBER;
BEGIN
    SELECT PHONE_NUMBER INTO P_NUM FROM EMPS_WITH_PHONES2 WHERE EMPLOYEE_ID = 1003;
    P_NUM.EXTEND;
    P_NUM(4) := T_PHONE_NUMBER('FAX','724-455-465-4');
    UPDATE EMPS_WITH_PHONES2 SET PHONE_NUMBER = P_NUM WHERE EMPLOYEE_ID = 1003;
END;
/
    