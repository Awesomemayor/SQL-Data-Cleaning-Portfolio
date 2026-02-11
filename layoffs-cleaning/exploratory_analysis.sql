-- ==========================================
-- LAYOFFS EXPLORATORY DATA ANALYSIS
-- ==========================================
-- Author: Mayowa Adejumo
-- Date: February 2026
-- Dataset: Global Layoffs 2020-2023
-- Source: Cleaned layoffs_staging2 table
-- 
-- Objective: Analyze layoff patterns across companies, industries, 
-- countries, and time periods to identify key trends
-- ==========================================

-- ==========================================
-- SECTION 1: DATA OVERVIEW
-- ==========================================

-- View the cleaned dataset
SELECT *
FROM layoffs_staging2;

-- What are the maximum layoffs in a single event?
-- Finding: Max single layoff = 12,000 employees
-- Finding: 116 companies laid off 100% of workforce
SELECT 	max(total_laid_off) AS max_layoffs, 
		max(percentage_laid_off) AS max_percentage
FROM layoffs_staging2;

-- Which companies had complete shutdowns (100% laid off)?
-- Finding: Companies like Katerra, Britishvolt went completely under
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- What is the date range of this dataset?
-- Finding: Data spans from March 2020 to March 2023 (3 years)
SELECT MIN(`date`), max(`date`)
FROM layoffs_staging2;

-- ==========================================
-- SECTION 2: COMPANY ANALYSIS
-- ==========================================

-- Which companies had the most total layoffs?
-- Finding: Amazon (18,150), Google (12,000), Meta (11,000) lead
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- What was the average layoff percentage per company?
-- Finding: Many startups laid off 100% (complete shutdown)
SELECT company, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


-- ==========================================
-- SECTION 3: INDUSTRY ANALYSIS
-- ==========================================

-- Which industries were hit hardest?
-- Finding: Consumer (45,182), Retail (43,613), Transportation (33,748)
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- ==========================================
-- SECTION 4: GEOGRAPHIC ANALYSIS
-- ==========================================

-- Which countries had the most layoffs?
-- Finding: United States dominated with 256,559 layoffs
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;


-- ==========================================
-- SECTION 5: TIME-BASED ANALYSIS
-- ==========================================

-- What's the yearly trend?
-- Finding: 2022 had peak layoffs (160,661), 2023 second (125,677)
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Monthly layoff totals
-- Finding: Shows monthly breakdown for granular trend analysis
SELECT SUBSTRING(`DATE`,1,7) AS `month`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`DATE`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC;

-- Rolling total of layoffs over time
-- Finding: Cumulative impact reached 383,659 total layoffs
WITH Rolling_Total AS 
(
SELECT SUBSTRING(`DATE`,1,7) AS `month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`DATE`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC
)
SELECT `month`, total_off,
SUM(total_off) OVER(ORDER BY `month`) AS rolling_total
FROM Rolling_Total;


-- ==========================================
-- SECTION 6: COMPANY STAGE ANALYSIS
-- ==========================================

-- Which company stages laid off the most?
-- Finding: Post-IPO companies (204,132) led, followed by Acquired (27,576)
SELECT stage, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;



-- ==========================================
-- SECTION 7: YEAR-OVER-YEAR COMPANY RANKINGS
-- ==========================================

-- Top 5 companies with most layoffs per year
-- Finding: Shows which companies dominated layoffs each year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
),
Company_Year_Rank AS
(
SELECT *, 
DENSE_RANK () OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranked
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE ranked <= 5;

-- ==========================================
-- KEY INSIGHTS SUMMARY
-- ==========================================
-- 
-- 1. SCALE: 383,659 total layoffs across 2020-2023
-- 2. PEAK YEAR: 2022 saw the most layoffs (tech correction)
-- 3. TOP COMPANIES: Amazon, Google, Meta led in absolute numbers
-- 4. INDUSTRIES: Consumer, Retail, Transportation hit hardest
-- 5. GEOGRAPHY: United States accounted for 66% of all layoffs
-- 6. STAGE: Post-IPO companies laid off the most (cost-cutting pressure)
-- 7. SHUTDOWNS: 116 companies completely shut down (100% layoffs)
-- 
-- ==========================================
