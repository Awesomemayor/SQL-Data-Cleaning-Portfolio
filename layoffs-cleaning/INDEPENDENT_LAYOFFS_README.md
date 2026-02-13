# Independent Layoffs Analysis

## Overview
Original analytical questions demonstrating independent SQL problem-solving on global layoffs data (2020-2023).

## Purpose
While the [exploratory analysis](./EXPLORATORY_README.md) followed a structured tutorial, this project showcases:
- Original business question formulation
- Creative SQL solutions without predefined approaches  
- Strategic analytical thinking
- Advanced SQL techniques

## Questions Analyzed

### Business Context (Q1-Q5)
1. **Survivor Analysis** - Companies with chronic layoff patterns (3+ events)
2. **Efficiency Metric** - Industry-level layoff intensity calculations  
3. **Geographic Comparison** - Average event size across top 5 countries
4. **Stage Vulnerability** - Shutdown rates by funding stage
5. **Timing Patterns** - Seasonal layoff trends across years

### Advanced Analytics (Q6-Q10)
6. **Market Leader Instability** - Year-over-year ranking volatility
7. **Industry Migration** - Shifting patterns of hardest-hit sectors
8. **Cumulative Impact** - Stage-level acceleration analysis for 2022
9. **Country-Industry Intersection** - Combined geographic-sector patterns  
10. **Recovery Indicator** - Companies that stabilized post-2021

## Key Findings

- **59 companies** had 3+ layoff events, suggesting chronic business struggles
- **Hardware industry** had highest layoff intensity (1,152 avg per company)
- **Netherlands** had largest average event sizes (1,913 employees per event)
- **Seed-stage companies** 4x more likely to shut down completely (43% rate)
- **January** consistently sees highest layoffs (seasonal budget planning)
- **Post-IPO companies** accelerated fastest in 2022 (79,373 cumulative)
- **425 companies** "recovered" after early-pandemic layoffs

## SQL Techniques Demonstrated

- Complex multi-step CTEs
- Window functions (RANK, DENSE_RANK, SUM OVER)
- Temporal set comparisons (NOT IN, NOT EXISTS)
- PARTITION BY with ORDER BY
- LEFT JOINs with COALESCE for NULL handling
- UNION ALL for combining result sets
- Date extraction and cross-year aggregation

## Related Files
- [layoffs_cleaning.sql](./layoffs_cleaning.sql) - Data cleaning process
- [exploratory_analysis.sql](./exploratory_analysis.sql) - Tutorial-based analysis
- [EXPLORATORY_README.md](./EXPLORATORY_README.md) - Exploratory analysis documentation

## Dataset
- **Source**: Layoffs 2020-2023
- **Companies**: 1,600+
- **Countries**: 50+
- **Time span**: March 2020 - March 2023
