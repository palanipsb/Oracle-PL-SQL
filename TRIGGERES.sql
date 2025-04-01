CREATE TABLE TRG_EMPLOYEES (
    employee_id   NUMBER PRIMARY KEY,
    first_name    VARCHAR2(50),
    last_name     VARCHAR2(50),
    department_id NUMBER,
    salary        NUMBER
);

CREATE TABLE TRG_DEPARTMENTS (
    department_id   NUMBER PRIMARY KEY,
    department_name VARCHAR2(50),
    budget          NUMBER
);

CREATE TABLE employee_audit_log (
    log_id        NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    employee_id   NUMBER,
    operation     VARCHAR2(10), -- INSERT, UPDATE, DELETE
    old_salary    NUMBER,
    new_salary    NUMBER,
    changed_by    VARCHAR2(50),
    change_date   DATE
);

CREATE TABLE employee_audit_summary (
    summary_id    NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    operation     VARCHAR2(10), -- INSERT, UPDATE, DELETE
    total_count   NUMBER,
    changed_by    VARCHAR2(50),
    change_date   DATE
);

CREATE OR REPLACE TRIGGER trg_employee_management
FOR INSERT OR UPDATE OR DELETE ON TRG_EMPLOYEES
COMPOUND TRIGGER
    -- Declare variables for department budget and total salary
    TYPE dept_salary_type IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    v_department_budget dept_salary_type;
    v_total_salary      dept_salary_type;

    -- Variables to track operation counts
    v_insert_count NUMBER := 0;
    v_update_count NUMBER := 0;
    v_delete_count NUMBER := 0;

    -- Before Statement Section
    BEFORE STATEMENT IS
    BEGIN
        -- Initialize department budget and total salary for all TRG_DEPARTMENTS
        FOR dept IN (SELECT department_id, budget FROM TRG_DEPARTMENTS) LOOP
            v_department_budget(dept.department_id) := dept.budget;
            v_total_salary(dept.department_id) := 0;
        END LOOP;

        -- Calculate the current total salary for each department
        FOR emp IN (SELECT department_id, salary FROM TRG_EMPLOYEES) LOOP
            v_total_salary(emp.department_id) := NVL(v_total_salary(emp.department_id), 0) + emp.salary;
        END LOOP;
    END BEFORE STATEMENT;

    -- Before Each Row Section
    
        -- For INSERT and UPDATE: Check department budget constraint
        IF INSERTING OR UPDATING THEN
            -- Calculate the new total salary for the department
            v_total_salary(:NEW.department_id) := NVL(v_total_salary(:NEW.department_id), 0) + :NEW.salary;

            -- Check if the new total salary exceeds the budget
            IF v_total_salary(:NEW.department_id) > v_department_budget(:NEW.department_id) THEN
                RAISE_APPLICATION_ERROR(-20001, 'Department budget exceeded for department ' || :NEW.department_id || '.');
            END IF;
        END IF;

        -- For UPDATE: Ensure salary is not decreased
        IF UPDATING THEN
            IF :NEW.salary < :OLD.salary THEN
                RAISE_APPLICATION_ERROR(-20002, 'Salary cannot be decreased.');
            END IF;
        END IF;

        -- For DELETE: Adjust the total salary for the department
        IF DELETING THEN
            v_total_salary(:OLD.department_id) := NVL(v_total_salary(:OLD.department_id), 0) - :OLD.salary;
        END IF;
    END BEFORE EACH ROW;

    -- After Each Row Section
    AFTER EACH ROW IS
    BEGIN
        -- Log the operation
        IF INSERTING THEN
            INSERT INTO employee_audit_log (employee_id, operation, new_salary, changed_by, change_date)
            VALUES (:NEW.employee_id, 'INSERT', :NEW.salary, USER, SYSDATE);
            v_insert_count := v_insert_count + 1;
        ELSIF UPDATING THEN
            INSERT INTO employee_audit_log (employee_id, operation, old_salary, new_salary, changed_by, change_date)
            VALUES (:NEW.employee_id, 'UPDATE', :OLD.salary, :NEW.salary, USER, SYSDATE);
            v_update_count := v_update_count + 1;
        ELSIF DELETING THEN
            INSERT INTO employee_audit_log (employee_id, operation, old_salary, changed_by, change_date)
            VALUES (:OLD.employee_id, 'DELETE', :OLD.salary, USER, SYSDATE);
            v_delete_count := v_delete_count + 1;
        END IF;
    END AFTER EACH ROW;

    -- After Statement Section
    AFTER STATEMENT IS
    BEGIN
        -- Log the summary of operations
        IF v_insert_count > 0 THEN
            INSERT INTO employee_audit_summary (operation, total_count, changed_by, change_date)
            VALUES ('INSERT', v_insert_count, USER, SYSDATE);
        END IF;

        IF v_update_count > 0 THEN
            INSERT INTO employee_audit_summary (operation, total_count, changed_by, change_date)
            VALUES ('UPDATE', v_update_count, USER, SYSDATE);
        END IF;

        IF v_delete_count > 0 THEN
            INSERT INTO employee_audit_summary (operation, total_count, changed_by, change_date)
            VALUES ('DELETE', v_delete_count, USER, SYSDATE);
        END IF;
    END AFTER STATEMENT;
END trg_employee_management;
/

-- Insert TRG_DEPARTMENTS
INSERT INTO TRG_DEPARTMENTS (department_id, department_name, budget) VALUES (10, 'Sales', 100000);
INSERT INTO TRG_DEPARTMENTS (department_id, department_name, budget) VALUES (20, 'Marketing', 80000);

-- Insert TRG_EMPLOYEES
INSERT INTO TRG_EMPLOYEES (employee_id, first_name, last_name, department_id, salary) VALUES (1, 'John', 'Doe', 10, 50000);
INSERT INTO TRG_EMPLOYEES (employee_id, first_name, last_name, department_id, salary) VALUES (2, 'Jane', 'Smith', 10, 40000);
INSERT INTO TRG_EMPLOYEES (employee_id, first_name, last_name, department_id, salary) VALUES (3, 'Alice', 'Johnson', 20, 30000);

-- Valid insert
INSERT INTO TRG_EMPLOYEES (employee_id, first_name, last_name, department_id, salary) VALUES (4, 'Bob', 'Brown', 10, 10000);

-- Valid update
UPDATE TRG_EMPLOYEES SET salary = 55000 WHERE employee_id = 1;

-- Delete an employee
DELETE FROM TRG_EMPLOYEES WHERE employee_id = 3;

-- Check the detailed audit log
SELECT * FROM employee_audit_log;

-- Check the audit summary
SELECT * FROM employee_audit_summary;