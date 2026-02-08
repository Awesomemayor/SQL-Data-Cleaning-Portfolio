# Customer Orders Data Cleaning Project

## Overview
Cleaned e-commerce orders dataset (11 rows) with multiple formatting inconsistencies.

## Dataset Details
- **Original rows:** 11
- **Duplicates removed:** 1
- **Unusable rows removed:** 1
- **Final clean rows:** 9

## Problems Fixed
- Duplicate order records
- Extra spaces in customer names
- Inconsistent country labels (USA, U.S.A., United States)
- Mixed phone number formats (555-1234, (555) 123-4567, 555.123.4567)
- Inconsistent price formats ($1200 vs 1,200 USD vs 25.00)
- Order status case variations (Shipped vs SHIPPED vs shipped)
- Multiple date formats
- Missing email domains

## Cleaning Process
1. **Duplicates:** ROW_NUMBER() identification and removal
2. **Standardization:** TRIM() for names, unified country/status labels
3. **Phone formatting:** SUBSTRING() to create XXX-XXX-XXXX format
4. **Price cleaning:** Multiple REPLACE() + DECIMAL conversion
5. **Date conversion:** STR_TO_DATE() for order and shipping dates
6. **Email fixing:** CONCAT() for missing .com

## Skills Demonstrated
- Advanced string manipulation (SUBSTRING, nested REPLACE)
- Pattern matching with LIKE
- Data type conversion
- Multi-step formatting logic
- Business rule application (NULL shipping dates for pending orders)

## New Functions Used
- **SUBSTRING()** - Extract portions of strings for phone formatting
- **Multiple nested REPLACE()** - Complex text cleaning
- **CONCAT()** - String assembly

## Files
- `orders_cleaning.sql` - Complete cleaning script
