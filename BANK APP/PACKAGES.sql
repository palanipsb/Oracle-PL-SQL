CREATE OR REPLACE PACKAGE PKG_TRANSACTIONS_API AS
    -- Customer Management
    PROCEDURE create_customer(
        p_first_name      IN VARCHAR2,
        p_last_name       IN VARCHAR2,
        p_dob             IN DATE,
        p_email           IN VARCHAR2,
        p_phone           IN VARCHAR2,
        p_address         IN VARCHAR2,
        p_city            IN VARCHAR2,
        p_state           IN VARCHAR2,
        p_zip             IN VARCHAR2,
        p_ssn             IN VARCHAR2,
        p_customer_id     OUT NUMBER,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    );
    
    PROCEDURE update_customer(
        p_customer_id     IN NUMBER,
        p_email           IN VARCHAR2 DEFAULT NULL,
        p_phone           IN VARCHAR2 DEFAULT NULL,
        p_address         IN VARCHAR2 DEFAULT NULL,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    );
    
    -- Account Management
    PROCEDURE open_account(
        p_customer_id     IN NUMBER,
        p_account_type    IN VARCHAR2,
        p_initial_deposit IN NUMBER,
        p_interest_rate   IN NUMBER DEFAULT NULL,
        p_account_id      OUT NUMBER,
        p_account_number  OUT VARCHAR2,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    );
    
    PROCEDURE close_account(
        p_account_id      IN NUMBER,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    );
    
    -- Transaction Processing
    PROCEDURE process_transaction(
        p_account_id      IN NUMBER,
        p_transaction_type IN VARCHAR2,
        p_amount          IN NUMBER,
        p_description     IN VARCHAR2 DEFAULT NULL,
        p_reference       IN VARCHAR2 DEFAULT NULL,
        p_transaction_id  OUT NUMBER,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    );
    
    PROCEDURE transfer_funds(
        p_from_account    IN NUMBER,
        p_to_account      IN NUMBER,
        p_amount          IN NUMBER,
        p_description     IN VARCHAR2 DEFAULT NULL,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    );
    
    -- Loan Management
    PROCEDURE apply_loan(
        p_customer_id     IN NUMBER,
        p_loan_type       IN VARCHAR2,
        p_amount          IN NUMBER,
        p_interest_rate   IN NUMBER,
        p_term_months     IN NUMBER,
        p_loan_id         OUT NUMBER,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    );
    
    PROCEDURE process_loan_payment(
        p_loan_id         IN NUMBER,
        p_amount          IN NUMBER,
        p_payment_date    IN DATE DEFAULT SYSDATE,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    );
    
    -- Reporting
    PROCEDURE get_customer_accounts(
        p_customer_id     IN NUMBER,
        p_account_cursor  OUT SYS_REFCURSOR,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    );
    
    PROCEDURE get_account_statement(
        p_account_id      IN NUMBER,
        p_start_date      IN DATE DEFAULT NULL,
        p_end_date        IN DATE DEFAULT NULL,
        p_statement_cursor OUT SYS_REFCURSOR,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    );
    
    -- Security Functions
    FUNCTION encrypt_data(p_data IN VARCHAR2) RETURN RAW;
    FUNCTION decrypt_data(p_data IN RAW) RETURN VARCHAR2;
    
    -- Bulk Processing
    PROCEDURE bulk_update_account_balances(
        p_batch_size      IN NUMBER DEFAULT 10000,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    );
    
    -- Utility Functions
    FUNCTION validate_customer(p_customer_id IN NUMBER) RETURN BOOLEAN;
    FUNCTION validate_account(p_account_id IN NUMBER) RETURN BOOLEAN;
    
END PKG_TRANSACTIONS_API;
/

CREATE OR REPLACE PACKAGE BODY PKG_TRANSACTIONS_API AS
    -- Encryption key (should be stored more securely in production)
    gc_encryption_key VARCHAR2(32) := 'A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6';
    
    -- Exception codes
    gc_invalid_customer EXCEPTION;
    gc_invalid_account EXCEPTION;
    gc_insufficient_funds EXCEPTION;
    gc_loan_approval_failed EXCEPTION;
    PRAGMA EXCEPTION_INIT(gc_invalid_customer, -20001);
    PRAGMA EXCEPTION_INIT(gc_invalid_account, -20002);
    PRAGMA EXCEPTION_INIT(gc_insufficient_funds, -20003);
    PRAGMA EXCEPTION_INIT(gc_loan_approval_failed, -20004);
    
    -- Customer Management Procedures
    PROCEDURE create_customer(
        p_first_name      IN VARCHAR2,
        p_last_name       IN VARCHAR2,
        p_dob             IN DATE,
        p_email           IN VARCHAR2,
        p_phone           IN VARCHAR2,
        p_address         IN VARCHAR2,
        p_city            IN VARCHAR2,
        p_state           IN VARCHAR2,
        p_zip             IN VARCHAR2,
        p_ssn             IN VARCHAR2,
        p_customer_id     OUT NUMBER,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    ) IS
        v_encrypted_ssn RAW(2000);
    BEGIN
        -- Encrypt sensitive data
        v_encrypted_ssn := encrypt_data(p_ssn);
        
        -- Insert customer with encrypted SSN
        INSERT INTO customers (
            customer_id, first_name, last_name, date_of_birth, 
            email, phone, address, city, state, zip_code, ssn
        ) VALUES (
            seq_customer_id.NEXTVAL, 
            p_first_name, p_last_name, p_dob,
            p_email, p_phone, p_address, p_city, p_state, p_zip,
            v_encrypted_ssn
        ) RETURNING customer_id INTO p_customer_id;
        
        p_status := 'SUCCESS';
        p_message := 'Customer created successfully';
        
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            p_status := 'ERROR';
            p_message := 'Customer with this email/phone/SSN already exists';
            ROLLBACK;
        WHEN OTHERS THEN
            p_status := 'ERROR';
            p_message := 'Error creating customer: ' || SQLERRM;
            ROLLBACK;
    END create_customer;
    
    PROCEDURE update_customer(
        p_customer_id     IN NUMBER,
        p_email           IN VARCHAR2 DEFAULT NULL,
        p_phone           IN VARCHAR2 DEFAULT NULL,
        p_address         IN VARCHAR2 DEFAULT NULL,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    ) IS
    BEGIN
        IF NOT validate_customer(p_customer_id) THEN
            RAISE gc_invalid_customer;
        END IF;
        
        UPDATE customers
        SET email = NVL(p_email, email),
            phone = NVL(p_phone, phone),
            address = NVL(p_address, address),
            last_updated = SYSDATE
        WHERE customer_id = p_customer_id;
        
        p_status := 'SUCCESS';
        p_message := 'Customer updated successfully';
        
        COMMIT;
    EXCEPTION
        WHEN gc_invalid_customer THEN
            p_status := 'ERROR';
            p_message := 'Invalid customer ID';
            ROLLBACK;
        WHEN OTHERS THEN
            p_status := 'ERROR';
            p_message := 'Error updating customer: ' || SQLERRM;
            ROLLBACK;
    END update_customer;
    
    -- Account Management Procedures
    PROCEDURE open_account(
        p_customer_id     IN NUMBER,
        p_account_type    IN VARCHAR2,
        p_initial_deposit IN NUMBER,
        p_interest_rate   IN NUMBER DEFAULT NULL,
        p_account_id      OUT NUMBER,
        p_account_number  OUT VARCHAR2,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    ) IS
        v_account_number VARCHAR2(20);
    BEGIN
        IF NOT validate_customer(p_customer_id) THEN
            RAISE gc_invalid_customer;
        END IF;
        
        -- Generate account number
        v_account_number := 'CITY' || TO_CHAR(SYSDATE, 'YYMMDD') || LPAD(seq_account_id.NEXTVAL, 6, '0');
        
        -- Insert account
        INSERT INTO accounts (
            account_id, customer_id, account_type, account_number,
            balance, interest_rate, open_date
        ) VALUES (
            seq_account_id.NEXTVAL, p_customer_id, p_account_type, v_account_number,
            p_initial_deposit, p_interest_rate, SYSDATE
        ) RETURNING account_id, account_number INTO p_account_id, p_account_number;
        
        -- Record initial deposit
        IF p_initial_deposit > 0 THEN
            INSERT INTO transactions (
                transaction_id, account_id, transaction_type, amount,
                description, transaction_date
            ) VALUES (
                seq_transaction_id.NEXTVAL, p_account_id, 'DEPOSIT', p_initial_deposit,
                'Initial deposit', SYSTIMESTAMP
            );
        END IF;
        
        p_status := 'SUCCESS';
        p_message := 'Account opened successfully';
        
        COMMIT;
    EXCEPTION
        WHEN gc_invalid_customer THEN
            p_status := 'ERROR';
            p_message := 'Invalid customer ID';
            ROLLBACK;
        WHEN OTHERS THEN
            p_status := 'ERROR';
            p_message := 'Error opening account: ' || SQLERRM;
            ROLLBACK;
    END open_account;
    
    PROCEDURE close_account(
        p_account_id      IN NUMBER,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    ) IS
        v_balance NUMBER(15,2);
    BEGIN
        IF NOT validate_account(p_account_id) THEN
            RAISE gc_invalid_account;
        END IF;
        
        -- Check balance
        SELECT balance INTO v_balance
        FROM accounts
        WHERE account_id = p_account_id
        FOR UPDATE;
        
        IF v_balance != 0 THEN
            p_status := 'ERROR';
            p_message := 'Account balance must be zero to close';
            RETURN;
        END IF;
        
        -- Update account status
        UPDATE accounts
        SET status = 'CLOSED',
            last_activity_date = SYSDATE
        WHERE account_id = p_account_id;
        
        p_status := 'SUCCESS';
        p_message := 'Account closed successfully';
        
        COMMIT;
    EXCEPTION
        WHEN gc_invalid_account THEN
            p_status := 'ERROR';
            p_message := 'Invalid account ID';
            ROLLBACK;
        WHEN OTHERS THEN
            p_status := 'ERROR';
            p_message := 'Error closing account: ' || SQLERRM;
            ROLLBACK;
    END close_account;
    
    -- Transaction Processing Procedures
    PROCEDURE process_transaction(
        p_account_id      IN NUMBER,
        p_transaction_type IN VARCHAR2,
        p_amount          IN NUMBER,
        p_description     IN VARCHAR2 DEFAULT NULL,
        p_reference       IN VARCHAR2 DEFAULT NULL,
        p_transaction_id  OUT NUMBER,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    ) IS
        v_balance NUMBER(15,2);
        v_account_status VARCHAR2(15);
    BEGIN
        IF NOT validate_account(p_account_id) THEN
            RAISE gc_invalid_account;
        END IF;
        
        -- Check account status
        SELECT status INTO v_account_status
        FROM accounts
        WHERE account_id = p_account_id;
        
        IF v_account_status != 'ACTIVE' THEN
            p_status := 'ERROR';
            p_message := 'Account is not active';
            RETURN;
        END IF;
        
        -- For withdrawals, check balance
        IF p_transaction_type = 'WITHDRAWAL' THEN
            SELECT balance INTO v_balance
            FROM accounts
            WHERE account_id = p_account_id
            FOR UPDATE;
            
            IF v_balance < p_amount THEN
                RAISE gc_insufficient_funds;
            END IF;
        END IF;
        
        -- Record transaction
        INSERT INTO transactions (
            transaction_id, account_id, transaction_type, amount,
            description, reference_number, transaction_date
        ) VALUES (
            seq_transaction_id.NEXTVAL, p_account_id, p_transaction_type, p_amount,
            p_description, p_reference, SYSTIMESTAMP
        ) RETURNING transaction_id INTO p_transaction_id;
        
        -- Update account balance (handled by trigger)
        
        p_status := 'SUCCESS';
        p_message := 'Transaction processed successfully';
        
        COMMIT;
    EXCEPTION
        WHEN gc_invalid_account THEN
            p_status := 'ERROR';
            p_message := 'Invalid account ID';
            ROLLBACK;
        WHEN gc_insufficient_funds THEN
            p_status := 'ERROR';
            p_message := 'Insufficient funds';
            ROLLBACK;
        WHEN OTHERS THEN
            p_status := 'ERROR';
            p_message := 'Error processing transaction: ' || SQLERRM;
            ROLLBACK;
    END process_transaction;
    
    PROCEDURE transfer_funds(
        p_from_account    IN NUMBER,
        p_to_account      IN NUMBER,
        p_amount          IN NUMBER,
        p_description     IN VARCHAR2 DEFAULT NULL,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    ) IS
        v_from_balance NUMBER(15,2);
        v_from_status VARCHAR2(15);
        v_to_status VARCHAR2(15);
        v_transaction_id NUMBER;
    BEGIN
        -- Validate both accounts
        IF NOT validate_account(p_from_account) OR NOT validate_account(p_to_account) THEN
            RAISE gc_invalid_account;
        END IF;
        
        -- Check account statuses
        SELECT status INTO v_from_status FROM accounts WHERE account_id = p_from_account;
        SELECT status INTO v_to_status FROM accounts WHERE account_id = p_to_account;
        
        IF v_from_status != 'ACTIVE' OR v_to_status != 'ACTIVE' THEN
            p_status := 'ERROR';
            p_message := 'One or both accounts are not active';
            RETURN;
        END IF;
        
        -- Check balance in from account
        SELECT balance INTO v_from_balance
        FROM accounts
        WHERE account_id = p_from_account
        FOR UPDATE;
        
        IF v_from_balance < p_amount THEN
            RAISE gc_insufficient_funds;
        END IF;
        
        -- Process withdrawal from source account
        process_transaction(
            p_account_id => p_from_account,
            p_transaction_type => 'WITHDRAWAL',
            p_amount => p_amount,
            p_description => p_description || ' (Transfer out)',
            p_status => p_status,
            p_message => p_message
        );
        
        IF p_status != 'SUCCESS' THEN
            ROLLBACK;
            RETURN;
        END IF;
        
        -- Process deposit to target account
        process_transaction(
            p_account_id => p_to_account,
            p_transaction_type => 'DEPOSIT',
            p_amount => p_amount,
            p_description => p_description || ' (Transfer in)',
            p_status => p_status,
            p_message => p_message
        );
        
        IF p_status != 'SUCCESS' THEN
            ROLLBACK;
            -- Reverse the withdrawal if deposit fails
            process_transaction(
                p_account_id => p_from_account,
                p_transaction_type => 'DEPOSIT',
                p_amount => p_amount,
                p_description => 'Transfer reversal',
                p_status => p_status,
                p_message => p_message
            );
            RETURN;
        END IF;
        
        p_status := 'SUCCESS';
        p_message := 'Transfer completed successfully';
        
        COMMIT;
    EXCEPTION
        WHEN gc_invalid_account THEN
            p_status := 'ERROR';
            p_message := 'Invalid account ID';
            ROLLBACK;
        WHEN gc_insufficient_funds THEN
            p_status := 'ERROR';
            p_message := 'Insufficient funds';
            ROLLBACK;
        WHEN OTHERS THEN
            p_status := 'ERROR';
            p_message := 'Error processing transfer: ' || SQLERRM;
            ROLLBACK;
    END transfer_funds;
    
    -- Loan Management Procedures
    PROCEDURE apply_loan(
        p_customer_id     IN NUMBER,
        p_loan_type       IN VARCHAR2,
        p_amount          IN NUMBER,
        p_interest_rate   IN NUMBER,
        p_term_months     IN NUMBER,
        p_loan_id         OUT NUMBER,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    ) IS
        v_account_id NUMBER;
        v_account_number VARCHAR2(20);
    BEGIN
        IF NOT validate_customer(p_customer_id) THEN
            RAISE gc_invalid_customer;
        END IF;
        
        -- First open a loan account
        open_account(
            p_customer_id => p_customer_id,
            p_account_type => 'LOAN',
            p_initial_deposit => 0,
            p_interest_rate => p_interest_rate,
            p_account_id => v_account_id,
            p_account_number => v_account_number,
            p_status => p_status,
            p_message => p_message
        );
        
        IF p_status != 'SUCCESS' THEN
            RETURN;
        END IF;
        
        -- Create loan record
        INSERT INTO loans (
            loan_id, account_id, loan_type, principal_amount,
            interest_rate, term_months, start_date, end_date,
            monthly_payment, remaining_balance
        ) VALUES (
            seq_loan_id.NEXTVAL, v_account_id, p_loan_type, p_amount,
            p_interest_rate, p_term_months, SYSDATE, 
            ADD_MONTHS(SYSDATE, p_term_months),
            ROUND(p_amount * (p_interest_rate/12/100) / 
                 (1 - POWER(1 + (p_interest_rate/12/100), -p_term_months), 2),
            p_amount
        ) RETURNING loan_id INTO p_loan_id;
        
        -- Disburse loan amount (credit to customer's account)
        -- In real scenario, this would go to a specific account
        transfer_funds(
            p_from_account => 999999, -- Bank's internal account
            p_to_account => v_account_id,
            p_amount => p_amount,
            p_description => 'Loan disbursement',
            p_status => p_status,
            p_message => p_message
        );
        
        IF p_status != 'SUCCESS' THEN
            ROLLBACK;
            p_message := 'Loan approved but disbursement failed: ' || p_message;
            RETURN;
        END IF;
        
        p_status := 'SUCCESS';
        p_message := 'Loan approved and disbursed successfully';
        
        COMMIT;
    EXCEPTION
        WHEN gc_invalid_customer THEN
            p_status := 'ERROR';
            p_message := 'Invalid customer ID';
            ROLLBACK;
        WHEN OTHERS THEN
            p_status := 'ERROR';
            p_message := 'Error processing loan: ' || SQLERRM;
            ROLLBACK;
    END apply_loan;
    
    PROCEDURE process_loan_payment(
        p_loan_id         IN NUMBER,
        p_amount          IN NUMBER,
        p_payment_date    IN DATE DEFAULT SYSDATE,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    ) IS
        v_account_id NUMBER;
        v_principal NUMBER(15,2);
        v_interest NUMBER(15,2);
        v_remaining_balance NUMBER(15,2);
    BEGIN
        -- Get loan details
        SELECT account_id, remaining_balance
        INTO v_account_id, v_remaining_balance
        FROM loans
        WHERE loan_id = p_loan_id
        FOR UPDATE;
        
        IF v_remaining_balance <= 0 THEN
            p_status := 'ERROR';
            p_message := 'Loan already paid off';
            RETURN;
        END IF;
        
        -- Calculate interest and principal portions
        SELECT 
            LEAST(p_amount, remaining_balance * (interest_rate/12/100)),
            LEAST(p_amount - LEAST(p_amount, remaining_balance * (interest_rate/12/100)), 
                   remaining_balance)
        INTO v_interest, v_principal
        FROM loans
        WHERE loan_id = p_loan_id;
        
        -- Record payment transaction
        process_transaction(
            p_account_id => v_account_id,
            p_transaction_type => 'PAYMENT',
            p_amount => p_amount,
            p_description => 'Loan payment',
            p_status => p_status,
            p_message => p_message
        );
        
        IF p_status != 'SUCCESS' THEN
            ROLLBACK;
            RETURN;
        END IF;
        
        -- Update loan balance
        UPDATE loans
        SET remaining_balance = remaining_balance - v_principal,
            last_payment_date = p_payment_date
        WHERE loan_id = p_loan_id;
        
        -- Mark as paid if balance is zero
        IF v_remaining_balance - v_principal <= 0 THEN
            UPDATE loans
            SET status = 'PAID',
                end_date = p_payment_date
            WHERE loan_id = p_loan_id;
        END IF;
        
        p_status := 'SUCCESS';
        p_message := 'Loan payment processed successfully';
        
        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_status := 'ERROR';
            p_message := 'Loan not found';
            ROLLBACK;
        WHEN OTHERS THEN
            p_status := 'ERROR';
            p_message := 'Error processing loan payment: ' || SQLERRM;
            ROLLBACK;
    END process_loan_payment;
    
    -- Reporting Procedures
    PROCEDURE get_customer_accounts(
        p_customer_id     IN NUMBER,
        p_account_cursor  OUT SYS_REFCURSOR,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    ) IS
    BEGIN
        IF NOT validate_customer(p_customer_id) THEN
            RAISE gc_invalid_customer;
        END IF;
        
        OPEN p_account_cursor FOR
        SELECT account_id, account_number, account_type, balance, 
               status, open_date, last_activity_date
        FROM accounts
        WHERE customer_id = p_customer_id
        ORDER BY open_date DESC;
        
        p_status := 'SUCCESS';
        p_message := 'Accounts retrieved successfully';
    EXCEPTION
        WHEN gc_invalid_customer THEN
            p_status := 'ERROR';
            p_message := 'Invalid customer ID';
        WHEN OTHERS THEN
            p_status := 'ERROR';
            p_message := 'Error retrieving accounts: ' || SQLERRM;
    END get_customer_accounts;
    
    PROCEDURE get_account_statement(
        p_account_id      IN NUMBER,
        p_start_date      IN DATE DEFAULT NULL,
        p_end_date        IN DATE DEFAULT NULL,
        p_statement_cursor OUT SYS_REFCURSOR,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    ) IS
    BEGIN
        IF NOT validate_account(p_account_id) THEN
            RAISE gc_invalid_account;
        END IF;
        
        OPEN p_statement_cursor FOR
        SELECT transaction_id, transaction_type, amount, 
               transaction_date, description, reference_number, status
        FROM transactions
        WHERE account_id = p_account_id
        AND transaction_date BETWEEN 
            NVL(p_start_date, TO_DATE('2000-01-01', 'YYYY-MM-DD')) AND
            NVL(p_end_date, SYSDATE + 1)
        ORDER BY transaction_date DESC;
        
        p_status := 'SUCCESS';
        p_message := 'Statement retrieved successfully';
    EXCEPTION
        WHEN gc_invalid_account THEN
            p_status := 'ERROR';
            p_message := 'Invalid account ID';
        WHEN OTHERS THEN
            p_status := 'ERROR';
            p_message := 'Error retrieving statement: ' || SQLERRM;
    END get_account_statement;
    
    -- Security Functions
    FUNCTION encrypt_data(p_data IN VARCHAR2) RETURN RAW IS
        v_encrypted_raw RAW(2000);
    BEGIN
        -- Use DBMS_CRYPTO for encryption
        v_encrypted_raw := DBMS_CRYPTO.ENCRYPT(
            src => UTL_I18N.STRING_TO_RAW(p_data, 'AL32UTF8'),
            typ => DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5,
            key => UTL_I18N.STRING_TO_RAW(gc_encryption_key, 'AL32UTF8')
        );
        RETURN v_encrypted_raw;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END encrypt_data;
    
    FUNCTION decrypt_data(p_data IN RAW) RETURN VARCHAR2 IS
        v_decrypted_raw RAW(2000);
    BEGIN
        -- Use DBMS_CRYPTO for decryption
        v_decrypted_raw := DBMS_CRYPTO.DECRYPT(
            src => p_data,
            typ => DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5,
            key => UTL_I18N.STRING_TO_RAW(gc_encryption_key, 'AL32UTF8')
        );
        RETURN UTL_I18N.RAW_TO_CHAR(v_decrypted_raw, 'AL32UTF8');
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END decrypt_data;
    
    -- Bulk Processing Procedure
    PROCEDURE bulk_update_account_balances(
        p_batch_size      IN NUMBER DEFAULT 10000,
        p_status          OUT VARCHAR2,
        p_message         OUT VARCHAR2
    ) IS
        CURSOR c_accounts IS
        SELECT account_id, balance
        FROM accounts
        WHERE last_activity_date < SYSDATE - 30
        ORDER BY account_id;
        
        TYPE t_account_tab IS TABLE OF c_accounts%ROWTYPE;
        v_accounts t_account_tab;
    BEGIN
        OPEN c_accounts;
        LOOP
            FETCH c_accounts BULK COLLECT INTO v_accounts LIMIT p_batch_size;
            EXIT WHEN v_accounts.COUNT = 0;
            
            FORALL i IN 1..v_accounts.COUNT
                UPDATE accounts
                SET balance = balance * (1 + interest_rate/12/100)
                WHERE account_id = v_accounts(i).account_id;
            
            COMMIT;
        END LOOP;
        CLOSE c_accounts;
        
        p_status := 'SUCCESS';
        p_message := 'Bulk update completed successfully';
    EXCEPTION
        WHEN OTHERS THEN
            IF c_accounts%ISOPEN THEN
                CLOSE c_accounts;
            END IF;
            p_status := 'ERROR';
            p_message := 'Error in bulk update: ' || SQLERRM;
            ROLLBACK;
    END bulk_update_account_balances;
    
    -- Utility Functions
    FUNCTION validate_customer(p_customer_id IN NUMBER) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM customers
        WHERE customer_id = p_customer_id;
        
        RETURN v_count = 1;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END validate_customer;
    
    FUNCTION validate_account(p_account_id IN NUMBER) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM accounts
        WHERE account_id = p_account_id;
        
        RETURN v_count = 1;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END validate_account;
    
END PKG_TRANSACTIONS_API;
/