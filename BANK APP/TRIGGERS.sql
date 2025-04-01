-- Auto-generate customer ID and track updates
CREATE OR REPLACE TRIGGER trg_customers_bi
BEFORE INSERT ON customers
FOR EACH ROW
BEGIN
    IF :NEW.customer_id IS NULL THEN
        :NEW.customer_id := seq_customer_id.NEXTVAL;
    END IF;
    :NEW.date_created := SYSDATE;
    :NEW.last_updated := SYSDATE;
END;
/

CREATE OR REPLACE TRIGGER trg_customers_bu
BEFORE UPDATE ON customers
FOR EACH ROW
BEGIN
    :NEW.last_updated := SYSDATE;
END;
/

-- Auto-generate account ID and account number
CREATE OR REPLACE TRIGGER trg_accounts_bi
BEFORE INSERT ON accounts
FOR EACH ROW
BEGIN
    IF :NEW.account_id IS NULL THEN
        :NEW.account_id := seq_account_id.NEXTVAL;
    END IF;
    
    IF :NEW.account_number IS NULL THEN
        :NEW.account_number := 'CITY' || TO_CHAR(SYSDATE, 'YYMMDD') || LPAD(seq_account_id.CURRVAL, 6, '0');
    END IF;
END;
/

-- Update last activity date when transaction occurs
CREATE OR REPLACE TRIGGER trg_accounts_activity
AFTER INSERT OR UPDATE ON transactions
FOR EACH ROW
BEGIN
    UPDATE accounts
    SET last_activity_date = SYSDATE
    WHERE account_id = :NEW.account_id;
END;
/

-- Auto-generate transaction ID
CREATE OR REPLACE TRIGGER trg_transactions_bi
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN
    IF :NEW.transaction_id IS NULL THEN
        :NEW.transaction_id := seq_transaction_id.NEXTVAL;
    END IF;
END;
/

-- Update account balance after transaction
CREATE OR REPLACE TRIGGER trg_transactions_balance
AFTER INSERT ON transactions
FOR EACH ROW
DECLARE
    v_balance NUMBER(15,2);
BEGIN
    IF :NEW.transaction_type = 'DEPOSIT' THEN
        UPDATE accounts
        SET balance = balance + :NEW.amount
        WHERE account_id = :NEW.account_id;
    ELSIF :NEW.transaction_type = 'WITHDRAWAL' THEN
        UPDATE accounts
        SET balance = balance - :NEW.amount
        WHERE account_id = :NEW.account_id;
    END IF;
END;
/

-- Generic audit trigger for all tables
CREATE OR REPLACE TRIGGER trg_audit_customers
AFTER INSERT OR UPDATE OR DELETE ON customers
FOR EACH ROW
DECLARE
    v_action VARCHAR2(10);
    v_old_val CLOB;
    v_new_val CLOB;
BEGIN
    IF INSERTING THEN
        v_action := 'INSERT';
        v_new_val := 'Customer ID: ' || :NEW.customer_id || ', Name: ' || :NEW.first_name || ' ' || :NEW.last_name;
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
        v_old_val := 'Customer ID: ' || :OLD.customer_id || ', Name: ' || :OLD.first_name || ' ' || :OLD.last_name;
        v_new_val := 'Customer ID: ' || :NEW.customer_id || ', Name: ' || :NEW.first_name || ' ' || :NEW.last_name;
    ELSIF DELETING THEN
        v_action := 'DELETE';
        v_old_val := 'Customer ID: ' || :OLD.customer_id || ', Name: ' || :OLD.first_name || ' ' || :OLD.last_name;
    END IF;
    
    INSERT INTO audit_log (log_id, table_name, record_id, action, user_id, old_value, new_value)
    VALUES (seq_audit_log_id.NEXTVAL, 'CUSTOMERS', NVL(:NEW.customer_id, :OLD.customer_id), v_action, USER, v_old_val, v_new_val);
END;
/