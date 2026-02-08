-- ========================================
-- INVENTORY MANAGEMENT DATA CLEANING PROJECT
-- ========================================
-- Author: Mayowa Adejumo
-- Date: January 2026
-- Dataset: Product Inventory (11 rows)
-- 
-- Objective: Clean inventory data with format inconsistencies and business logic issues
-- Problems addressed:
-- - Duplicate products with different SKU formats
-- - Inconsistent category hierarchies
-- - Mixed price formats ($1,299.99 vs 129.99 USD)
-- - Negative stock levels (data errors)
-- - NULL stock levels
-- - Supplier name variations
-- - Missing category and warehouse assignments
-- - SKU format inconsistencies (SKU-001 vs sku001 vs SKU 007)
-- ========================================


DROP TABLE IF EXISTS dirty_inventory;
CREATE TABLE dirty_inventory (
    product_id VARCHAR(20),
    product_name VARCHAR(100),
    category VARCHAR(100),
    price VARCHAR(20),
    stock_level INT,
    supplier VARCHAR(100),
    last_restock VARCHAR(20),
    warehouse_location VARCHAR(50)
);

INSERT INTO dirty_inventory VALUES
('SKU-001', 'Laptop Pro', 'Electronics/Computers', '$1,299.99', 45, 'Tech Supplies Inc', '01/05/2024', 'Warehouse A'),
('sku001', 'Laptop Pro', 'Computers/Electronics', '1299.99', 30, 'Tech Supplies Inc.', '01/05/2024', 'Warehouse A'),
('SKU-002', 'Wireless Mouse ', 'Accessories/Computer', '$ 29.99', 150, 'Office Gear Co', '01/10/2024', 'Warehouse B'),
('SKU-003', 'USB Cable', 'Accessories', '9.99', -5, 'Cable World', '12/20/2023', 'Warehouse C'),
('SKU-004', 'Monitor 27"', 'Electronics/Displays', '$399', 0, 'Screen Masters LLC', '01/15/2024', NULL),
('SKU-005', ' Keyboard Mechanical', 'Accessories/Computer', '129.99 USD', 75, 'Office Gear Co.', '1/12/24', 'Warehouse B'),
('SKU-006', 'Webcam HD', 'Electronics/Video', '$79.99', 60, 'Tech Supplies Inc', '01/08/2024', 'Warehouse A'),
('SKU 007', 'Headphones', 'Audio/Electronics', '149.99', NULL, 'Sound Plus', '01/20/2024', 'Warehouse D'),
('SKU-008', 'Tablet 10"', NULL, '$ 499.99', 25, 'Mobile Devices Ltd', '01/18/2024', 'Warehouse A'),
('SKU-009', 'USB Cable', 'Accessories', '$9.99', 200, 'Cable World Inc', '01/22/2024', 'Warehouse C'),
('SKU-010', 'Monitor 27"', 'Displays/Electronics', '399.00', 15, 'Screen Masters LLC', '01/25/2024', 'Warehouse B');

SELECT * 
FROM dirty_inventory;

-- TASK 1 -  CREATE A STAGING TABLE
DROP TABLE if exists dirty_inventory2;
CREATE TABLE dirty_inventory2
LIKE dirty_inventory;

INSERT INTO dirty_inventory2
SELECT *
FROM dirty_inventory;

SELECT * 
FROM dirty_inventory2;

-- TASK 2 - CHECKING FOR AND REMOVING DUPLICATES
SELECT *, 
ROW_NUMBER () OVER (PARTITION BY product_id, product_name, category, price, stock_level, supplier, last_restock, warehouse_location) row_num
FROM dirty_inventory2;

WITH checking_duplicates AS 
(SELECT *, 
ROW_NUMBER (
) OVER (PARTITION BY product_id, product_name, category, price, stock_level, supplier, last_restock, warehouse_location) row_num
FROM dirty_inventory2)
SELECT * from checking_duplicates
WHERE row_num > 1;

-- THERE ARE NO DUPLICATES IN THE TABLE.. THE LAPTOP PRO THAT SHOULD HAVE BEEN DUPLICATE HAVE INCONSISTENT LABELS. UNTIL THE LABELS ARE UNIFIED, THE DUPLICATE WONT BE ELIMINATED

-- TASK 3 - STANDARDIZING THE TABLE

SELECT *
FROM dirty_inventory2;

-- TASK 4 - TRIM PRODUCT NAME
UPDATE dirty_inventory2
SET product_name = TRIM(product_name);

-- TASK 5 - UNIFY LABELS
SELECT *
FROM dirty_inventory2;

-- 5.1. UNIFY PRODUCT_ID
UPDATE dirty_inventory2
SET product_id = 'SKU-001'
WHERE product_id = 'sku001';

-- 5.2. UNIFY CATEGORY
UPDATE dirty_inventory2
SET category = 'Electronics/Computers'
WHERE category = 'Computers/Electronics';

-- TASK 6 - SORT PRICE INCONSISTENCIES
UPDATE dirty_inventory2
SET price = REPLACE(REPLACE (price, '$', ''), ',', '');

UPDATE dirty_inventory2
SET price = REPLACE(price, ' USD', '');

-- TASK 7 - TRIM PRICE
SELECT *
FROM dirty_inventory2;

UPDATE dirty_inventory2
SET price = TRIM(price);

ALTER TABLE dirty_inventory2
MODIFY COLUMN price DECIMAL(10, 2);

-- TASK 8 - SET DATE FORMAT
UPDATE dirty_inventory2
SET last_restock = STR_TO_DATE(last_restock, '%m/%d/%Y');

ALTER TABLE dirty_inventory2
MODIFY COLUMN last_restock DATE;

SELECT *
FROM dirty_inventory2;

-- TASK 9 - UNIFY PRODUCT_ID - SKU-007
UPDATE dirty_inventory2
SET product_id = 'SKU-007'
WHERE product_id = 'SKU 007';

-- TASK 10 - UNIFY STOCK_LEVEL
UPDATE dirty_inventory2
SET stock_level = '5'
WHERE stock_level = '-5';

-- TASK 11 - UNIFY SUPPLIER
UPDATE dirty_inventory2
SET supplier = TRIM(TRAILING '.' FROM supplier);

-- TASK 12 - DEALING WITH NULLS - CATEGORY
SELECT *
FROM dirty_inventory2 d1
JOIN dirty_inventory2 d2
ON d1.warehouse_location = d2.warehouse_location
WHERE d1.category IS NULL AND d2.category IS NOT NULL
AND d2.product_name = 'Laptop Pro';

UPDATE dirty_inventory2 d1
JOIN dirty_inventory2 d2
ON d1.warehouse_location = d2.warehouse_location
SET d1.category = d2.category
WHERE d1.category IS NULL AND d2.category IS NOT NULL
AND d2.product_name = 'Laptop Pro'; 

-- TASK 13 - DEALING WITH NULLS - WAREHOUSE LOCATION
SELECT *
FROM dirty_inventory2 d1
JOIN dirty_inventory2 d2
ON d1.supplier = d2.supplier
WHERE d1.warehouse_location IS NULL AND d2.warehouse_location IS NOT NULL;

UPDATE dirty_inventory2 d1
JOIN dirty_inventory2 d2
ON d1.supplier = d2.supplier
SET d1.warehouse_location = d2.warehouse_location
WHERE d1.warehouse_location IS NULL AND d2.warehouse_location IS NOT NULL;

SELECT *
FROM dirty_inventory2;

-- TASK 14 - REMOVING THE IDENTIFIED DUPLICATE
DELETE FROM dirty_inventory2
WHERE product_id = 'SKU-001' 
AND stock_level = 30;

UPDATE dirty_inventory2
SET stock_level = 75
WHERE product_id = 'SKU-001';

SELECT * 
FROM dirty_inventory2;


-- ========================================
-- CLEANING COMPLETE
-- ========================================
-- Original rows: 11
-- Duplicate products merged: 1 (SKU-001 combined stock)
-- Final clean rows: 10
-- 
-- Key changes:
-- - Unified product IDs (sku001 → SKU-001, SKU 007 → SKU-007)
-- - Trimmed product names and supplier names
-- - Standardized category hierarchy (Electronics/Computers)
-- - Cleaned price format (removed $, USD, commas)
-- - Converted price to DECIMAL type
-- - Fixed negative stock (-5 → 5)
-- - Converted last_restock from text to DATE type
-- - Populated NULL category using warehouse matching
-- - Populated NULL warehouse using supplier matching
-- - Merged duplicate SKU-001 entries (combined stock: 45 + 30 = 75)
-- 
-- Business logic applied:
-- - Negative stock treated as data entry error and corrected
-- - NULL stock left as-is (unknown inventory)
-- - Duplicate products merged with combined stock levels
-- ========================================
