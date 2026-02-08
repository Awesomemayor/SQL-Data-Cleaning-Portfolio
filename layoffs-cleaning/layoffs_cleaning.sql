-- ========================================
-- LAYOFFS DATA CLEANING PROJECT
-- ========================================
-- Author: Mayowa Adejumo
-- Date: January 2026
-- Dataset: World Layoffs (2020-2023)
-- Source: Alex The Analyst YouTube Tutorial
-- 
-- Objective: Clean and standardize layoffs dataset
-- Methods: Remove duplicates, standardize formats, handle nulls
-- ========================================

-- MY DATA CLEANING EXERCISE - WORLD LAYOFFS

SELECT * 
FROM layoffs;

								-- THE DATA CLEANING PROCESS WILL INVOLVE 4 (FOUR) KEY PROCESSES
-- 1. REMOVE DUPLICATES FROM THE DATA SET
-- 2. STANDARDIZE THE DATA
-- 3. POPULATE NECESSARY NULL AND BLANK VALUES
-- 4. REMOVE UNNECESSARY ROWS AND COLUMS

-- TASK 1a - CREATE A STAGING TABLE
-- Purpose: Preserve original data while working on a copy

DROP TABLE IF EXISTS layoffs_staging;
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * 
FROM layoffs_staging;

-- TASK 1b - INSERT THE DATA INTO THE STAGING TABLE CREATED

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

-- TASK 2 - REMOVE DUPLICATES
-- THE GOAL IS TO USE ROW NUMBERS TO IDENTIFY DUPLICATES... THIS WILL BE DONE IN PHASES
-- 1. INDENTIFY THE DUPLICATES
-- 2. USE CTE TO SORT THE DUPLICATES
-- 3. DELETE THE DUPLICATES FROM THE DATA SET

-- 2a. INDENTIFY THE DUPLICATES
SELECT *, 
ROW_NUMBER () OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- 2b USE CTE TO SORT THE DUPLICATES
WITH sorting_duplicates AS
(SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM sorting_duplicates
WHERE row_num > 1;

-- 2c. DELETE THE DUPLICATES FROM THE DATA SET
-- THE STEPS INVOLVED INCLUDE 
-- 		1. creating another staging table (this time, with the create statement), with an additional column (row_num)
-- 		2. inserting data into the new staging table created
-- 		3. running the new code to earmark the duplicates
--      4. then delete duplicates... thus, the new staging table (staging table 2) becomes the new operational table.

-- 2ci. CREATE THE LAYOFF_STAGING_2
DROP TABLE IF EXISTS layoffs_staging2;
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging2;

-- 2cii. INSERT DATA FROM LAYOFF_STAGING INTO LAYOFF_STAGING2
INSERT layoffs_staging2
SELECT *, ROW_NUMBER () OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT * 
FROM layoffs_staging2;

-- 2ciii. FROM LAYOFF_STAGING2, IDENTIFY DUPLICATES
SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

-- 2civ. DELETE DUPLICATES

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2;


-- TASK 3 - STANDARDIZE THE TABLE

-- 3.1 - TRIM
SELECT company, TRIM(company)
FROM layoffs_staging2;

-- 3.1b - UPDATE THE TRIM
UPDATE layoffs_staging2
SET company = TRIM(company);

-- 3.2. STANDARDIZE LABEL FOR ROWS... SOME DATA NAMES ARE USED DIFFERENTLY E.G. IN INDUSTRY, CRYPTO, CRYPTOCURRENCY, CRYPTO CURRENCY... SAME CATEGORY BUT DIFFERENT LABEL. SO THE LABELS MUST BE UNIFIED
-- 3.2a ORDER THE SPECIFIC COLUMN TO SEE WHAT DATA NEEDS TO BE UNIFIED
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- 3.2b FOCUS ON THE IDENTIFIED DATA TO KNOW THE DIFFERENT VARIATIONS THAT EZIST
SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'crypto%';

-- 3.2c - UPDATE IT BY UNIFYING THE LABEL
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%';

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- 3.3 - STANDARDIZED LABEL FOR ROWS... ANOTHER ISSUE WITH THE COUNTRY COLUMN. United States HAS TWO DIFFERENT LABELS, ONE WITH '.' THE OTHER WITHOUT
-- 3.3a - USE TRIM...TRAIL TO REMOVE THE '.'  
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) AS trimmed
FROM layoffs_staging2
ORDER BY 1;

-- 3.3b - UPDATE IT
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- 3.4 - SETTING DATE TO TIMESERIES
-- 3.4a FORMAT THE DATE COLUMN
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') date_formatted
FROM layoffs_staging2;

-- 3.4b - UPDATE IT.
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- 3.4c - ENSURE THE INFORMATION IS MODIFIED ON THE TABLE INFORMATION. THIS WILL CHANGE THE DATA TYPE OF THE OF DATE IN THE ACTUAL TABLE.
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- TASK 4 WORKING ON NULL AND BLANK VALUES
-- IN INDUSTRY THERE ARE 4 ROWS WITH BLANK OR NULL ENTRIES. THE TASK IS TO MANUALLY SORT THEM AND KNOW WHAT COMPANY EACH IS MEANT TO BE
SELECT * 
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

-- 4.1 THE FIRST BLANK IS UNDER THE COMPANY AIRBNB
SELECT * 
FROM layoffs_staging2
WHERE company = 'Airbnb';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;


UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;


-- TASK 5 - REMOVE UNNECESSARY ROWS AND COLUMNS
-- 5.1 - DELETE ROWS
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

-- 5.2 - DELETE COLUMN
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;



-- ========================================
-- CLEANING COMPLETE
-- ========================================
-- Original rows: 2,361
-- Duplicates removed: 5
-- Rows with no useful data removed: 361
-- Final clean rows: 1,995
-- 
-- Key changes:
-- - Standardized company names (trimmed spaces)
-- - Unified industry labels (Crypto variations)
-- - Fixed country formatting (United States.)
-- - Converted date from text to DATE type
-- - Populated missing industry values where possible
-- ========================================
