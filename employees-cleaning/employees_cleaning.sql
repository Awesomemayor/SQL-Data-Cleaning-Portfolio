-- ========================================
-- EMPLOYEE DATA CLEANING PROJECT
-- ========================================
-- Author: Mayowa Adejumo
-- Date: January 2026
-- Dataset: Employee Records (13 rows)
-- 
-- Objective: Clean employee data with inconsistent formatting
-- Problems addressed:
-- - Duplicate records
-- - Extra spaces in names
-- - Inconsistent salary formats ($75,000 vs 65000)
-- - Missing email domains
-- - Mixed date formats
-- - Department case inconsistencies
-- - NULL manager assignments
-- ========================================

DROP TABLE IF EXISTS employees_dirty;
CREATE TABLE employees_dirty (
    emp_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    department VARCHAR(50),
    salary VARCHAR(20),
    hire_date VARCHAR(20),
    manager VARCHAR(100)
);

INSERT INTO employees_dirty VALUES
(1, 'John', 'Smith', 'john.smith@company.com', 'Sales', '$75,000', '01/15/2023', 'Sarah Johnson'),
(2, ' Jane', 'Doe', 'jane.doe@company', 'Marketing', '65000', '02/20/2023', 'Mike Davis'),
(3, 'Bob', 'Wilson ', 'bob.wilson@company.com', 'IT', '$85,000.00', '03/10/2023', NULL),
(1, 'John', 'Smith', 'john.smith@company.com', 'Sales', '$75,000', '01/15/2023', 'Sarah Johnson'),
(4, 'Alice', 'Brown', 'alice.brown@company.com', 'HR', '70000', '04/05/2023', 'Lisa White'),
(5, 'Charlie', 'Lee', 'charlie.lee@company.com', 'IT', '$90,000', '05/12/2023', NULL),
(6, 'Diana', 'Ross', 'diana.ross@company.com', 'sales', '78,000', '06/18/2023', 'Sarah Johnson'),
(7, 'Eve', 'Adams', 'eve.adams@company', 'Marketing', '$72000', '7/22/23', 'Mike Davis'),
(8, 'Frank', 'Miller', NULL, NULL, NULL, '08/30/2023', NULL),
(9, 'Grace', 'Hill', 'grace.hill@company.com', 'Finance', '95,000', '09/14/2023', 'Tom Wilson'),
(10, 'Henry', 'Ford', 'henry.ford@company.com', 'IT', '$88,000', '10/05/2023', 'David Chen'),
(11, 'Ivy', 'Chen', 'ivy.chen@company.com', 'Sales', '76000', '11/20/2023', 'Sarah Johnson'),
(12, 'Jack', 'Black', 'jack.black@company.com', 'IT ', '$92,000', '12/08/2023', NULL);


SELECT * 
FROM employees_dirty;

-- TASK 1 - CREATING A STAGING TABLE 

-- 1a. CREATE A STAGING TABLE
DROP TABLE if exists employees_dirty2;
CREATE TABLE employees_dirty2
LIKE employees_dirty;

-- 1b. INSERT DATA INTO THE STAGING TABLE
INSERT INTO employees_dirty2
SELECT *
FROM employees_dirty;

SELECT * 
FROM employees_dirty2;

-- TASK 2 - REMOVING DUPLICATES

-- 2a. IDENTIFY DUPLICATES WITH ROW_NUMBER
SELECT *, ROW_NUMBER () OVER (PARTITION BY emp_id, first_name, last_name, email, department, salary, hire_date, manager) AS row_num
FROM employees_dirty2;

-- 2b. CREATE AN ALTERNATIVE TABLE TO DELETE DUPLICATES

DROP TABLE if exists employees_dirty3;
CREATE TABLE `employees_dirty3` (
  `emp_id` int DEFAULT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `department` varchar(50) DEFAULT NULL,
  `salary` varchar(20) DEFAULT NULL,
  `hire_date` varchar(20) DEFAULT NULL,
  `manager` varchar(100) DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO employees_dirty3
SELECT *, ROW_NUMBER () OVER (PARTITION BY emp_id, first_name, last_name, email, department, salary, hire_date, manager)
FROM employees_dirty2;

SELECT *
FROM employees_dirty3
WHERE row_num > 1;

-- 2c. DELETE DUPLICATES
DELETE
FROM employees_dirty3
WHERE row_num > 1;

-- TASK 3 - STANDARDIZING THE DATA

-- TRIM FIRST_NAME
SELECT first_name, TRIM(first_name)
FROM employees_dirty3;

UPDATE employees_dirty3
SET first_name = TRIM(first_name);

-- TRIM LAST NAME
SELECT last_name, TRIM(last_name)
FROM employees_dirty3;

UPDATE employees_dirty3
SET last_name = TRIM(last_name);

-- 5. TRIM DEPARTMENT
SELECT department, TRIM(department)
FROM employees_dirty3;

UPDATE employees_dirty3
SET department = TRIM(department);

-- TASK 4 - UNIFYING DATA

-- 6. UNIFY DEPARTMENT LABELS
SELECT DISTINCT department
FROM employees_dirty3;

UPDATE employees_dirty3
SET department = 'Sales'
WHERE department = 'sales';

-- TASK 5 -- STANDARDIZING THE DATA
-- 7. DATE FORMAT 
UPDATE employees_dirty3
SET `hire_date` = STR_TO_DATE(`hire_date`, '%m/%d/%Y');

ALTER TABLE employees_dirty3
MODIFY COLUMN hire_date DATE;

-- 8. SALARY
UPDATE employees_dirty3
SET salary = REPLACE(REPLACE(salary, '$', ''), ',', '');

-- Step 2: Convert to decimal
ALTER TABLE employees_dirty3
MODIFY COLUMN salary DECIMAL(10);

-- 9. EMAIL
UPDATE employees_dirty3
SET email = CONCAT(email, '.com')
WHERE email NOT LIKE '%.com';

SELECT * FROM employees_dirty3;

-- TASK 6 - REMOVING UNNECESSARY DATA 
-- 10 - REMOVE UNNECESSARY ROW
DELETE
FROM employees_dirty3
WHERE email IS NULL AND department IS NULL AND SALARY IS NULL;

-- 11. REMOVING ROW_NUM COLUMN
ALTER TABLE employees_dirty3
DROP COLUMN row_num;

-- TASK 7 - POPULATING NULLS 
-- 12. NULLS UNDER MANAGER COLUMN
SELECT *
FROM employees_dirty3
WHERE manager IS NULL;

SELECT *
FROM employees_dirty3 ed1
JOIN employees_dirty3 ed2
ON ed1.department = ed2.department
WHERE ed1.manager IS NULL AND ed2.manager IS NOT NULL;

UPDATE employees_dirty3 ed1
JOIN employees_dirty3 ed2
ON ed1.department = ed2.department
SET ed1.manager = ed2.manager
WHERE ed1.manager IS NULL AND ed2.manager IS NOT NULL;


SELECT * FROM employees_dirty3;


-- ========================================
-- CLEANING COMPLETE
-- ========================================
-- Original rows: 13
-- Duplicates removed: 1
-- Unusable rows removed: 1
-- Final clean rows: 11
-- 
-- Key changes:
-- - Removed duplicate employee (emp_id 1)
-- - Trimmed extra spaces from names and departments
-- - Standardized department labels (sales → Sales)
-- - Converted hire_date from text to DATE type
-- - Cleaned salary format (removed $, commas)
-- - Added missing .com to email addresses
-- - Populated NULL managers using department matching
-- - Removed employee with no useful data (emp_id 8)
-- ========================================
