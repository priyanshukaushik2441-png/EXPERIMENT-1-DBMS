-- Exp.1 To understand DDL and DML Command
-- Company Database Schema Creation and Data Insertion

-- Drop tables if they exist (in reverse order due to foreign key constraints)
DROP TABLE IF EXISTS DEPENDENT;
DROP TABLE IF EXISTS WORKS_ON;
DROP TABLE IF EXISTS PROJECT;
DROP TABLE IF EXISTS DEPT_LOCATIONS;
DROP TABLE IF EXISTS EMPLOYEE;
DROP TABLE IF EXISTS DEPARTMENT;

-- Create DEPARTMENT table first (referenced by other tables)
CREATE TABLE DEPARTMENT (
    Dname VARCHAR(15) NOT NULL,
    Dnumber INT NOT NULL,
    Mgr_ssn CHAR(9) NOT NULL,
    Mgr_start_date DATE,
    PRIMARY KEY (Dnumber),
    UNIQUE (Dname)
);

-- Create EMPLOYEE table
CREATE TABLE EMPLOYEE (
    Fname VARCHAR(15) NOT NULL,
    Minit CHAR,
    Lname VARCHAR(15) NOT NULL,
    Ssn CHAR(9) NOT NULL,
    Bdate DATE,
    Address VARCHAR(30),
    Sex CHAR,
    Salary DECIMAL(10,2),
    Super_ssn CHAR(9),
    Dno INT NOT NULL,
    PRIMARY KEY (Ssn),
    FOREIGN KEY (Super_ssn) REFERENCES EMPLOYEE(Ssn),
    FOREIGN KEY (Dno) REFERENCES DEPARTMENT(Dnumber)
);

-- Add foreign key constraint to DEPARTMENT table (referencing EMPLOYEE)
ALTER TABLE DEPARTMENT 
ADD CONSTRAINT FK_DEPT_MGR 
FOREIGN KEY (Mgr_ssn) REFERENCES EMPLOYEE(Ssn);

-- Create DEPT_LOCATIONS table
CREATE TABLE DEPT_LOCATIONS (
    Dnumber INT NOT NULL,
    Dlocation VARCHAR(15) NOT NULL,
    PRIMARY KEY (Dnumber, Dlocation),
    FOREIGN KEY (Dnumber) REFERENCES DEPARTMENT(Dnumber)
);

-- Create PROJECT table
CREATE TABLE PROJECT (
    Pname VARCHAR(15) NOT NULL,
    Pnumber INT NOT NULL,
    Plocation VARCHAR(15),
    Dnum INT NOT NULL,
    PRIMARY KEY (Pnumber),
    UNIQUE (Pname),
    FOREIGN KEY (Dnum) REFERENCES DEPARTMENT(Dnumber)
);

-- Create WORKS_ON table
CREATE TABLE WORKS_ON (
    Essn CHAR(9) NOT NULL,
    Pno INT NOT NULL,
    Hours DECIMAL(3,1) NOT NULL,
    PRIMARY KEY (Essn, Pno),
    FOREIGN KEY (Essn) REFERENCES EMPLOYEE(Ssn),
    FOREIGN KEY (Pno) REFERENCES PROJECT(Pnumber)
);

-- Create DEPENDENT table
CREATE TABLE DEPENDENT (
    Essn CHAR(9) NOT NULL,
    Dependent_name VARCHAR(15) NOT NULL,
    Sex CHAR,
    Bdate DATE,
    Relationship VARCHAR(8),
    PRIMARY KEY (Essn, Dependent_name),
    FOREIGN KEY (Essn) REFERENCES EMPLOYEE(Ssn)
);

-- Insert data into DEPARTMENT table
INSERT INTO DEPARTMENT (Dname, Dnumber, Mgr_ssn, Mgr_start_date) VALUES
('Research', 5, '333445555', '1988-05-22'),
('Administration', 4, '987654321', '1995-01-01'),
('Headquarters', 1, '888665555', '1981-06-19');

-- Insert data into EMPLOYEE table
INSERT INTO EMPLOYEE (Fname, Minit, Lname, Ssn, Bdate, Address, Sex, Salary, Super_ssn, Dno) VALUES
('John', NULL, 'Smith', '123456789', '1965-01-09', '731 Fondren, Houston TX', 'M', 30000, '333445555', 5),
('Franklin', NULL, 'Wong', '333445555', '1965-12-08', '638 Voss, Houston TX', 'M', 40000, '888665555', 5),
('Alicia', NULL, 'Zelaya', '999887777', '1968-01-19', '3321 Castle, Spring TX', 'F', 25000, '987654321', 4),
('Jennifer', NULL, 'Wallace', '987654321', '1941-06-20', '291 Berry, Bellaire TX', 'F', 43000, '888665555', 4),
('Ramesh', NULL, 'Narayan', '666884444', '1962-09-15', '975 Fire Oak, Humble TX', 'M', 38000, '333445555', 5),
('Joyce', NULL, 'English', '453453453', '1972-07-31', '5631 Rice, Houston TX', 'F', 25000, '333445555', 5),
('Ahmad', NULL, 'Jabbar', '987987987', '1969-03-29', '980 Dallas, Houston TX', 'M', 25000, '987654321', 4),
('James', NULL, 'Borg', '888665555', '1937-11-10', '450 Stone, Houston TX', 'M', 55000, NULL, 1);

-- Insert data into PROJECT table
INSERT INTO PROJECT (Pname, Pnumber, Plocation, Dnum) VALUES
('ProductX', 1, 'Bellaire', 5),
('ProductY', 2, 'Sugarland', 5),
('ProductZ', 3, 'Houston', 5),
('Computerization', 10, 'Stafford', 4),
('Reorganization', 20, 'Houston', 1),
('Newbenefits', 30, 'Stafford', 4);

-- Insert data into WORKS_ON table
INSERT INTO WORKS_ON (Essn, Pno, Hours) VALUES
('123456789', 1, 32.5),
('123456789', 2, 7.5),
('666884444', 3, 40.0),
('453453453', 1, 20.0),
('453453453', 2, 20.0),
('333445555', 2, 10.0),
('333445555', 3, 10.0),
('333445555', 10, 10.0),
('333445555', 20, 10.0),
('999887777', 30, 30.0),
('999887777', 10, 10.0),
('987987987', 10, 35.0),
('987987987', 30, 5.0),
('987654321', 30, 20.0),
('987654321', 20, 15.0),
('888665555', 20, NULL);

-- Insert data into DEPENDENT table
INSERT INTO DEPENDENT (Essn, Dependent_name, Sex, Bdate, Relationship) VALUES
('333445555', 'Alice', 'F', '1986-04-04', 'Daughter'),
('333445555', 'Theodore', 'M', '1983-10-25', 'Son'),
('333445555', 'Joy', 'F', '1958-05-03', 'Spouse'),
('987654321', 'Abner', 'M', '1942-02-28', 'Spouse'),
('123456789', 'Michael', 'M', '1988-01-04', 'Son'),
('123456789', 'Alice', 'F', '1988-12-30', 'Daughter'),
('123456789', 'Elizabeth', 'F', '1967-05-05', 'Spouse');

-- Insert data into DEPT_LOCATIONS table
INSERT INTO DEPT_LOCATIONS (Dnumber, Dlocation) VALUES
(1, 'Houston'),
(4, 'Stafford'),
(5, 'Bellaire'),
(5, 'Houston'),
(5, 'Sugarland');

-- Display all tables to verify the data
SELECT 'DEPARTMENT TABLE:' as TableName;
SELECT * FROM DEPARTMENT;

SELECT 'EMPLOYEE TABLE:' as TableName;
SELECT * FROM EMPLOYEE;

SELECT 'PROJECT TABLE:' as TableName;
SELECT * FROM PROJECT;

SELECT 'WORKS_ON TABLE:' as TableName;
SELECT * FROM WORKS_ON;

SELECT 'DEPENDENT TABLE:' as TableName;
SELECT * FROM DEPENDENT;

SELECT 'DEPT_LOCATIONS TABLE:' as TableName;
SELECT * FROM DEPT_LOCATIONS;