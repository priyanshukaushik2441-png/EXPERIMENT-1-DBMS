-- COMPANY DATABASE - Experiment 1: Understanding DDL and DML Commands
-- Author: (Your Name)
-- ------------------------------------------------------------
-- This script creates the Company database schema (tables, PKs, FKs)
-- and populates it with the sample data provided in the lab images.
--
-- NOTE:
-- 1. The script is written for MySQL-compatible databases. If you are
--    using another RDBMS (e.g. PostgreSQL, Oracle, SQL Server) you may
--    have to make minor syntax adjustments (e.g. AUTO_INCREMENT vs.
--    SERIAL, DATE literals, enabling/disabling FK checks, etc.).
-- 2. There is a circular reference between EMPLOYEE (via Dno) and
--    DEPARTMENT (via Mgr_ssn). To keep the script simple and still
--    preserve referential integrity, we temporarily disable foreign key
--    checks during the data-load phase and re-enable them afterwards.
-- ------------------------------------------------------------

/*------------------------------------------------------------
  0. Create (or switch to) the database schema
  ------------------------------------------------------------*/

DROP DATABASE IF EXISTS company_lab;
CREATE DATABASE company_lab;
USE company_lab;

/*------------------------------------------------------------
  1.  TABLE DEFINITIONS (DDL)
  ------------------------------------------------------------*/

-- 1.1  DEPARTMENT ---------------------------------------------------------
DROP TABLE IF EXISTS DEPARTMENT;
CREATE TABLE DEPARTMENT (
    Dname           VARCHAR(15)  NOT NULL,
    Dnumber         INT          NOT NULL,
    Mgr_ssn         CHAR(9)      NULL,
    Mgr_start_date  DATE,
    CONSTRAINT PK_DEPARTMENT PRIMARY KEY (Dnumber),
    CONSTRAINT UQ_DEPARTMENT_DNAME UNIQUE (Dname)
);

-- 1.2  EMPLOYEE -----------------------------------------------------------
DROP TABLE IF EXISTS EMPLOYEE;
CREATE TABLE EMPLOYEE (
    Fname       VARCHAR(15) NOT NULL,
    Minit       CHAR(1),
    Lname       VARCHAR(15) NOT NULL,
    Ssn         CHAR(9)     NOT NULL,
    Bdate       DATE,
    Address     VARCHAR(30),
    Sex         CHAR(1),
    Salary      DECIMAL(10,2),
    Super_ssn   CHAR(9),
    Dno         INT         NOT NULL,
    CONSTRAINT PK_EMPLOYEE PRIMARY KEY (Ssn),
    CONSTRAINT FK_EMPLOYEE_SUPERSSN  FOREIGN KEY (Super_ssn) REFERENCES EMPLOYEE(Ssn),
    CONSTRAINT FK_EMPLOYEE_DNO       FOREIGN KEY (Dno)       REFERENCES DEPARTMENT(Dnumber)
);

-- 1.3  DEPT_LOCATIONS -----------------------------------------------------
DROP TABLE IF EXISTS DEPT_LOCATIONS;
CREATE TABLE DEPT_LOCATIONS (
    Dnumber   INT         NOT NULL,
    Dlocation VARCHAR(15) NOT NULL,
    CONSTRAINT PK_DEPT_LOCATIONS PRIMARY KEY (Dnumber, Dlocation),
    CONSTRAINT FK_DEPTLOC_DNUM FOREIGN KEY (Dnumber) REFERENCES DEPARTMENT(Dnumber)
);

-- 1.4  PROJECT ------------------------------------------------------------
DROP TABLE IF EXISTS PROJECT;
CREATE TABLE PROJECT (
    Pname     VARCHAR(15) NOT NULL,
    Pnumber   INT         NOT NULL,
    Plocation VARCHAR(15),
    Dnum      INT         NOT NULL,
    CONSTRAINT PK_PROJECT PRIMARY KEY (Pnumber),
    CONSTRAINT UQ_PROJECT_PNAME UNIQUE (Pname),
    CONSTRAINT FK_PROJECT_DNUM FOREIGN KEY (Dnum) REFERENCES DEPARTMENT(Dnumber)
);

-- 1.5  WORKS_ON -----------------------------------------------------------
DROP TABLE IF EXISTS WORKS_ON;
CREATE TABLE WORKS_ON (
    Essn   CHAR(9)      NOT NULL,
    Pno    INT          NOT NULL,
    Hours  DECIMAL(4,1) NOT NULL,
    CONSTRAINT PK_WORKS_ON PRIMARY KEY (Essn, Pno),
    CONSTRAINT FK_WORKS_EMP  FOREIGN KEY (Essn) REFERENCES EMPLOYEE(Ssn),
    CONSTRAINT FK_WORKS_PROJ FOREIGN KEY (Pno)  REFERENCES PROJECT(Pnumber)
);

-- 1.6  DEPENDENT ----------------------------------------------------------
DROP TABLE IF EXISTS DEPENDENT;
CREATE TABLE DEPENDENT (
    Essn            CHAR(9)     NOT NULL,
    Dependent_name  VARCHAR(15) NOT NULL,
    Sex             CHAR(1),
    Bdate           DATE,
    Relationship    VARCHAR(8),
    CONSTRAINT PK_DEPENDENT PRIMARY KEY (Essn, Dependent_name),
    CONSTRAINT FK_DEPENDENT_ESSN FOREIGN KEY (Essn) REFERENCES EMPLOYEE(Ssn)
);

/*------------------------------------------------------------
  2.  POPULATE TABLES (DML)
  ------------------------------------------------------------*/

-- Disable FK checks during the bulk-load phase to work around
-- the DEPARTMENT ↔ EMPLOYEE circular reference.
SET FOREIGN_KEY_CHECKS = 0;

-- 2.1  Insert departments --------------------------------------------------
INSERT INTO DEPARTMENT (Dname, Dnumber, Mgr_ssn, Mgr_start_date) VALUES
    ('Research',        5,  '333445555', '1988-05-22'),
    ('Administration',  4,  '987654321', '1995-01-01'),
    ('Headquarters',    1,  '888665555', '1981-06-19');

-- 2.2  Insert employees ----------------------------------------------------
INSERT INTO EMPLOYEE (Fname, Minit, Lname, Ssn, Bdate, Address, Sex, Salary, Super_ssn, Dno) VALUES
    ('John',      'B', 'Smith',    '123456789', '1965-01-09', '731 Fondren, Houston TX',     'M', 30000, '333445555', 5),
    ('Franklin',  'T', 'Wong',     '333445555', '1965-12-08', '638 Voss, Houston TX',        'M', 40000, '888665555', 5),
    ('Alicia',    'J', 'Zelaya',   '999887777', '1968-01-19', '3321 Castle, Spring TX',      'F', 25000, '987654321', 4),
    ('Jennifer',  'S', 'Wallace',  '987654321', '1941-06-20', '291 Berry, Bellaire TX',      'F', 43000, '888665555', 4),
    ('Ramesh',    'K', 'Narayan',  '666884444', '1962-09-15', '975 Fire Oak, Humble TX',     'M', 38000, '333445555', 5),
    ('Joyce',     'A', 'English',  '453453453', '1972-07-31', '5631 Rice, Houston TX',       'F', 25000, '333445555', 5),
    ('Ahmad',     'V', 'Jabbar',   '987987987', '1969-03-29', '980 Dallas, Houston TX',      'M', 25000, '987654321', 4),
    ('James',     'E', 'Borg',     '888665555', '1937-11-10', '450 Stone, Houston TX',       'M', 55000, NULL,        1);

-- 2.3  Insert department locations ---------------------------------------
INSERT INTO DEPT_LOCATIONS (Dnumber, Dlocation) VALUES
    (1, 'Houston'),
    (4, 'Stafford'),
    (5, 'Bellaire'),
    (5, 'Houston'),
    (5, 'Sugarland');

-- 2.4  Insert projects -----------------------------------------------------
INSERT INTO PROJECT (Pname, Pnumber, Plocation, Dnum) VALUES
    ('ProductX',        1,  'Bellaire', 5),
    ('ProductY',        2,  'Sugarland',5),
    ('ProductZ',        3,  'Houston',  5),
    ('Computerization',10,  'Stafford', 4),
    ('Reorganization', 20,  'Houston',  1),
    ('Newbenefits',     30, 'Stafford', 4);

-- 2.5  Insert work assignments (WORKS_ON) --------------------------------
INSERT INTO WORKS_ON (Essn, Pno, Hours) VALUES
    ('123456789', 1, 32.5),
    ('123456789', 2,  7.5),
    ('666884444', 3, 40.0),
    ('453453453', 1, 20.0),
    ('453453453', 2, 20.0),
    ('333445555', 2, 10.0),
    ('333445555', 3, 10.0),
    ('333445555',10, 10.0),
    ('333445555',20, 10.0),
    ('999887777',30, 30.0),
    ('999887777',10, 10.0),
    ('987987987',10, 35.0),
    ('987987987',30,  5.0),
    ('987654321',30, 20.0),
    ('987654321',20, 15.0);

--  NOTE: original data shows an entry ('888665555', 20, NULL).  Since the
--  Hours column is NOT NULL, that row has been omitted to satisfy the
--  integrity constraint.

-- 2.6  Insert dependents ---------------------------------------------------
INSERT INTO DEPENDENT (Essn, Dependent_name, Sex, Bdate, Relationship) VALUES
    ('333445555', 'Alice',      'F', '1986-04-04', 'Daughter'),
    ('333445555', 'Theodore',   'M', '1983-10-25', 'Son'),
    ('333445555', 'Joy',        'F', '1958-05-03', 'Spouse'),
    ('987654321', 'Abner',      'M', '1942-02-28', 'Spouse'),
    ('123456789', 'Michael',    'M', '1988-01-04', 'Son'),
    ('123456789', 'Alice',      'F', '1988-12-30', 'Daughter'),
    ('123456789', 'Elizabeth',  'F', '1967-05-05', 'Spouse');

-- Re-enable FK checks once all data has been loaded.
SET FOREIGN_KEY_CHECKS = 1;

/*------------------------------------------------------------
  3.  OPTIONAL: ADD the missing DEPARTMENT → EMPLOYEE FK now
  ------------------------------------------------------------
  We can now safely add the foreign key constraint on DEPARTMENT.Mgr_ssn
  because all referenced EMPLOYEE rows are present.
-------------------------------------------------------------*/
ALTER TABLE DEPARTMENT
    ADD CONSTRAINT FK_DEPT_MGR FOREIGN KEY (Mgr_ssn) REFERENCES EMPLOYEE(Ssn);

-- End of script ----------------------------------------------------------