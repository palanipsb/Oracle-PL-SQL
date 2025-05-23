QUESTIONS AND ANSER PRACTICE
1. WRITE A QUERY TO SELECT THE ROWS THAT HAVE "A" IN ANY ONE OF THE COLUMNS(COL1, COL2, COL3, COL4, COL5) WITHOUT USING "OR" KEYWORD.

CREATE TABLE IQA_TAB_EMP(S_NO NUMBER, COL1 CHAR, COL2 CHAR, COL3 CHAR, COL4 CHAR, COL5 CHAR);

INSERT INTO IQA_TAB_EMP(S_NO, COL1, COL2, COL3, COL4, COL5) 
SELECT 1,'A', 'B', 'C', 'D', 'E' FROM DUAL UNION ALL
SELECT 1,NULL, 'A', 'B', 'C', 'D' FROM DUAL UNION ALL
SELECT 1,'E', NULL, NULL, NULL, 'A' FROM DUAL UNION ALL
SELECT 1,NULL, 'A', 'E', NULL, 'D' FROM DUAL UNION ALL
SELECT 1,'E', 'D', 'C', 'B', NULL FROM DUAL;

SELECT * FROM EMP WHERE COL='A' AND COL IS NOT NULL
UNION ALL
SELECT * FROM EMP WHERE COL2='A'
UNION ALL
SELECT * FROM EMP WHERE COL3='A'
UNION ALL
SELECT * FROM EMP WHERE COL4='A'
UNION ALL
SELECT * FROM EMP WHERE COL5='A'

SELECT * FROM EMP WHERE 'A' IN (COL, COL1,COL2,COL3,CLO4)

SELECT * FROM TAB1
WHERE COL||COL1||COL2||COL3||CLO4 LIKE '%A%';

SELECT * FROM TAB1 WHERE INSTR(COL||COL1||COL2||COL3||CLO4, '%A%')>0;

2. WRITE SQL TO RETURN GREATER THAN AVG SALARY BY DEPARTMENT.

SELECT * FROM EMPLOYEES E,
(SELECT DEPARTMENT_ID,TRUNC(AVG(SALARY))AVG_SALARY FROM EMPLOYEES GROUP BY DEPARTMENT_ID)AVG_SAL
WHERE E.SALARY>AVG_SAL.AVG_SALARY AND E.DEPARTMENT_ID = AVG_SAL.DEPARTMENT_ID;

SELECT * FROM EMPLOYEES E
WHERE E.SALARY>(SELECT TRUNC(AVG(SALARY)) FROM EMPLOYEES E1 WHERE E1.DEPARTMENT_ID = E.DEPARTMENT_ID);

SELECT * FROM(
SELECT EMPLOYEE_ID,
FIRST_NAME,
LAST_NAME,
EMAIL,
PHONE_NUMBER,
HIRE_DATE,
JOB_ID,
SALARY,
COMMISSION_PCT,
MANAGER_ID,
DEPARTMENT_ID, TRUNC(AVG(SALARY) OVER (PARTITION BY DEPARTMENT_ID)) AVG_SAL
FROM EMPLOYEES) WHERE SALARY>AVG_SAL;

WITH
FUNCTION FN_AVG_SALARY(P_DEPARTMENT_ID NUMBER) RETURN NUMBER AS
V_AVG_SAL NUMBER;
BEGIN
    SELECT TRUNC(AVG(SALARY)) INTO V_AVG_SAL FROM EMPLOYEES WHERE DEPARTMENT_ID = P_DEPARTMENT_ID;
    RETURN V_AVG_SAL;
END FN_AVG_SALARY;
SELECT * FROM EMPLOYEES WHERE SALARY>FN_AVG_SALARY(DEPARTMENT_ID);

3. TAB1, TAB2 WRITE QUERY TO GET TAB1 RECORDS THAT ARE NOT EXITS IN TAB2 WOTHOUT "NOT"

SELECT EMPLOYEE_ID FROM EMPLOYEES 
MINUS 
SELECT EMPLOYEE_ID FROM EMPLOYEES_COPY

SELECT * FROM EMPLOYEES WHERE EMPLOYEE_ID NOT IN (SELECT EMPLOYEE_ID FROM EMPLOYEES_COPY);

SELECT * FROM EMPLOYEES E1 WHERE NOT EXISTS (SELECT 1 FROM EMPLOYEES_COPY E2 WHERE E1.EMPLOYEE_ID = E2.EMPLOYEE_ID);

SELECT * FROM EMPLOYEES E1 WHERE 1>(SELECT COUNT(*) FROM EMPLOYEES_COPY E2 WHERE E1.EMPLOYEE_ID=E2.EMPLOYEE_ID)

SELECT * FROM EMPLOYEES E1 
LEFT OUTER JOIN EMPLOYEES_COPY E2 
ON E1.EMPLOYEE_ID = E2.EMPLOYEE_ID;

SELECT * FROM EMPLOYEES E1 WHERE (SELECT COUNT(1) FROM EMPLOYEES_COPY E2 WHERE E1.EMPLOYEE_ID = E2.EMPLOYEE_ID)=0;

4. WRTIE QUERY TO FIND OUT NUMBER OF MATHCES "PLAYED" BY EACH TEAM, "WON", "LOST"

SELECT TEAM_NAME,NO_OF_MATCHES, NVL(WON_COUNT,0)WON, NO_OF_MATCHES-NVL(WON_COUNT,0) AS LOST_MATCH FROM
(SELECT TEAM_NAME,COUNT(*) NO_OF_MATCHES FROM (
SELECT TEAM_A AS TEAM_NAME FROM CRICKET
UNION ALL
SELECT TEAM_B FROM CRICKET) GROUP BY TEAM_NAME) T_LIST
LEFT JOIN (SELECT WINNER, COUNT(*) WON_COUNT FROM CRICKET GROUP BY WINNER) W
ON T_LIST.TEAM_NAME=W.WINNER;

WITH MATCHES_PLAYED AS
(SELECT TEAM_NAME,COUNT(*) NO_OF_MATCHES FROM (
SELECT TEAM_A AS TEAM_NAME FROM CRICKET
UNION ALL
SELECT TEAM_B FROM CRICKET) GROUP BY TEAM_NAME),
MATCHES_WON AS
(SELECT WINNER, COUNT(*) WON_COUNT FROM CRICKET GROUP BY WINNER)
SELECT TEAM_NAME,NO_OF_MATCHES, NVL(WON_COUNT,0) WON_COUNT, NO_OF_MATCHES-NVL(WON_COUNT,0) MATCH_LOST 
FROM MATCHES_PLAYED FULL OUTER JOIN MATCHES_WON ON MATCHES_PLAYED.TEAM_NAME = MATCHES_WON.WINNER;

5. WRITE A QUERY TO PRINT NUMBER FROM 1.. TO "N" NUMBERS

DECLARE
V_NUMBER NUMBER := :NUM;
BEGIN
    FOR i IN 1..V_NUMBER LOOP
        DBMS_OUTPUT.PUT_LINE(i);
    END LOOP;
END;
/

SELECT ROWNUM FROM DUAL CONNECT BY LEVEL<=:NUM;

CREATE OR REPLACE FUNCTION FN_GET_TABLE_OF_NUMBERS(P_COUNT NUMBER) RETURN SYS.ODCINUMBERLIST
IS
L_NUM_TAB SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();
BEGIN
    FOR i IN 1..P_COUNT LOOP
        L_NUM_TAB.EXTEND;
        L_NUM_TAB(L_NUM_TAB.LAST) :=i;
    END LOOP;
    RETURN L_NUM_TAB;
END FN_GET_TABLE_OF_NUMBERS;
/

SELECT * FROM (FN_GET_TABLE_OF_NUMBERS(10));

WITH FUNCTION FN_GET_TABLE_OF_NUMBERS(P_COUNT NUMBER) RETURN SYS.ODCINUMBERLIST
IS
L_NUM_TAB SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();
BEGIN
    FOR i IN 1..P_COUNT LOOP
        L_NUM_TAB.EXTEND;
        L_NUM_TAB(L_NUM_TAB.LAST) :=i;
    END LOOP;
    RETURN L_NUM_TAB;
END FN_GET_TABLE_OF_NUMBERS;
SELECT * FROM (FN_GET_TABLE_OF_NUMBERS(10));

SELECT ROWNUM FROM XMLTABLE('1 to 10');

6. WRTIE 'WELCOME' PRAMID

SELECT ROWNUM,SUBSTR('WELCOME',ROWNUM,1)OUTPUT1,
SUBSTR('WELCOME',ROWNUM*-1,1) OUTPUT2,
SUBSTR('WELCOME',1,ROWNUM) OUTPUT3,
SUBSTR('WELCOME',ROWNUM) OUTPUT4,
RPAD(' ', ROWNUM, ' ')||SUBSTR('WELCOME',ROWNUM) OUTPUT5,
RPAD(' ', LENGTH('WELCOME')+1-ROWNUM, ' ')||SUBSTR('WELCOME',1,ROWNUM) OUTPUT6
FROM DUAL CONNECT BY LEVEL<=LENGTH('WELCOME');

SELECT RPAD('*', ROWNUM,'*') AS OUTPUT1, 
RPAD('*', :NUM-ROWNUM+1,'*') AS OUTPUT2,
RPAD(' ',ROWNUM, ' ') || RPAD('*', :NUM-ROWNUM+1,'*') AS OUTPUT3,
RPAD(' ', :NUM-ROWNUM+1, ' ') || RPAD('*',ROWNUM,'*') AS OUTPUT4,
RPAD(' ', ROWNUM, ' ')||RPAD('*', ROWNUM,'*') AS OUTPUT5,
RPAD(' ', :NUM-ROWNUM+1, ' ')||RPAD(' ', :NUM-ROWNUM+1, ' ')||RPAD('*', ROWNUM,'*') AS OUTPUT6
FROM DUAL CONNECT BY LEVEL<=:NUM;

WITH D1 AS (SELECT RPAD('*', ROWNUM, '*') || RPAD(' ', :NUM-ROWNUM+1,' ') || RPAD(' ', :NUM-ROWNUM+1,' ') || RPAD('*', ROWNUM, '*') O1
FROM DUAL CONNECT BY LEVEL<=:NUM),
D2 AS (SELECT RPAD('*', :NUM-ROWNUM+1, '*') || RPAD(' ', ROWNUM,' ') || RPAD(' ', ROWNUM,' ') || RPAD('*', :NUM-ROWNUM+1, '*') O2
FROM DUAL CONNECT BY LEVEL<=:NUM)
SELECT * FROM D2
UNION ALL
SELECT * FROM D1;

7. WRITE FIRST NAME LAST NAME DOMAIN NAME FROM EMAIL.

WITH D AS (SELECT 'PALANIVEL.SUBRMANI.MANO@YHOO.IN'EMAIL FROM DUAL UNION ALL
SELECT 'MANO.PRIYA.PALANI@GMAIL.IN'EMAIL FROM DUAL UNION ALL
SELECT 'ASHWIN.PALANIVEL.MANO@GMAIL.IN'EMAIL FROM DUAL),

DS AS (SELECT SUBSTR(EMAIL,1,INSTR(EMAIL,'@')-1) NAME,
SUBSTR(EMAIL,INSTR(EMAIL,'@')+1) DOMAIN_NAME FROM D)

SELECT SUBSTR(NAME, 1, INSTR(NAME,'.',1,1)-1) FIRST_NAME,
SUBSTR(NAME,INSTR(NAME,'.',1,1)+1,INSTR(NAME,'.',1,2)-INSTR(NAME,'.',1,1)-1) MIDDLE_NAME,
SUBSTR(NAME,INSTR(NAME,'.',1,2)+1) LAST_NAME,
DOMAIN_NAME
FROM DS;


WITH D AS (SELECT 'PALANIVEL.SUBRMANI.MANO@YHOO.IN'EMAIL FROM DUAL UNION ALL
SELECT 'MANO@GMAIL.IN'EMAIL FROM DUAL UNION ALL
SELECT 'ASHWIN.MANO@GMAIL.IN'EMAIL FROM DUAL),

DS AS (SELECT SUBSTR(EMAIL,1,INSTR(EMAIL,'@')-1) NAME,
SUBSTR(EMAIL,INSTR(EMAIL,'@')+1) DOMAIN_NAME FROM D),
D2 AS (SELECT NAME,DOMAIN_NAME, INSTR(NAME,'.',1,1)F_DOT,INSTR(NAME,'.',1,2)S_DOT FROM DS),

D3 AS (SELECT NAME,DOMAIN_NAME,F_DOT,S_DOT,
SUBSTR(NAME,1,DECODE(F_DOT,0,LENGTH(NAME),F_DOT-1))FIRST_NAME,
DECODE(S_DOT,0,NULL,SUBSTR(NAME,F_DOT+1,S_DOT-F_DOT-1)) MIDDLE_NAME,
DECODE(F_DOT+S_DOT,0,NULL,SUBSTR(NAME,DECODE(S_DOT,0,F_DOT,S_DOT)+1)) LAST_NAME
FROM D2)

SELECT FIRST_NAME, MIDDLE_NAME, LAST_NAME, DOMAIN_NAME FROM D3;

8. EMPLOYEE HIERARCY 

CREATE TABLE EMP_LEVEL(EMP_ID NUMBER, EMP_NAME CHAR, MANAGER_ID NUMBER);

INSERT INTO EMP_LEVEL
SELECT 1, 'A', NULL FROM DUAL UNION ALL
SELECT 2, 'B', 1 FROM DUAL UNION ALL
SELECT 3, 'C', 1 FROM DUAL UNION ALL
SELECT 4, 'D', 2 FROM DUAL UNION ALL
SELECT 5, 'E', 2 FROM DUAL UNION ALL
SELECT 6, 'F', 3 FROM DUAL UNION ALL
SELECT 7, 'B', 3 FROM DUAL UNION ALL
SELECT 8, 'H', 3 FROM DUAL UNION ALL
SELECT 9, 'I', 5 FROM DUAL;

SELECT * FROM EMP_LEVEL;

SELECT EMP_ID,EMP_NAME,MANAGER_ID
FROM EMP_LEVEL
START WITH MANAGER_ID = 1
CONNECT BY
PRIOR EMP_ID = MANAGER_ID
ORDER SIBLINGS BY
EMP_ID;

SELECT LEVEL AS REPORTING_LEVEL,
LISTAGG(EMP_NAME,', ')WITHIN GROUP (ORDER BY EMP_ID) AS  EMPS
FROM EMP_LEVEL
START WITH MANAGER_ID = 1
CONNECT BY
PRIOR EMP_ID = MANAGER_ID
GROUP BY LEVEL
ORDER BY LEVEL;

-- Create the EMP_LEVEL_SAL table
CREATE TABLE EMP_LEVEL_SAL (
    EMPNO      NUMBER PRIMARY KEY,
    EMP_NAME   VARCHAR2(50),
    MANAGERNO  NUMBER,
    SALARY     NUMBER
);

-- Insert 10 sample records
INSERT INTO EMP_LEVEL_SAL (EMPNO, EMP_NAME, MANAGERNO, SALARY) VALUES (1, 'John', NULL, 10000);  -- John is the CEO (no manager)
INSERT INTO EMP_LEVEL_SAL (EMPNO, EMP_NAME, MANAGERNO, SALARY) VALUES (2, 'Alice', 1, 8000);     -- Alice reports to John
INSERT INTO EMP_LEVEL_SAL (EMPNO, EMP_NAME, MANAGERNO, SALARY) VALUES (3, 'Bob', 1, 7500);       -- Bob reports to John
INSERT INTO EMP_LEVEL_SAL (EMPNO, EMP_NAME, MANAGERNO, SALARY) VALUES (4, 'Charlie', 2, 6000);   -- Charlie reports to Alice
INSERT INTO EMP_LEVEL_SAL (EMPNO, EMP_NAME, MANAGERNO, SALARY) VALUES (5, 'David', 2, 5500);     -- David reports to Alice
INSERT INTO EMP_LEVEL_SAL (EMPNO, EMP_NAME, MANAGERNO, SALARY) VALUES (6, 'Eva', 3, 5000);       -- Eva reports to Bob
INSERT INTO EMP_LEVEL_SAL (EMPNO, EMP_NAME, MANAGERNO, SALARY) VALUES (7, 'Frank', 3, 4500);     -- Frank reports to Bob
INSERT INTO EMP_LEVEL_SAL (EMPNO, EMP_NAME, MANAGERNO, SALARY) VALUES (8, 'Grace', 4, 4000);     -- Grace reports to Charlie
INSERT INTO EMP_LEVEL_SAL (EMPNO, EMP_NAME, MANAGERNO, SALARY) VALUES (9, 'Hank', 5, 3500);      -- Hank reports to David
INSERT INTO EMP_LEVEL_SAL (EMPNO, EMP_NAME, MANAGERNO, SALARY) VALUES (10, 'Ivy', 6, 3000);      -- Ivy reports to Eva

-- Commit the transaction
COMMIT;

-- Query the table to verify the data
SELECT * FROM EMP_LEVEL_SAL;

SELECT LEVEL, EMPNO,EMP_NAME,MANAGERNO,SALARY,
SYS_CONNECT_BY_PATH(EMP_NAME,'-->')
FROM EMP_LEVEL_SAL
START WITH MANAGERNO IS NULL
CONNECT BY PRIOR EMPNO = MANAGERNO;

SELECT SUM(SALARY)
FROM EMP_LEVEL_SAL
START WITH EMP_NAME = E.EMP_NAME
CONNECT BY PRIOR EMPNO = MANAGERNO;

SELECT EMPNO,EMP_NAME,MANAGERNO,SALARY,(
SELECT SUM(SALARY)
FROM EMP_LEVEL_SAL
START WITH EMP_NAME = E.EMP_NAME
CONNECT BY PRIOR EMPNO = MANAGERNO) GROUP_SALARY
FROM EMP_LEVEL_SAL E;

9. PRINT THE RESULT STATUS CONTAINING "YEAS WISE", "DEPT WISE" NO OF STUDENTS P/F;

CREATE TABLE STUDENTS_LIST(SNO NUMBER, NAME VARCHAR2(30), MARK NUMBER, RESULT VARCHAR2(1), DEPT VARCHAR2(5), YEAR NUMBER);

BEGIN
    FOR i IN 1..1000 LOOP
        INSERT INTO STUDENTS_LIST(SNO, NAME , MARK, DEPT, YEAR)
        VALUES (i, 'STUDENT_'||i,TRUNC(DBMS_RANDOM.VALUE(1,100)),
        TRUNC(DBMS_RANDOM.VALUE(1,6)),
        TRUNC(DBMS_RANDOM.VALUE(1,5)));
    END LOOP;
END;
/

update STUDENTS_LIST set result='P' 
where mark >=35;
update STUDENTS_LIST set result='F' 
where mark <35;

update STUDENTS_LIST set dept='CSE' where dept='1';
update STUDENTS_LIST set dept='ECE' where dept='2';
update STUDENTS_LIST set dept='EEE' where dept='3';
update STUDENTS_LIST set dept='MECH' where dept='4';
update STUDENTS_LIST set dept='CVE' where dept='5';

SELECT * FROM STUDENTS_LIST ORDER BY SNO;

SELECT DEPT,
MAX(CASE WHEN YEAR =1 THEN CNT END) Y_I,
MAX(CASE WHEN YEAR =2 THEN CNT END) Y_II,
MAX(CASE WHEN YEAR =3 THEN CNT END) Y_III,
MAX(CASE WHEN YEAR =4 THEN CNT END) Y_IV
FROM(
SELECT DEPT,YEAR,
'P= '||COUNT(CASE WHEN RESULT='P' THEN RESULT END) ||
', F= '||COUNT(CASE WHEN RESULT='F' THEN RESULT END) CNT
FROM STUDENTS_LIST
GROUP BY DEPT,YEAR)
GROUP BY DEPT;


SELECT * FROM(
SELECT DEPT,YEAR,
'P= '||COUNT(CASE WHEN RESULT='P' THEN RESULT END) ||
', F= '||COUNT(CASE WHEN RESULT='F' THEN RESULT END) CNT
FROM STUDENTS_LIST
GROUP BY DEPT,YEAR)
PIVOT (
MAX(CNT) FOR YEAR IN (1 I, 2 II, 3 III, 4 IV)
)

10. WRITE PASSIBLE ROUTES

SELECT * FROM IQA_TAB_CITY;

SELECT C1.CITY_ID CITY_ID_1, C1.CITY FROM_CITY, C2.CITY_ID CITY_ID_2, C2.CITY TO_CITY 
FROM IQA_TAB_CITY C1, IQA_TAB_CITY C2
WHERE C1.CITY_ID<C2.CITY_ID;

SELECT 
DISTINCT GREATEST(C1.CITY,C2.CITY) FROM_CITY, 
LEAST(C1.CITY,C2.CITY) TO_CITY 
FROM IQA_TAB_CITY C1,
IQA_TAB_CITY C2 WHERE C1.CITY <> C2.CITY;

11. WRITE TO DISPLAY REPORTING MANAGER AND EMPLOYEE HIERARCY

SELECT E.EMPLOYEE_ID, E.FIRST_NAME, NVL(E2.NO_REPS,0)NO_REPS, NVL(E2.EMP_NAMES,' ')EMP_NAMES FROM
(SELECT MANAGER_ID,COUNT(*) NO_REPS, LISTAGG(FIRST_NAME,',') EMP_NAMES FROM EMPLOYEES GROUP BY MANAGER_ID) E2
RIGHT OUTER JOIN EMPLOYEES E ON E.EMPLOYEE_ID = E2.MANAGER_ID
ORDER BY E.EMPLOYEE_ID

12. PRODUCT AND SERVICE, COMMA SEPARATED CODES WITH ITS DESCRIPTION

CREATE TABLE SERVICE(SERVICE_CODE CHAR, SERVICE_NAME VARCHAR2(15));

CREATE TABLE PRODUCT_SERVICE(PRODUCT_CODE VARCHAR(2), PRODUCT_DESC VARCHAR2(10), SERVICE_ORDER VARCHAR2(20));

INSERT INTO SERVICE(SERVICE_CODE, SERVICE_NAME) VALUES ('A', 'Service-A');
INSERT INTO SERVICE(SERVICE_CODE, SERVICE_NAME) VALUES ('B', 'Service-B');
INSERT INTO SERVICE(SERVICE_CODE, SERVICE_NAME) VALUES ('C', 'Service-C');
INSERT INTO SERVICE(SERVICE_CODE, SERVICE_NAME) VALUES ('D', 'Service-D');

INSERT INTO PRODUCT_SERVICE(PRODUCT_CODE, PRODUCT_DESC, SERVICE_ORDER) VALUES ('P1', 'PROD-P1', 'A,C');
INSERT INTO PRODUCT_SERVICE(PRODUCT_CODE, PRODUCT_DESC, SERVICE_ORDER) VALUES ('P2', 'PROD-P2', 'C,B,D');
INSERT INTO PRODUCT_SERVICE(PRODUCT_CODE, PRODUCT_DESC, SERVICE_ORDER) VALUES ('P3', 'PROD-P3', 'D,A,C,B');
INSERT INTO PRODUCT_SERVICE(PRODUCT_CODE, PRODUCT_DESC, SERVICE_ORDER) VALUES ('P4', 'PROD-P4', 'A,B,C,D');
INSERT INTO PRODUCT_SERVICE(PRODUCT_CODE, PRODUCT_DESC, SERVICE_ORDER) VALUES ('P5', 'PROD-P4', 'D,C,B,A,B');

SELECT * FROM SERVICE;

SELECT * FROM PRODUCT_SERVICE;
 
WITH PRD_LIST AS
(SELECT PRODUCT_CODE, PRODUCT_DESC, SERVICE_ORDER,L FROM PRODUCT_SERVICE,
LATERAL(SELECT LEVEL L FROM DUAL CONNECT BY LEVEL <= REGEXP_COUNT(SERVICE_ORDER, ',')+1)),

SERVICE_LIST AS (SELECT PRODUCT_CODE, PRODUCT_DESC, SERVICE_ORDER,L,
REGEXP_SUBSTR(SERVICE_ORDER,'[^,]+', 1, L) AS SERVICE_ID 
FROM PRD_LIST)

SELECT PRODUCT_CODE, PRODUCT_DESC, SERVICE_ORDER,
LISTAGG(S.SERVICE_NAME,', ') WITHIN GROUP (ORDER BY L) SERVICE_NAMES
FROM SERVICE_LIST SL
LEFT JOIN SERVICE S ON S.SERVICE_CODE = SL.SERVICE_ID
GROUP BY PRODUCT_CODE, PRODUCT_DESC, SERVICE_ORDER
ORDER BY PRODUCT_CODE;

13. WRITE SQL TO GENERATE ALL DATE RANGES FOR TRANSACTION RECORDS.

CREATE TABLE DAILY_TRAN_T(TRAN_DATE DATE, TRAN_DESC VARCHAR2(30), TAN_AMOUNT NUMBER);

INSERT INTO DAILY_TRAN_T(TRAN_DATE, TRAN_DESC, TAN_AMOUNT) VALUES (TO_DATE('05-MAY-2025','DD-MON-YYYY'), 'BILL PAYMENT', 1000);
INSERT INTO DAILY_TRAN_T(TRAN_DATE, TRAN_DESC, TAN_AMOUNT) VALUES (TO_DATE('07-MAY-2025','DD-MON-YYYY'), 'DEPOSIT', 5000);
INSERT INTO DAILY_TRAN_T(TRAN_DATE, TRAN_DESC, TAN_AMOUNT) VALUES (TO_DATE('12-MAY-2025','DD-MON-YYYY'), 'FEES PAYMENT', 2500);
INSERT INTO DAILY_TRAN_T(TRAN_DATE, TRAN_DESC, TAN_AMOUNT) VALUES (TO_DATE('13-MAY-2025','DD-MON-YYYY'), 'BONUS RECEIVED', 3400);
INSERT INTO DAILY_TRAN_T(TRAN_DATE, TRAN_DESC, TAN_AMOUNT) VALUES (TO_DATE('09-MAY-2025','DD-MON-YYYY'), 'BONUS RECEIVED', 3400);

WITH D AS
(SELECT TRUNC(MIN(TRAN_DATE),'MONTH') FIRST_DATE, 
LAST_DAY(MAX(TRAN_DATE)) - TRUNC(MIN(TRAN_DATE),'MONTH')+1 NO_OF_DAYS
FROM DAILY_TRAN_T),
CAL_DATES AS (SELECT FIRST_DATE+LEVEL-1 T_DATE FROM D
CONNECT BY LEVEL <=NO_OF_DAYS)
SELECT CD.T_DATE,TRAN_DESC,NVL(TAN_AMOUNT,0) AS TAN_AMOUNT FROM CAL_DATES CD
LEFT JOIN DAILY_TRAN_T T ON T.TRAN_DATE = CD.T_DATE
ORDER BY CD.T_DATE

14. SQL TO FIND THE NUMBER OF SATURDAY AND SUNDAY IN CURRENT MONTH

WITH DAYS AS
(SELECT TRUNC(MIN(TRAN_DATE),'MONTH') AS FIRST_DATE,
LAST_DAY(MAX(TRAN_DATE)) AS LAST_DATE,
LAST_DAY(MAX(TRAN_DATE)) - TRUNC(MIN(TRAN_DATE),'MONTH')+1 AS NO_OF_DAYS
FROM DAILY_TRAN_T),
ALL_DAYS_D AS (SELECT FIRST_DATE+LEVEL-1 AS DATES ,
TRIM(TO_CHAR(FIRST_DATE+LEVEL-1,'DAY')) AS ALL_DAYS
FROM DAYS
CONNECT BY LEVEL<=NO_OF_DAYS)
SELECT ALL_DAYS,COUNT(*) NO_OF_SUN_SAT FROM ALL_DAYS_D WHERE ALL_DAYS IN ('SATURDAY', 'SUNDAY')
GROUP BY ALL_DAYS;

SELECT TO_CHAR(C_DATE,'DAY') AS DAY,COUNT(*)NO_DAYS
FROM(
SELECT TRUNC(SYSDATE,'MONTH')+LEVEL-1 C_DATE FROM DUAL
CONNECT BY LEVEL <= LAST_DAY(TRUNC(SYSDATE)) - TRUNC(SYSDATE,'MONTH')+1)
WHERE TRIM(TO_CHAR(C_DATE,'DAY')) IN ('SATURDAY','SUNDAY')
GROUP BY TO_CHAR(C_DATE,'DAY');

15. TEAM, PLAYED, WON LOST.

WITH D AS (
SELECT TEAM_A A, TEAM_B B, CASE WHEN TEAM_A = WINNER THEN 1 ELSE 0 END A_W,
CASE WHEN TEAM_B = WINNER THEN 1 ELSE 0 END B_W FROM CRICKET)
SELECT TEAM,COUNT(*) NO_MATCH_PLAYED,SUM(WIN) AS WON,COUNT(*)-SUM(WIN) LOST FROM(
SELECT DECODE(R,1,A,B)TEAM,DECODE(R,1,A_W,B_W)WIN FROM D, (SELECT ROWNUM R FROM DUAL CONNECT BY LEVEL <=2))
GROUP BY TEAM;

16. A DICE IS ROLLED THREE TIMES.
	1. WRITE A SQL TO FIND THE LIST OF COMBINATIONS, WHERE THE THIRD ROLLED DOCE VALUE IS EQUAL TO SUM OF FIRST AND SECOND ROLLED VALUE.
	2. WRITE A SQL TO FIND THE LIST OF COMBINATIONS, WHERE ANY ROLL VALUE IS EQUAL TO SUM OF OTHER TWO ROLLED VALUES.
	
WITH T AS(SELECT LEVEL R FROM DUAL CONNECT BY LEVEL<=6) 
SELECT T1.R ROLL1, T2.R ROLL2, T3.R ROLL3 FROM T T1, T T2, T T3
WHERE T3.R = T1.R + T2.R ORDER BY T3.R;

WITH T AS(SELECT LEVEL R FROM DUAL CONNECT BY LEVEL<=6) 
SELECT T1.R ROLL1, T2.R ROLL2, T3.R ROLL3 FROM T T1, T T2, T T3
WHERE (T2.R = T1.R + T3.R) OR (T1.R = T3.R + T2.R) OR (T3.R = T1.R + T2.R)
ORDER BY T3.R;

17. SORT THE NUMBERS IN COMMA SEPARATED LIST. SORT THE CHARACTER IN THE GIVEN STRING.

WITH STR AS(SELECT '1,5,3,8,2,6,12,8,9,4,10' AS S FROM DUAL),
NUM AS (SELECT TO_NUMBER(REGEXP_SUBSTR(S,'[^,]+', 1, LEVEL)) NUMBERS FROM STR CONNECT BY 
LEVEL <= REGEXP_COUNT(S,'[^,]+'))
SELECT LISTAGG(NUMBERS,',') WITHIN GROUP (ORDER BY TO_NUMBER(NUMBERS)) CONVERTED FROM NUM;


WITH STR AS(SELECT 'WELCOME' AS S FROM DUAL),
CHARS AS (SELECT SUBSTR(S,LEVEL,1) CHRAC FROM STR CONNECT BY 
LEVEL <= LENGTH(S))
SELECT LISTAGG(CHRAC,'') WITHIN GROUP (ORDER BY TO_CHAR(CHRAC)) CONVERTED FROM CHARS;

18. REVERSE THE STRING WITHOUT REVERSE.

SELECT S ACTUAL_TEXT, LISTAGG(STR,'') WITHIN GROUP (ORDER BY L DESC) REVERESED FROM (
SELECT S, SUBSTR(S,LEVEL,1) STR, LEVEL L FROM (
SELECT 'WELCOME' S FROM DUAL) CONNECT BY LEVEL<=LENGTH(S)) GROUP BY S;

19. FIRST AND LAST RECORDS OF TABLE 1 INOT TABLE 2
SECOND AND LST BUT SECOND ROW OF TABLE 1 INTO TABLE 2
CONTINUEW THE SAME LOGIC TO INSERT ALL RECORDS OF TABLE 1 INTO TABLE 2

WITH D AS (
SELECT EMPNO,ENAME,
ROUND(COUNT(1) OVER()/2) - ROW_NUMBER() OVER (ORDER BY EMPNO) RNUM 
FROM EMP1),
D1 AS (SELECT EMPNO,ENAME, RNUM FROM D WHERE RNUM >=0),
D2 AS (SELECT EMPNO,ENAME, ABS(RNUM)RNUM  FROM D WHERE RNUM <0)
SELECT D1.EMPNO, D1.ENAME, D2.EMPNO, D2.ENAME FROM D1,D2 WHERE D1.RNUM = D2.RNUM (+)

20. WRITE A QUERY TO FILL THE MISSING DATE VALUES.

WITH DATE_LIST AS(
SELECT FIRST_DATE+LEVEL-1 AS DATES FROM(
SELECT MIN(TX_DATE)FIRST_DATE, MAX(TX_DATE) -  MIN(TX_DATE)+1 AS TOTAL_DAYS FROM TRAN_TAB)
CONNECT BY LEVEL <= TOTAL_DAYS)
SELECT DL.DATES, 
COALESCE(TX_AMOUNT,LAG(TX_AMOUNT IGNORE NULLS) OVER (ORDER BY DL.DATES)) TX_AMOUNT 
FROM DATE_LIST DL
LEFT JOIN TRAN_TAB TR ON TR.TX_DATE = DL.DATES
ORDER BY DL.DATES;

WITH DATE_LIST AS(
SELECT FIRST_DATE+LEVEL-1 AS DATES FROM(
SELECT MIN(TX_DATE)FIRST_DATE, MAX(TX_DATE) -  MIN(TX_DATE)+1 AS TOTAL_DAYS FROM TRAN_TAB)
CONNECT BY LEVEL <= TOTAL_DAYS)
SELECT DL.DATES, 
LAST_VALUE(TX_AMOUNT IGNORE NULLS) OVER (ORDER BY DL.DATES) TX_AMOUNT 
FROM DATE_LIST DL
LEFT JOIN TRAN_TAB TR ON TR.TX_DATE = DL.DATES
ORDER BY DL.DATES;

21. WRITE A QUERY TO COMPUTE THE START AND END OF GROUP IN THE GIVEN MISSING SEQ OF NUMBERS.

WITH VAL AS(SELECT NUMS,NUMS-ROWNUM AS CNUM FROM NUMBERS_TAB)
SELECT MIN(NUMS)START_RANGE, MAX(NUMS) END_RANGE FROM VAL
GROUP BY CNUM ORDER BY START_RANGE;

SELECT MIN(NUMS)START_RANGE, MAX(NUMS) END_RANGE FROM NUMBERS_TAB
GROUP BY (NUMS-ROWNUM) ORDER BY 1

REVERSE ORDER: 

WITH TABL AS(
SELECT MIN(NUMS)START_RANGE, MAX(NUMS) END_RANGE FROM NUMBERS_TAB
GROUP BY (NUMS-ROWNUM) ORDER BY 1),
DATEDIFF AS
(SELECT START_RANGE+LEVEL-1 FN FROM TABL
CONNECT BY LEVEL <= END_RANGE - START_RANGE+1)
SELECT DISTINCT FN FROM DATEDIFF ORDER BY FN;

22. WRITE A QUERY TO GROUP THE SEQUENTIAL RANGTE OF DATA INTO SINGLE ROW OF DATA.

WITH YEARDIFF AS(
SELECT NAME, START_YEAR, END_YEAR, END_YEAR - START_YEAR+1 DIFF  FROM CARS),
TOT_YEARS AS 
(SELECT NAME,START_YEAR+LEVEL-1 ALL_YEAR FROM YEARDIFF
CONNECT BY LEVEL <= DIFF),
FIN AS (SELECT DISTINCT NAME,ALL_YEAR  FROM TOT_YEARS ORDER BY 1,2)
SELECT NAME, MIN(ALL_YEAR)START_DATE, MAX(ALL_YEAR)END_DATE FROM FIN
GROUP BY NAME, ALL_YEAR-ROWNUM
ORDER BY 1 DESC,2 ASC

WITH R AS(
SELECT DISTINCT NAME, START_YEAR+R YEAR FROM CARS,
LATERAL(SELECT ROWNUM-1 R FROM DUAL CONNECT BY LEVEL <= END_YEAR-START_YEAR+1)
ORDER BY 1,2)
SELECT NAME, MIN(YEAR) START_YEAR, MAX(YEAR) END_YEAR
FROM R GROUP BY NAME, YEAR-ROWNUM ORDER BY 1, 2;

23. WRITE A SQL TO CHECK WHETHER SUDOKU IS RESOLVED.

SELECT ROW_NO, C1+C2+C3+C4+C5+C6+C7+C8+C9 ROW_SUM FROM SUDOKU;

SELECT SUM(C1) C1, SUM(C2) C2, SUM(C3) C3, SUM(C4) C4, SUM(C5) C5, SUM(C6) C6, SUM(C7) C7, SUM(C8) C8, SUM(C9) C9 
FROM SUDOKU;

SELECT 'G'||CEIL(ROWNUM/3) AS GRP, SUM(C1+C2+C3) G1, SUM(C4+C5+C6) G2, SUM(C7+C8+C9) G3 FROM SUDOKU
GROUP BY CEIL(ROWNUM/3);

SELECT * FROM (
SELECT SUM(C1) C1, SUM(C2) C2, SUM(C3) C3, SUM(C4) C4, SUM(C5) C5, SUM(C6) C6, SUM(C7) C7, SUM(C8) C8, SUM(C9) C9 
FROM SUDOKU)
UNPIVOT(COLUMN_VAL FOR COLUMN_NAME IN (C1, C2, C3, C4, C5, C6, C7, C8, C9));

SELECT GRP||COLUMN_NAME GRP_NAME,COLUMN_VAL GRP_SUM FROM(
SELECT 'G'||CEIL(ROWNUM/3) AS GRP, SUM(C1+C2+C3) G1, SUM(C4+C5+C6) G2, SUM(C7+C8+C9) G3 FROM SUDOKU
GROUP BY CEIL(ROWNUM/3))
UNPIVOT(COLUMN_VAL FOR COLUMN_NAME IN (G1, G2, G3));

SELECT ROW_NO, C1+C2+C3+C4+C5+C6+C7+C8+C9 ROW_SUM FROM SUDOKU;

SELECT CASE WHEN SUM(DISTINCT COL_SUM) = 45 THEN 'CORRECT' ELSE 'INCORRECT' END CASE FROM(
SELECT COLUMN_NAME,COLUMN_VAL COL_SUM FROM (
SELECT SUM(C1) C1, SUM(C2) C2, SUM(C3) C3, SUM(C4) C4, SUM(C5) C5, SUM(C6) C6, SUM(C7) C7, SUM(C8) C8, SUM(C9) C9 
FROM SUDOKU)
UNPIVOT(COLUMN_VAL FOR COLUMN_NAME IN (C1, C2, C3, C4, C5, C6, C7, C8, C9))
UNION ALL
SELECT GRP||COLUMN_NAME GRP_NAME,COLUMN_VAL GRP_SUM FROM(
SELECT 'G'||CEIL(ROWNUM/3) AS GRP, SUM(C1+C2+C3) G1, SUM(C4+C5+C6) G2, SUM(C7+C8+C9) G3 FROM SUDOKU
GROUP BY CEIL(ROWNUM/3))
UNPIVOT(COLUMN_VAL FOR COLUMN_NAME IN (G1, G2, G3))
UNION ALL
SELECT ROW_NO, C1+C2+C3+C4+C5+C6+C7+C8+C9 COL_SUM FROM SUDOKU);

25. WRITE A SQL TO CONVERT SINGLE COLUMN OF DATA IN TO TABLE FORMAT.

WITH CNT AS
(SELECT SQRT(COUNT(*)) CNT FROM SEQ_NUM),
PT AS (SELECT NUM,CEIL(NUM/CNT) X, ROW_NUMBER() OVER (PARTITION BY CEIL(NUM/CNT) ORDER BY NUM) Y 
FROM CNT, SEQ_NUM ORDER BY 1,2,3)
SELECT C1, C2, C3, C4, C5, C6, C7, C8, C9, C10 FROM PT
PIVOT(SUM(NUM) FOR Y IN (1 C1,2 C2,3 C3,4 C4,5 C5,6 C6,7 C7,8 C8,9 C9,10 C10))
ORDER BY X;

SELECT C1, C2, C3, C4, C5, C6, C7, C8, C9, C10 FROM(
SELECT NUM,CEIL(NUM/10) X, ROW_NUMBER() OVER (PARTITION BY CEIL(NUM/10) ORDER BY NUM)Y FROM SEQ_NUM
) PIVOT (SUM(NUM) FOR Y IN (1 C1,2 C2,3 C3,4 C4,5 C5,6 C6,7 C7,8 C8,9 C9,10 C10)) ORDER BY X;

SELECT C1, C2, C3, C4, C5, C6, C7, C8, C9, C10 FROM(
SELECT NUM,CEIL(NUM/10) X, ROW_NUMBER() OVER (PARTITION BY CEIL(NUM/10) ORDER BY NUM)Y FROM SEQ_NUM
) PIVOT (SUM(NUM) FOR X IN (1 C1,2 C2,3 C3,4 C4,5 C5,6 C6,7 C7,8 C8,9 C9,10 C10)) ORDER BY Y;

27. WRITE A SQL TO DISPLAY THE EMP DATA IN FLAT FORMAT

SELECT
NVL(REGEXP_SUBSTR(ENOLIST, '\w+',1,1),' ') LV1_EMPNO, NVL(REGEXP_SUBSTR(ENAMELIST, '\w+',1,1),' ')  LV1_ENAME, 
DECODE(REGEXP_SUBSTR(ENOLIST, '\w+',1,1),NULL,' ', 1) LV1,
NVL(REGEXP_SUBSTR(ENOLIST, '\w+',1,1),' ')  LV2_EMPNO, NVL(REGEXP_SUBSTR(ENAMELIST, '\w+',1,2),' ')  LV1_ENAME,
DECODE(REGEXP_SUBSTR(ENOLIST, '\w+',1,2),NULL,' ', 2) LV2,
NVL(REGEXP_SUBSTR(ENOLIST, '\w+',1,1),' ')  LV3_EMPNO, NVL(REGEXP_SUBSTR(ENAMELIST, '\w+',1,3),' ')  LV1_ENAME,
DECODE(REGEXP_SUBSTR(ENOLIST, '\w+',1,3),NULL,' ', 3) LV3,
NVL(REGEXP_SUBSTR(ENOLIST, '\w+',1,1),' ')  LV4_EMPNO, NVL(REGEXP_SUBSTR(ENAMELIST, '\w+',1,4),' ')  LV1_ENAME,
DECODE(REGEXP_SUBSTR(ENOLIST, '\w+',1,4),NULL,' ', 4) LV4,
NVL(REGEXP_SUBSTR(ENOLIST, '\w+',1,1),' ')  LV5_EMPNO, NVL(REGEXP_SUBSTR(ENAMELIST, '\w+',1,5),' ')  LV1_ENAME,
DECODE(REGEXP_SUBSTR(ENOLIST, '\w+',1,5),NULL,' ', 5) LV5
FROM(
SELECT TRIM(',' FROM SYS_CONNECT_BY_PATH(EMPLOYEE_ID, ',')) ENOLIST,
TRIM(',' FROM SYS_CONNECT_BY_PATH(FIRST_NAME, ',')) ENAMELIST,
CONNECT_BY_ISLEAF ISLEAF
FROM EMPLOYEES
START WITH MANAGER_ID IS NULL
CONNECT BY PRIOR employee_id = MANAGER_ID)
WHERE ISLEAF = 1

28. WRITE A SQL TO GROUP THE EMPLOYEES INTO TEAMS. TEAM MEMBERS SHOULD BE FROM SAME CITY.

SELECT * FROM EMP_CITY_TEAM;

WITH T AS (
SELECT ENAME, CITY, 
CEIL(ROW_NUMBER() OVER (PARTITION BY CITY ORDER BY ROWNUM)/2) GRP_NO 
FROM EMP_CITY_TEAM)
SELECT CITY, LISTAGG(ENAME,',') WITHIN GROUP (ORDER BY ENAME) TEAM_NAMES,
'TEAM-'||ROW_NUMBER() OVER (ORDER BY CITY) TEAM_NAME
FROM T GROUP BY CITY, GRP_NO;

WITH T AS (
SELECT ENAME, CITY, 
CEIL(ROW_NUMBER() OVER (PARTITION BY CITY ORDER BY ROWNUM)/3) GRP_NO 
FROM EMP_CITY_TEAM)
SELECT CITY, LISTAGG(ENAME,',') WITHIN GROUP (ORDER BY ENAME) TEAM_NAMES,
'TEAM-'||ROW_NUMBER() OVER (ORDER BY CITY) TEAM_NAME
FROM T GROUP BY CITY, GRP_NO;

WITH T AS (
SELECT ENAME, CITY, 
CEIL(ROW_NUMBER() OVER (PARTITION BY CITY ORDER BY ROWNUM)/4) GRP_NO 
FROM EMP_CITY_TEAM)
SELECT CITY, LISTAGG(ENAME,',') WITHIN GROUP (ORDER BY ENAME) TEAM_NAMES,
'TEAM-'||ROW_NUMBER() OVER (ORDER BY CITY) TEAM_NAME
FROM T GROUP BY CITY, GRP_NO;

WITH T AS (
SELECT ENAME, CITY, 
CEIL(ROW_NUMBER() OVER (PARTITION BY CITY ORDER BY ROWNUM)/5) GRP_NO 
FROM EMP_CITY_TEAM)
SELECT CITY, LISTAGG(ENAME,',') WITHIN GROUP (ORDER BY ENAME) TEAM_NAMES,
'TEAM-'||ROW_NUMBER() OVER (ORDER BY CITY) TEAM_NAME
FROM T GROUP BY CITY, GRP_NO;

29. WRITE SQL TO FIND THE CONSECUTIVE STATUS OF RED BASED ON ID REPORT THE ID ONLY IF THE NUMBER OF LAST CONSECUTIVEES STATUS GREATER THAN OR EQUAL TO 3.

SELECT * FROM PRJ_STATUS;

SELECT ID,COUNT(*) FROM(
SELECT ID,SUM(DECODE(STATUS,'Red',0,1)) OVER (PARTITION BY ID ORDER BY TO_DATE(REPORTING_MONTH,'Mon-YY') DESC)D
FROM PRJ_STATUS)
WHERE D =0 GROUP BY ID HAVING COUNT(*) >= 3

30. 