# Layoffs Data Cleaning Project

## Overview
Cleaned and standardized a dataset of global layoffs (2020-2023) with 2,361 rows using MySQL.

## Dataset
- **Source:** Alex The Analyst YouTube Tutorial
- **Original rows:** 2,361
- **Final clean rows:** 1,995

## Cleaning Steps
1. **Removed duplicates** - Identified using ROW_NUMBER() window function
2. **Standardized data** - Trimmed spaces, unified industry labels, fixed country formatting
3. **Converted date format** - Changed from text to DATE type
4. **Handled nulls** - Populated missing industry values using self-joins
5. **Removed unusable rows** - Deleted records with no layoff data

## Skills Demonstrated
- Window functions (ROW_NUMBER, PARTITION BY)
- CTEs (Common Table Expressions)
- Self-joins for data population
- Data type conversion (STR_TO_DATE)
- String manipulation (TRIM, REPLACE)

## Files
- `layoffs_cleaning.sql` - Complete SQL cleaning script
