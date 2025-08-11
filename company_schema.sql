-- COMPANY database DDL + DML
-- Compatible with PostgreSQL and MySQL (minor type differences tolerated)

-- Drop in dependency order
DROP TABLE IF EXISTS WORKS_ON;
DROP TABLE IF EXISTS DEPENDENT;
DROP TABLE IF EXISTS PROJECT;
DROP TABLE IF EXISTS DEPT_LOCATIONS;
DROP TABLE IF EXISTS DEPARTMENT;
DROP TABLE IF EXISTS EMPLOYEE;

-- =============================
-- Tables
-- =============================

-- EMPLOYEE first, without FK on Dno to avoid circular dependency initially
CREATE TABLE EMPLOYEE (
  Fname        VARCHAR(15) NOT NULL,
  Minit        CHAR(1),
  Lname        VARCHAR(15) NOT NULL,
  Ssn          CHAR(9)     NOT NULL,
  Bdate        DATE,
  Address      VARCHAR(30),
  Sex          CHAR(1),
  Salary       DECIMAL(10,2),
  Super_ssn    CHAR(9),
  Dno          INT NOT NULL,
  PRIMARY KEY (Ssn),
  CONSTRAINT fk_employee_super
    FOREIGN KEY (Super_ssn) REFERENCES EMPLOYEE(Ssn)
);

-- Insert employees (note: Dno will be validated after departments are created)
INSERT INTO EMPLOYEE (Fname, Minit, Lname, Ssn, Bdate, Address, Sex, Salary, Super_ssn, Dno) VALUES
  ('John',     'B', 'Smith',   '123456789', DATE '1965-01-09', '731 Fondren, Houston TX', 'M', 30000, '333445555', 5),
  ('Franklin', 'T', 'Wong',    '333445555', DATE '1965-12-08', '638 Voss, Houston TX',    'M', 40000, '888665555', 5),
  ('Alicia',   'J', 'Zelaya',  '999887777', DATE '1968-01-19', '3321 Castle, Spring TX',  'F', 25000, '987654321', 4),
  ('Jennifer', 'S', 'Wallace', '987654321', DATE '1941-06-20', '291 Berry, Bellaire TX',  'F', 43000, '888665555', 4),
  ('Ramesh',   'K', 'Narayan', '666884444', DATE '1962-09-15', '975 Fire Oak, Humble TX', 'M', 38000, '333445555', 5),
  ('Joyce',    'A', 'English', '453453453', DATE '1972-07-31', '5631 Rice, Houston TX',   'F', 25000, '333445555', 5),
  ('Ahmad',    'V', 'Jabbar',  '987987987', DATE '1969-03-29', '980 Dallas, Houston TX',  'M', 25000, '987654321', 4),
  ('James',    'E', 'Borg',    '888665555', DATE '1937-11-10', '450 Stone, Houston TX',   'M', 55000, NULL,        1);

-- DEPARTMENT references EMPLOYEE (Mgr_ssn)
CREATE TABLE DEPARTMENT (
  Dname          VARCHAR(15) NOT NULL,
  Dnumber        INT         NOT NULL,
  Mgr_ssn        CHAR(9)     NOT NULL,
  Mgr_start_date DATE,
  PRIMARY KEY (Dnumber),
  UNIQUE (Dname),
  CONSTRAINT fk_dept_mgr
    FOREIGN KEY (Mgr_ssn) REFERENCES EMPLOYEE(Ssn)
);

INSERT INTO DEPARTMENT (Dname, Dnumber, Mgr_ssn, Mgr_start_date) VALUES
  ('Research',        5, '333445555', DATE '1988-05-22'),
  ('Administration',  4, '987654321', DATE '1995-01-01'),
  ('Headquarters',    1, '888665555', DATE '1981-06-19');

-- Now that DEPARTMENT exists, add the FK from EMPLOYEE.Dno to DEPARTMENT.Dnumber
ALTER TABLE EMPLOYEE
  ADD CONSTRAINT fk_employee_dno
  FOREIGN KEY (Dno) REFERENCES DEPARTMENT(Dnumber);

-- DEPT_LOCATIONS
CREATE TABLE DEPT_LOCATIONS (
  Dnumber   INT         NOT NULL,
  Dlocation VARCHAR(15) NOT NULL,
  PRIMARY KEY (Dnumber, Dlocation),
  CONSTRAINT fk_dept_locations_dept
    FOREIGN KEY (Dnumber) REFERENCES DEPARTMENT(Dnumber)
);

INSERT INTO DEPT_LOCATIONS (Dnumber, Dlocation) VALUES
  (1, 'Houston'),
  (4, 'Stafford'),
  (5, 'Bellaire'),
  (5, 'Houston'),
  (5, 'Sugarland');

-- PROJECT
CREATE TABLE PROJECT (
  Pname   VARCHAR(15) NOT NULL,
  Pnumber INT         NOT NULL,
  Plocation VARCHAR(15),
  Dnum    INT         NOT NULL,
  PRIMARY KEY (Pnumber),
  UNIQUE (Pname),
  CONSTRAINT fk_project_dept
    FOREIGN KEY (Dnum) REFERENCES DEPARTMENT(Dnumber)
);

INSERT INTO PROJECT (Pname, Pnumber, Plocation, Dnum) VALUES
  ('ProductX',        1,  'Bellaire', 5),
  ('ProductY',        2,  'Sugarland',5),
  ('ProductZ',        3,  'Houston',  5),
  ('Computerization', 10, 'Stafford', 4),
  ('Reorganization',  20, 'Houston',  1),
  ('Newbenefits',     30, 'Stafford', 4);

-- WORKS_ON
CREATE TABLE WORKS_ON (
  Essn  CHAR(9) NOT NULL,
  Pno   INT     NOT NULL,
  Hours DECIMAL(3,1) NOT NULL,
  PRIMARY KEY (Essn, Pno),
  CONSTRAINT fk_works_on_emp
    FOREIGN KEY (Essn) REFERENCES EMPLOYEE(Ssn),
  CONSTRAINT fk_works_on_project
    FOREIGN KEY (Pno) REFERENCES PROJECT(Pnumber)
);

INSERT INTO WORKS_ON (Essn, Pno, Hours) VALUES
  ('123456789', 1, 32.5),
  ('123456789', 2,  7.5),
  ('333445555', 2, 10.0),
  ('333445555', 3, 10.0),
  ('333445555',10, 10.0),
  ('333445555',20, 10.0),
  ('999887777',30, 30.0),
  ('999887777',10, 10.0),
  ('987987987',10, 35.0),
  ('987987987',30,  5.0),
  ('987654321',30, 20.0),
  ('987654321',20, 15.0),
  ('666884444', 3, 40.0),
  ('453453453', 1, 20.0),
  ('453453453', 2, 20.0);

-- DEPENDENT
CREATE TABLE DEPENDENT (
  Essn           CHAR(9)     NOT NULL,
  Dependent_name VARCHAR(15) NOT NULL,
  Sex            CHAR(1),
  Bdate          DATE,
  Relationship   VARCHAR(8),
  PRIMARY KEY (Essn, Dependent_name),
  CONSTRAINT fk_dependent_emp
    FOREIGN KEY (Essn) REFERENCES EMPLOYEE(Ssn)
);

INSERT INTO DEPENDENT (Essn, Dependent_name, Sex, Bdate, Relationship) VALUES
  ('123456789', 'Alice',    'F', DATE '1988-12-30', 'Daughter'),
  ('123456789', 'Elizabeth','F', DATE '1967-05-05', 'Spouse'),
  ('333445555', 'Alice',    'F', DATE '1986-04-04', 'Daughter'),
  ('333445555', 'Theodore', 'M', DATE '1983-10-25', 'Son'),
  ('333445555', 'Joy',      'F', DATE '1958-05-03', 'Spouse'),
  ('987654321', 'Abner',    'M', DATE '1942-02-28', 'Spouse');

-- =============================
-- Simple checks (optional)
-- =============================
-- SELECT * FROM EMPLOYEE;
-- SELECT * FROM DEPARTMENT;
-- SELECT * FROM PROJECT;
-- SELECT * FROM WORKS_ON;
-- SELECT * FROM DEPENDENT;
-- SELECT * FROM DEPT_LOCATIONS;