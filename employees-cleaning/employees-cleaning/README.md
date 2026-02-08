# Employee Data Cleaning Project

## Overview
Cleaned employee records dataset (13 rows) addressing formatting inconsistencies and data quality issues.

## Dataset Details
- **Original rows:** 13
- **Duplicates removed:** 1
- **Unusable rows removed:** 1
- **Final clean rows:** 11

## Problems Fixed
- Duplicate employee records
- Extra spaces in names and departments
- Inconsistent salary formats ($75,000 vs 65000 vs 78,000)
- Missing email domains (.com)
- Mixed date formats (01/15/2023 vs 7/22/23)
- Department case inconsistencies (Sales vs sales)
- NULL manager assignments

## Cleaning Process
1. **Duplicates:** Used ROW_NUMBER() to identify and remove
2. **Standardization:** TRIM() for spaces, unified department labels
3. **Date conversion:** STR_TO_DATE() + ALTER TABLE to DATE type
4. **Salary cleaning:** REPLACE() to remove $, commas; converted to DECIMAL
5. **Email fixing:** CONCAT() to add missing .com domains
6. **Null handling:** Self-join to populate managers by department

## Skills Demonstrated
- Window functions (ROW_NUMBER, PARTITION BY)
- String manipulation (TRIM, REPLACE, CONCAT)
- Data type conversion
- Self-joins for data population
- Business logic application

## Files
- `employees_cleaning.sql` - Complete cleaning script
