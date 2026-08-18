/*
====================================================================
FILE: 11_business_analysis.sql
PROJECT: Apple Retail Sales Analytics
DATABASE: PostgreSQL
PHASE: Business Analysis
====================================================================

PURPOSE:
This file contains SQL-based business analysis performed on the
Apple Retail Sales Analytics database.

The objective is to convert transactional data into meaningful
business insights related to sales, revenue, products, stores,
customers, pricing, and warranty performance.

TOPICS COVERED:
1. Filtering and Data Exploration
2. LIKE / NOT LIKE / ILIKE
3. CASE Expressions
4. Aggregations
5. GROUP BY / HAVING
6. JOINs
7. Subqueries
8. CTEs
9. Window Functions
10. Ranking
11. Running Totals
12. Percentage Contribution
13. LAG / LEAD
14. Period-over-Period Analysis
15. Business KPI Analysis

KEY BUSINESS AREAS:
- Sales Performance
- Revenue Analysis
- Product Performance
- Store Performance
- Pricing Analysis
- Monthly Trends
- Warranty Analysis
- Business KPI Evaluation

ANALYTICAL APPROACH:
Business questions are converted into SQL queries using
filtering, aggregation, joins, subqueries, CTEs, and window
functions to generate measurable business insights.

IMPORTANT:
Queries in this file are analytical and do not modify the
underlying transactional data unless explicitly stated.

====================================================================
*/


SET search_path TO apple;

-- Q1 - Find all products whose name contains the word "iPhone". Return the product ID, product name and price.


SELECT product_id,product_name,price 
FROM products
WHERE product_name ILIKE '%iPhone%';


-- Q2 - Find all products launched during 2025 with a price greater than 50,000. Return product_id, product_name, launch_date, and price.

SELECT product_id,product_name,launch_date,price
FROM products
WHERE price > 1000
AND launch_date BETWEEN '2019-01-01' AND '2019-12-31';



-- Q3 - Find all sales made from either of two specific stores.


























