# Inventory Management Data Cleaning Project

## Overview
Cleaned product inventory dataset (11 rows) with complex business logic requirements.

## Dataset Details
- **Original rows:** 11
- **Duplicate products merged:** 1 (SKU-001)
- **Final clean rows:** 10

## Problems Fixed
- Duplicate products with different SKU formats (SKU-001 vs sku001)
- Inconsistent category hierarchies (Electronics/Computers vs Computers/Electronics)
- Mixed price formats ($1,299.99 vs 129.99 USD)
- Negative stock levels (data entry errors)
- NULL stock levels (unknown inventory)
- Supplier name variations (Tech Supplies Inc vs Tech Supplies Inc.)
- SKU format inconsistencies (SKU-001 vs sku001 vs SKU 007)
- Missing category and warehouse assignments

## Cleaning Process
1. **SKU standardization:** Unified format variations
2. **Category hierarchy:** Standardized order (Electronics/Computers)
3. **Price cleaning:** REPLACE() + DECIMAL conversion
4. **Stock corrections:** Fixed negative values, left NULLs for unknowns
5. **Date conversion:** STR_TO_DATE() for restock dates
6. **Null population:** Self-joins using warehouse and supplier matching
7. **Duplicate merging:** Combined stock levels (45 + 30 = 75)

## Business Logic Applied
- Negative stock treated as data entry error (-5 → 5)
- NULL stock preserved (unknown inventory status)
- Duplicate products merged with combined stock totals
- Category inferred from warehouse location patterns
- Warehouse assigned based on supplier relationships

## Skills Demonstrated
- Complex business rule implementation
- Multi-condition self-joins
- Data aggregation for duplicates
- Pattern-based null filling
- Inventory management logic

## Files
- `inventory_cleaning.sql` - Complete cleaning script
