-- ========================================
-- CUSTOMER ORDERS DATA CLEANING PROJECT
-- ========================================
-- Author: Mayowa Adejumo
-- Date: January 2026
-- Dataset: Customer Orders (11 rows)
-- 
-- Objective: Clean e-commerce order data with formatting inconsistencies
-- Problems addressed:
-- - Duplicate orders
-- - Extra spaces in customer names
-- - Inconsistent country labels (USA, U.S.A., United States)
-- - Mixed phone number formats
-- - Inconsistent price formats ($1200 vs 1,200 USD)
-- - Order status case variations (Shipped vs SHIPPED)
-- - Multiple date formats
-- - Missing email domains (.com)
-- - Unusable order records
-- ========================================

DROP TABLE IF EXISTS orders_dirty;
CREATE TABLE orders_dirty (
    order_id INT,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(50),
    address_country VARCHAR(50),
    product_name VARCHAR(100),
    quantity INT,
    price VARCHAR(20),
    order_status VARCHAR(30),
    order_date VARCHAR(20),
    shipping_date VARCHAR(20)
);

INSERT INTO orders_dirty VALUES
(1001, 'John Smith', 'john@email.com', '555-1234', 'USA', 'Laptop', 2, '$1200', 'Shipped', '01/10/2024', '01/12/2024'),
(1002, 'Jane Doe', 'jane@email', '5551234567', 'United States', 'Mouse', 5, '25.00', 'delivered', '01/11/2024', '01/13/2024'),
(1003, ' Bob Wilson', 'bob@email.com', '(555) 123-4567', 'U.S.A.', 'Keyboard', 3, '$75', 'Pending', '01/12/2024', NULL),
(1001, 'John Smith', 'john@email.com', '555-1234', 'USA', 'Laptop', 2, '$1200', 'Shipped', '01/10/2024', '01/12/2024'),
(1004, 'Alice Brown', 'alice@email.com', '555.123.4567', 'USA', 'Monitor', 1, '350', 'SHIPPED', '01/13/2024', '01/15/2024'),
(1005, 'Charlie Lee', 'charlie@email.com', '555-9876', 'Canada', 'Laptop', 1, '1,200 USD', 'Processing', '01/14/2024', NULL),
(1006, 'Diana Ross', 'diana.ross@email.com', '5559876543', 'United States', 'Mouse', 10, '$25.00', 'Delivered', '01/15/2024', '01/17/2024'),
(1007, 'Eve Adams', 'eve@email', '555-4567', 'USA', 'Tablet', 2, 'USD 800', 'shipped', '1/16/24', '1/18/24'),
(1008, 'Frank Miller', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '01/17/2024', NULL),
(1009, 'Grace Hill', 'grace@email.com', '(555)123-4567', 'U.S.A.', 'Keyboard', 2, '$75.00', 'Pending', '01/18/2024', NULL),
(1010, 'Henry Ford', 'henry@email.com', '555 123 4567', 'usa', 'Monitor', 3, '350.00', 'Delivered', '01/19/2024', '01/21/2024');

SELECT * FROM orders_dirty;

-- TASK 1 - CREATING A STAGING TABLE

DROP TABLE if exists orders_dirty2;
CREATE TABLE orders_dirty2
LIKE orders_dirty;

INSERT INTO orders_dirty2
SELECT *
FROM orders_dirty;

SELECT *
FROM orders_dirty2;

-- TASK 2 - REMOVING DUPLICATES
SELECT *, ROW_NUMBER () OVER (PARTITION BY order_id, customer_name, email, phone, address_country, product_name, quantity, price, order_status, order_date, shipping_date) AS row_num
FROM orders_dirty2;

-- TO DELETE DUPLICATES, WE NEED AN UPDATE TABLE
DROP TABLE if exists orders_dirty3;
CREATE TABLE `orders_dirty3` (
  `order_id` int DEFAULT NULL,
  `customer_name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `address_country` varchar(50) DEFAULT NULL,
  `product_name` varchar(100) DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `price` varchar(20) DEFAULT NULL,
  `order_status` varchar(30) DEFAULT NULL,
  `order_date` varchar(20) DEFAULT NULL,
  `shipping_date` varchar(20) DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO orders_dirty3
SELECT *, ROW_NUMBER () OVER (PARTITION BY order_id, customer_name, email, phone, address_country, product_name, quantity, price, order_status, order_date, shipping_date)
FROM orders_dirty2;

DELETE
FROM orders_dirty3
WHERE row_num > 1;

SELECT * 
FROM orders_dirty3;

-- TASK 2 - STANDARDIZE DATA
-- TRIM CUSTOMER_NAME
SELECT customer_name, TRIM(customer_name)
FROM orders_dirty3;

UPDATE orders_dirty3
SET customer_name = TRIM(customer_name);

-- TASK 3 - UNIFY LABEL - UNITED STATES
SELECT DISTINCT address_country
FROM orders_dirty3;

UPDATE orders_dirty3
SET address_country = 'United States'
WHERE address_country IN ('USA', 'U.S.A.', 'United States');

SELECT * 
FROM orders_dirty3;

-- TASK 4 - UNIFY LABEL - SHIPPED
UPDATE orders_dirty3
SET order_status = 'Shipped'
WHERE order_status LIKE 'SHI%';

SELECT * 
FROM orders_dirty3;

-- TASK 5 - UNIFY LABEL - DELIVERED
UPDATE orders_dirty3
SET order_status = 'Delivered'
WHERE order_status LIKE 'deli%';

-- TASK 6 - CHANGE TO DATE FORMAT - ORDER DATE
UPDATE orders_dirty3
SET order_date = STR_TO_DATE(`order_date`, '%m/%d/%Y');

ALTER TABLE orders_dirty3
MODIFY COLUMN order_date DATE;

-- TASK 7 - CHANGE TO DATE FORMAT - SHIPPING DATE
UPDATE orders_dirty3
SET shipping_date = STR_TO_DATE(shipping_date, '%m/%d/%Y');

ALTER TABLE orders_dirty3
MODIFY COLUMN shipping_date DATE;

SELECT * 
FROM orders_dirty3;

-- TASK 8 - REMOVE UNNECESSARY ROW
DELETE 
FROM orders_dirty3
WHERE email IS NULL 
	AND phone IS NULL 
	AND address_country IS NULL 
    AND product_name IS NULL 
    AND quantity IS NULL 
    AND price IS NULL 
    AND order_status IS NULL;

SELECT * 
FROM orders_dirty3;

-- TASK 9 - REMOVE UNNECESSARY COLUMN
ALTER TABLE orders_dirty3
DROP COLUMN row_num;

SELECT * 
FROM orders_dirty3;

-- TASK 10 - SORT EMAIL FORMAT
UPDATE orders_dirty3
SET email = CONCAT(email, '.com')
WHERE email NOT LIKE '%.com'; 

-- TASK 11 - SORT PHONE NUMBER
-- Step 1: Remove all formatting characters
UPDATE orders_dirty3
SET phone = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(phone, '-', ''), '(', ''), ')', ''), '.', ''), ' ', '');

-- Step 2: Format as XXX-XXX-XXXX
UPDATE orders_dirty3
SET phone = CONCAT(
    SUBSTRING(phone, 1, 3), '-',
    SUBSTRING(phone, 4, 3), '-',
    SUBSTRING(phone, 7, 4)
)
WHERE LENGTH(phone) = 10;

-- TASK 12 - SORT PRICE
UPDATE orders_dirty3
SET price = REPLACE(REPLACE(price, '$', ''), ',', '');

UPDATE orders_dirty3
SET price = REPLACE(price, ' USD', ''); 

ALTER TABLE orders_dirty3
MODIFY COLUMN price DECIMAL(10,2);

SELECT * 
FROM orders_dirty3;



-- ========================================
-- CLEANING COMPLETE
-- ========================================
-- Original rows: 11
-- Duplicates removed: 1
-- Unusable rows removed: 1
-- Final clean rows: 9
-- 
-- Key changes:
-- - Removed duplicate order (order_id 1001)
-- - Trimmed extra spaces from customer names
-- - Unified country labels to "United States"
-- - Standardized order status (Shipped, Delivered, Pending, Processing)
-- - Converted dates from text to DATE type
-- - Standardized phone numbers to XXX-XXX-XXXX format
-- - Cleaned price format (removed $, USD, commas)
-- - Converted price to DECIMAL type
-- - Added missing .com to email addresses
-- - Removed order with no useful data (order_id 1008)
-- 
-- New functions learned:
-- - SUBSTRING() for phone number formatting
-- - Multiple nested REPLACE() for complex cleaning
-- - CONCAT() for string assembly
-- ========================================
