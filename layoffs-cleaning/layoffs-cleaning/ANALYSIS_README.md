# Layoffs Exploratory Data Analysis

## Overview
Analyzed 3 years of global layoff data (2020-2023) to identify patterns across companies, industries, countries, and time periods.

## Dataset
- **Source:** Cleaned layoffs_staging2 table
- **Total layoffs analyzed:** 383,659
- **Time period:** March 2020 - March 2023
- **Companies:** 1,600+
- **Countries:** 50+

## Analysis Sections

### 1. Data Overview
- Verified data quality and range
- Identified maximum single layoff event (12,000)
- Found 116 complete company shutdowns

### 2. Company Analysis
- Ranked companies by total layoffs
- Identified top 3: Amazon (18,150), Google (12,000), Meta (11,000)
- Analyzed average layoff percentages

### 3. Industry Analysis
- Consumer sector hit hardest (45,182 layoffs)
- Retail second (43,613)
- Transportation third (33,748)

### 4. Geographic Analysis
- United States dominated with 256,559 layoffs (66%)
- India second with 35,993
- Netherlands third with 17,220

### 5. Time-Based Analysis
- Peak year: 2022 (160,661 layoffs)
- Created rolling total to show cumulative impact
- Monthly breakdown reveals trend patterns

### 6. Company Stage Analysis
- Post-IPO companies laid off most (204,132)
- Early-stage (Seed, Series A-C) relatively stable
- Acquired companies also heavily affected (27,576)

### 7. Year-over-Year Rankings
- Tracked top 5 companies per year
- Shows shift from startups (2020) to Big Tech (2022-2023)

## Key Insights

1. **Tech Correction:** 2022 marked peak layoffs after pandemic hiring surge
2. **Big Tech Impact:** FAANG companies dominated 2022-2023 layoffs
3. **Geographic Concentration:** 2/3 of layoffs in United States
4. **Industry Shift:** Consumer and retail sectors collapsed post-pandemic
5. **Survival Rate:** 94% of companies did partial layoffs, 6% shut down completely

## SQL Techniques Used
- Aggregate functions (SUM, AVG, MAX)
- GROUP BY for categorical analysis
- Window functions (DENSE_RANK, SUM OVER)
- CTEs for complex multi-step queries
- Date functions (YEAR, SUBSTRING)
- Subqueries and rolling calculations

## Files
- `exploratory_analysis.sql` - Complete analysis queries with findings
- `layoffs_cleaning.sql` - Data cleaning process
