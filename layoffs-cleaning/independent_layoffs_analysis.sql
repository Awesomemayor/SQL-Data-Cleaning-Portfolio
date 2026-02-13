-- ==========================================
-- INDEPENDENT LAYOFFS ANALYSIS
-- ==========================================

-- Author: Mayowa Adejumo
-- Date: February 12, 2026
-- Dataset: Global Layoffs 2020-2023

-- OBJECTIVE:
-- This analysis demonstrates independent analytical thinking by answering 10 original business questions about workforce reduction,
-- patterns across companies, industries, geographies, and time periods.

-- ==========================================
-- SECTION 1: BUSINESS CONTEXT QUESTIONS
-- ==========================================

-- Q1: SURVIVOR ANALYSIS
-- Companies with multiple layoff events (3+)?
-- What does the pattern suggest about individual business strategy?

SELECT * 
FROM layoffs_staging2;

SELECT company, COUNT(*) AS event_count
FROM layoffs_staging2
GROUP BY company
HAVING event_count >= 3
ORDER BY event_count DESC;

-- 59 companies had 3+ layoff events
-- Multiple layoffs suggest business struggles vs one-time restructuring. 


-- Q2: EFFICIENCY METRIC (LAYOFF INTENSITY)
-- The "layoff intensity" for each industry, i.e. (total layoffs ÷ number of companies). 
-- Which industries had the highest average layoffs per company?

WITH Layoff_Intensity AS (
    SELECT industry, 
           SUM(total_laid_off) AS industry_layoff, 
           COUNT(DISTINCT company) AS company_count
    FROM layoffs_staging2
    WHERE industry IS NOT NULL
    GROUP BY industry
)
SELECT industry,
       industry_layoff,
       company_count,
       ROUND(industry_layoff / company_count, 2) AS layoff_intensity
FROM Layoff_Intensity
ORDER BY layoff_intensity DESC;

-- Hardware (1,152 avg), Consumer (531 avg) and Sales (528 avg) had highest layoff intensity


-- Q3: GEOGRAPHIC COMPARISON
-- The top 5 countries by total layoffs and the average company size affected (per layoff event) 
-- Did larger or smaller companies get hit harder in each country?

WITH Top5_Countries AS (
    SELECT country, SUM(total_laid_off) AS total
    FROM layoffs_staging2
    GROUP BY country
    ORDER BY total DESC
    LIMIT 5
)
SELECT ls.country, 
       ROUND(AVG(ls.total_laid_off), 2) AS avg_event_size,
       COUNT(*) AS num_events
FROM layoffs_staging2 ls
WHERE ls.country IN (SELECT country FROM Top5_Countries)
  AND ls.total_laid_off IS NOT NULL
GROUP BY ls.country
ORDER BY avg_event_size DESC;

-- Netherlands 1913.339 Sweden 704.0016 India 285.66126 United States 249.811027 Brazil 157.4466
-- Netherlands and Sweden had much larger average event sizes despite smaller total layoffs.
-- This suggests fewer but more severe layoff events in European markets.

-- Q4: STAGE VULNERABILITY
-- The PERCENTAGE of companies that completely shut down (100% laid off) across funding stages. 
-- Are early-stage or late-stage companies more likely to fail completely?

WITH Stage_Totals AS (
    SELECT stage, 
           COUNT(DISTINCT company) AS total_companies
    FROM layoffs_staging2
    WHERE stage IS NOT NULL
    GROUP BY stage
),
Stage_Shutdowns AS (
    SELECT stage,
           COUNT(DISTINCT company) AS shutdown_companies
    FROM layoffs_staging2
    WHERE stage IS NOT NULL 
      AND percentage_laid_off = 1
    GROUP BY stage
)
SELECT st.stage,
       st.total_companies,
       COALESCE(ss.shutdown_companies, 0) AS shutdowns,
       ROUND((COALESCE(ss.shutdown_companies, 0) / st.total_companies) * 100, 2) AS shutdown_rate
FROM Stage_Totals st
LEFT JOIN Stage_Shutdowns ss ON st.stage = ss.stage
ORDER BY shutdown_rate DESC;

-- Seed stage (43% shutdown rate), Unknown (12%), Acquired (14.3%) had highest failure rates
-- Early-stage companies 4x more likely to fail completely.


-- Q5: TIMING PATTERNS (SEASONAL ANALYSIS)
-- Which month of the year (regardless of year) had the most layoffs? 
-- Is there a seasonal pattern?

SELECT MONTH(`date`) AS month_num,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY MONTH(`date`)
ORDER BY total_layoffs DESC;

-- January (92,037), November (55,758), February (41,046) had most layoffs.  
-- - January: Post-holiday budget cuts, fiscal year planning
-- - November: Pre-holiday cost reduction, Q4 adjustments
-- This suggests layoffs are strategically timed, not purely reactive.


-- ==========================================
-- SECTION 2: ADVANCED ANALYTICAL QUESTIONS
-- ==========================================

-- Q6: MARKET LEADER INSTABILITY
-- Companies in top 10 for layoffs one year but dropped out of top 20 the next year. 
-- What does volatility suggest?

WITH Yearly_Ranks AS (
    SELECT company, 
           YEAR(`date`) AS year,
           SUM(total_laid_off) AS total_layoffs,
           DENSE_RANK() OVER (PARTITION BY YEAR(`date`) ORDER BY SUM(total_laid_off) DESC) AS yearly_rank
    FROM layoffs_staging2
    WHERE YEAR(`date`) IS NOT NULL
    GROUP BY company, YEAR(`date`)
),
-- Companies in top 10 in 2020
Top10_2020 AS (
    SELECT company, total_layoffs
    FROM Yearly_Ranks
    WHERE year = 2020 AND yearly_rank <= 10
),
-- Companies in top 20 in 2021
Top20_2021 AS (
    SELECT company
    FROM Yearly_Ranks
    WHERE year = 2021 AND yearly_rank <= 20
),
-- 2020 top 10 that dropped out in 2021
Dropped_2020_2021 AS (
    SELECT company, total_layoffs, 2020 AS top_year, 2021 AS dropped_year
    FROM Top10_2020
    WHERE company NOT IN (SELECT company FROM Top20_2021)
),
-- Same for 2021 - 2022
Top10_2021 AS (
    SELECT company, total_layoffs
    FROM Yearly_Ranks
    WHERE year = 2021 AND yearly_rank <= 10
),
Top20_2022 AS (
    SELECT company
    FROM Yearly_Ranks
    WHERE year = 2022 AND yearly_rank <= 20
),
Dropped_2021_2022 AS (
    SELECT company, total_layoffs, 2021 AS top_year, 2022 AS dropped_year
    FROM Top10_2021
    WHERE company NOT IN (SELECT company FROM Top20_2022)
),
-- Same for 2022 - 2023
Top10_2022 AS (
    SELECT company, total_layoffs
    FROM Yearly_Ranks
    WHERE year = 2022 AND yearly_rank <= 10
),
Top20_2023 AS (
    SELECT company
    FROM Yearly_Ranks
    WHERE year = 2023 AND yearly_rank <= 20
),
Dropped_2022_2023 AS (
    SELECT company, total_layoffs, 2022 AS top_year, 2023 AS dropped_year
    FROM Top10_2022
    WHERE company NOT IN (SELECT company FROM Top20_2023)
)
-- Combining all periods
SELECT * FROM Dropped_2020_2021
UNION ALL
SELECT * FROM Dropped_2021_2022
UNION ALL
SELECT * FROM Dropped_2022_2023
ORDER BY top_year, company;

-- Several companies dropped from top 10 to outside top 20
-- High volatility suggests layoffs were event-driven (one-time mass cuts) rather than sustained workforce reduction.


-- Q7: INDUSTRY MIGRATION
-- Which industry had highest layoffs in 2020, 2021, 2022, 2023.
-- Did the "worst industry" shift over time?

WITH industry_layoff AS (
    SELECT industry, 
           YEAR(`date`) AS `year`, 
           SUM(total_laid_off) AS total_lay_off
    FROM layoffs_staging2
    WHERE YEAR(`date`) IS NOT NULL
    GROUP BY industry, `year`
),
Ranked_Layoff AS (
    SELECT *, 
           RANK() OVER(PARTITION BY `year` ORDER BY total_lay_off DESC) AS layoff_ranked
    FROM industry_layoff
)
SELECT industry, `year`, total_lay_off 
FROM Ranked_Layoff
WHERE layoff_ranked = 1
ORDER BY `year`;

-- "Worst industry" shifted each year. No single industry dominated as layoffs were sector-specific responses to different crises.


-- Q8: CUMULATIVE IMPACT BY STAGE
-- Running total of layoffs by company stage over time. Which stage's cumulative layoffs accelerated fastest in 2022?

WITH Running_Totals AS (
    SELECT stage,
           `date`,
           total_laid_off,
           SUM(total_laid_off) OVER (PARTITION BY stage ORDER BY `date`) AS running_total
    FROM layoffs_staging2
    WHERE stage IS NOT NULL 
      AND total_laid_off IS NOT NULL
      AND YEAR(`date`) = 2022
),
-- The final running total per stage in 2022
Stage_Acceleration AS (
    SELECT stage,
           MAX(running_total) AS peak_2022_total
    FROM Running_Totals
    GROUP BY stage
)
SELECT stage, peak_2022_total
FROM Stage_Acceleration
ORDER BY peak_2022_total DESC;

-- Post-IPO (79,373 cumulative), Unknown (19,127), Series C (13,072) accelerated fastest in 2022.


-- Q9: COUNTRY-INDUSTRY INTERSECTION
-- The country-industry combination with most layoffs. 
-- Is the pattern consistent (same combo dominates) or diverse?

SELECT country, 
       industry, 
       SUM(total_laid_off) AS total_layoff
FROM layoffs_staging2
WHERE country IS NOT NULL AND industry IS NOT NULL
GROUP BY country, industry
ORDER BY total_layoff DESC
LIMIT 20;

-- FINDING: United States + Consumer (38,080), United States + Retail (33,590), United States + Transportation (20,885) dominate top 3
-- Pattern is not diverse at the top (US industries dominate top 20). US market size explains concentration.
-- However, layoffs were global phenomenon affecting various sectors.


-- Q10: RECOVERY INDICATOR
-- Companies with layoffs in 2020-2021 but no layoffs in 2022-2023. 

WITH Early_Layoffs AS (
    SELECT DISTINCT company
    FROM layoffs_staging2
    WHERE YEAR(`date`) IN (2020, 2021)
),
Late_Layoffs AS (
    SELECT DISTINCT company
    FROM layoffs_staging2
    WHERE YEAR(`date`) IN (2022, 2023)
),
Recovered_Companies AS (
    SELECT company
    FROM Early_Layoffs
    WHERE company NOT IN (SELECT company FROM Late_Layoffs)
)
SELECT company,
       (SELECT COUNT(*) FROM Recovered_Companies) AS total_recovered
FROM Recovered_Companies
ORDER BY company;

-- 425 companies "recovered" (had early layoffs, none later)
