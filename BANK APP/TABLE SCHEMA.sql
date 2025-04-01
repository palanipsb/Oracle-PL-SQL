CREATE TABLE customers (
    customer_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR2(100) UNIQUE,
    phone VARCHAR2(20) UNIQUE,
    address VARCHAR2(200),
    city VARCHAR2(50),
    state VARCHAR2(50),
    zip_code VARCHAR2(20),
    ssn VARCHAR2(20) UNIQUE,
    date_created DATE DEFAULT SYSDATE,
    last_updated DATE
);

CREATE TABLE accounts (
    account_id NUMBER PRIMARY KEY,
    customer_id NUMBER NOT NULL,
    account_type VARCHAR2(20) NOT NULL CHECK (account_type IN ('SAVINGS', 'CHECKING', 'LOAN', 'CREDIT')),
    account_number VARCHAR2(20) UNIQUE NOT NULL,
    balance NUMBER(15,2) DEFAULT 0,
    open_date DATE DEFAULT SYSDATE,
    status VARCHAR2(15) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'CLOSED', 'FROZEN')),
    interest_rate NUMBER(5,2),
    last_activity_date DATE,
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE transactions (
    transaction_id NUMBER PRIMARY KEY,
    account_id NUMBER NOT NULL,
    transaction_type VARCHAR2(20) NOT NULL CHECK (transaction_type IN ('DEPOSIT', 'WITHDRAWAL', 'TRANSFER', 'PAYMENT')),
    amount NUMBER(15,2) NOT NULL,
    transaction_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    description VARCHAR2(200),
    reference_number VARCHAR2(50),
    status VARCHAR2(15) DEFAULT 'COMPLETED' CHECK (status IN ('COMPLETED', 'PENDING', 'FAILED', 'REVERSED')),
    CONSTRAINT fk_account FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

CREATE TABLE loans (
    loan_id NUMBER PRIMARY KEY,
    account_id NUMBER NOT NULL,
    loan_type VARCHAR2(30) NOT NULL CHECK (loan_type IN ('PERSONAL', 'MORTGAGE', 'AUTO', 'BUSINESS')),
    principal_amount NUMBER(15,2) NOT NULL,
    interest_rate NUMBER(5,2) NOT NULL,
    term_months NUMBER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    monthly_payment NUMBER(15,2),
    remaining_balance NUMBER(15,2),
    status VARCHAR2(15) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'PAID', 'DEFAULTED')),
    CONSTRAINT fk_loan_account FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

CREATE TABLE cards (
    card_id NUMBER PRIMARY KEY,
    account_id NUMBER NOT NULL,
    card_number VARCHAR2(20) UNIQUE NOT NULL,
    card_type VARCHAR2(20) NOT NULL CHECK (card_type IN ('DEBIT', 'CREDIT')),
    expiry_date DATE NOT NULL,
    cvv VARCHAR2(5) NOT NULL,
    issue_date DATE DEFAULT SYSDATE,
    status VARCHAR2(15) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'BLOCKED', 'EXPIRED', 'LOST')),
    daily_limit NUMBER(15,2),
    CONSTRAINT fk_card_account FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

CREATE TABLE branches (
    branch_id NUMBER PRIMARY KEY,
    branch_name VARCHAR2(100) NOT NULL,
    address VARCHAR2(200) NOT NULL,
    city VARCHAR2(50) NOT NULL,
    state VARCHAR2(50) NOT NULL,
    zip_code VARCHAR2(20) NOT NULL,
    phone VARCHAR2(20) NOT NULL,
    manager_id NUMBER
);

CREATE TABLE employees (
    employee_id NUMBER PRIMARY KEY,
    branch_id NUMBER NOT NULL,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    position VARCHAR2(50) NOT NULL,
    hire_date DATE NOT NULL,
    salary NUMBER(15,2),
    email VARCHAR2(100) UNIQUE,
    phone VARCHAR2(20) UNIQUE,
    CONSTRAINT fk_branch FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

CREATE TABLE audit_log (
    log_id NUMBER PRIMARY KEY,
    table_name VARCHAR2(50) NOT NULL,
    record_id NUMBER NOT NULL,
    action VARCHAR2(10) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    action_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    user_id VARCHAR2(50) NOT NULL,
    old_value CLOB,
    new_value CLOB
);

-- Customer sequence
CREATE SEQUENCE seq_customer_id
START WITH 1000
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Account sequence
CREATE SEQUENCE seq_account_id
START WITH 50000
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Transaction sequence
CREATE SEQUENCE seq_transaction_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Loan sequence
CREATE SEQUENCE seq_loan_id
START WITH 100
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Card sequence
CREATE SEQUENCE seq_card_id
START WITH 10000
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Branch sequence
CREATE SEQUENCE seq_branch_id
START WITH 10
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Employee sequence
CREATE SEQUENCE seq_employee_id
START WITH 1000
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Audit log sequence
CREATE SEQUENCE seq_audit_log_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;