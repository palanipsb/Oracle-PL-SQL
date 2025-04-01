-- Insert sample branch
INSERT INTO branches (branch_id, branch_name, address, city, state, zip_code, phone)
VALUES (seq_branch_id.NEXTVAL, 'City Bank Main Branch', '123 Financial Street', 'New York', 'NY', '10001', '212-555-1000');

-- Insert sample employee
INSERT INTO employees (employee_id, branch_id, first_name, last_name, position, hire_date, salary, email, phone)
VALUES (seq_employee_id.NEXTVAL, 10, 'John', 'Smith', 'Branch Manager', TO_DATE('2020-01-15', 'YYYY-MM-DD'), 85000, 'john.smith@citybank.com', '212-555-1001');

-- Insert sample customer
INSERT INTO customers (customer_id, first_name, last_name, date_of_birth, email, phone, address, city, state, zip_code, ssn)
VALUES (seq_customer_id.NEXTVAL, 'Alice', 'Johnson', TO_DATE('1985-05-20', 'YYYY-MM-DD'), 'alice.johnson@email.com', '212-555-1234', '456 Park Ave', 'New York', 'NY', '10022', '123-45-6789');

-- Insert sample account
INSERT INTO accounts (account_id, customer_id, account_type, account_number, balance, interest_rate)
VALUES (seq_account_id.NEXTVAL, 1000, 'SAVINGS', NULL, 5000.00, 1.5);

-- Insert sample transaction
INSERT INTO transactions (transaction_id, account_id, transaction_type, amount, description)
VALUES (seq_transaction_id.NEXTVAL, 50000, 'DEPOSIT', 1000.00, 'Initial deposit');