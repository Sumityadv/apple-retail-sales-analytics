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
BUSINESS ANALYSIS — BLUEPRINT

This is the blueprint we'll follow for the SQL Business Analysis phase of your Apple Retail project.

1. Filtering & Data Exploration
	WHERE
	AND / OR
	IN / NOT IN
	BETWEEN
	LIKE / NOT LIKE
	ILIKE
	IS NULL / IS NOT NULL
	DISTINCT
	ORDER BY
	LIMIT
2. Conditional Analysis
	CASE
	Business segmentation
	Conditional calculations
3. Aggregation & KPI Analysis
	COUNT
	SUM
	AVG
	MIN / MAX
	GROUP BY
	HAVING
	Revenue
	Units sold
	Average selling price
	Sales volume
4. JOIN-Based Business Analysis
	INNER JOIN
	LEFT JOIN
	Multi-table joins
	Sales + Products
	Sales + Stores
	Sales + Warranty
	Category-level analysis
	Avoiding duplicate/inflated results
5. Subqueries
	Scalar subqueries
	IN subqueries
	Correlated subqueries
	Above/below average analysis
	Comparison against maximum/minimum
6. CTEs
	Basic CTE
	Multiple CTEs
	CTE for intermediate calculations
	CTE-based business KPIs
	Making complex analysis readable
7. Window Functions ⭐
	ROW_NUMBER()
	RANK()
	DENSE_RANK()
	PARTITION BY
	ORDER BY inside OVER()
	Running totals
	Cumulative revenue
	Moving averages
8. Time-Series Analysis
	Monthly revenue
	Monthly sales volume
	LAG()
	LEAD()
	Month-over-month growth
	Year-over-year analysis if the dataset supports multiple years
9. Advanced Business Analytics
	Top-N analysis
	Top-N within category/store
	Revenue contribution %
	Product contribution
	Store contribution
	Ranking
	Pareto-style analysis
	Performance comparison
10. Final Business Questions

We'll then solve a sufficient set of non-repetitive, job-relevant business questions using the above techniques.

The goal isn't a fixed 25, 30, or 100 questions. We'll stop practicing a concept once you've demonstrated sufficient command of it and move toward multi-concept, 
realistic analyst problems.

11. Business Insights

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
SET
	SEARCH_PATH TO APPLE;

-- ALL THE BELOW 10 QUESTIONS ARE BASED ON THIS TOPICS --
 /* 1. Filtering & Data Exploration
	WHERE
	AND / OR
	IN / NOT IN
	BETWEEN
	LIKE / NOT LIKE
	ILIKE
	IS NULL / IS NOT NULL
	DISTINCT
	ORDER BY
	LIMIT
*/

-- Q1 - Find all products whose name contains the word "iPhone". Return the product ID, product name and price.
SELECT
	PRODUCT_ID,
	PRODUCT_NAME,
	PRICE
FROM
	PRODUCTS
WHERE
	PRODUCT_NAME ILIKE '%iPhone%';

-- Q2 - Find all products launched during 2025 with a price greater than 50,000. Return product_id, product_name, launch_date, and price.
SELECT
	PRODUCT_ID,
	PRODUCT_NAME,
	LAUNCH_DATE,
	PRICE
FROM
	PRODUCTS
WHERE
	PRICE > 1000
	AND LAUNCH_DATE BETWEEN '2019-01-01' AND '2019-12-31';

-- Q3 - Find all sales made from either of two specific stores.
SELECT
	*
FROM
	STORES;

SELECT
	*
FROM
	SALES;

SELECT
	*
FROM
	SALES
WHERE
	STORE_ID IN ('ST056', 'ST057');

-- Q4 - Find all warranty claims where the repair_status has not been recorded yet.
SELECT
	*
FROM
	WARRANTY;

SELECT
	CLAIM_ID,
	CLAIM_DATE,
	SALE_ID,
	REPAIR_STATUS
FROM
	WARRANTY
WHERE
	REPAIR_STATUS IS NULL;

-- Q5 - Find the distinct product IDs that have been sold in the sales table.
SELECT DISTINCT
	PRODUCT_ID
FROM
	SALES;

-- Q6 - Find the 5 most expensive products in the Apple product catalog.
SELECT
	PRODUCT_ID,
	PRODUCT_NAME,
	PRICE
FROM
	PRODUCTS
ORDER BY
	PRICE DESC
LIMIT
	5;

/*
  Q7. Find all sales made by stores ST056, ST057, or ST058 where the quantity sold is greater than 2,
return sale_id, store_id, product_id, and quantity; sort by quantity descending.
*/

SELECT sale_id,
		store_id,
		product_id,
		quantity
FROM sales
WHERE store_id IN ('ST056','ST057','ST058')
AND quantity > 2
ORDER BY quantity DESC;



/*
Q8. Find all products that are not in category CAT001 or CAT002 and have a price between $500 and $2,000,
return product_id, product_name, category_id, and price; sort by price ascending.
*/


SELECT product_id,
		product_name,
		category_id,
		price
FROM products
WHERE category_id NOT IN ('CAT001','CAT002')
AND price BETWEEN 500 AND 2000
ORDER BY price ASC;



/*
Q9. Find all products whose name contains "Pro" but does not contain "Max",
return product_id, product_name, and price; sort by price descending and return only the top 10 results.
*/


SELECT product_id,
		product_name,
		price
FROM products
WHERE product_name LIKE '%Pro%' 
AND product_name NOT LIKE '%Max%'
ORDER BY price DESC LIMIT 10;



/*
Q10. Find all sales where either the quantity is greater than 5 or the sale date falls within the first quarter of 2019, and where the store_id is not ST001,
return sale_id, sale_date, store_id, product_id, and quantity; sort by sale_date ascending.
*/

SELECT sale_id,
		sale_date,
		store_id,
		product_id,
		quantity
FROM sales
WHERE ( quantity > 5
OR sale_date BETWEEN '2019-01-01' AND '2019-03-31')
AND store_id NOT IN ('ST001')
ORDER BY sale_date ASC;

-- this is the second and best way to solve this question

SELECT sale_id,
		sale_date,
		store_id,
		product_id,
		quantity
FROM sales
WHERE ( quantity > 5
OR EXTRACT(YEAR FROM sale_date) = 2019
AND EXTRACT(QUARTER FROM sale_date) = 1 )
AND store_id NOT IN ('ST001')
ORDER BY sale_date ASC;

-- this is the third way to get this.

SELECT sale_id,
		sale_date,
		store_id,
		product_id,
		quantity
FROM sales
WHERE ( quantity > 5
OR DATE_TRUNC('quarter', sale_date) = DATE '2019-01-01' )
AND store_id NOT IN ('ST001')
ORDER BY sale_date ASC;


-- ALL THE BELOW 6 FROM 11 TO 16 QUESTIONS ARE BASED ON THIS TOPICS --
/*
2. Conditional Analysis
	CASE
	Business segmentation
	Conditional calculations


Q11. Classify each product into three price categories based on its price:
"Budget" for products below $500,
"Mid-Range" for products from $500 to $1,500,
and "Premium" for products above $1,500;
return product_id, product_name, price, and price_category.
*/


SELECT product_id,
		product_name,
		price,
		CASE
			WHEN price < 500 THEN 'Budget'
			WHEN price >= 500 AND price < 1500 THEN 'Mid-Range'
			ELSE 'Premium'
		END AS price_category
FROM products;



/*
Q12. Classify each product based on its price as "Low", "Medium", or "High";
use $300 and $1,000 as the boundaries;
return product_id, product_name, price, and price_segment;
make sure products priced exactly at the boundaries are classified consistently.
*/



SELECT product_id,
		product_name,
		price,
		CASE
			WHEN price < 300 THEN 'Low'
			WHEN price >= 300 AND price < 1000 THEN 'Medium'
			ELSE 'Premium'
		END AS price_segment
FROM products;


/*
Q13. Classify each sale as "Small", "Medium", or "Large" based on the quantity sold;
classify quantities of 1–2 as "Small", 3–5 as "Medium", and quantities above 5 as "Large";
return sale_id, product_id, quantity, and sale_size.
*/


SELECT sale_id,
		product_id,
		quantity,
		CASE
			WHEN quantity < 2 THEN 'Small'
			WHEN quantity >= 2 AND quantity < 5 THEN 'Medium'
			ELSE 'Large'
		END sale_size
FROM sales;


/*
Q14. Identify products as "Recently Launched" if their launch date is in the last 3 months of the available dataset period, otherwise classify them as "Existing";
return product_id, product_name, launch_date, and product_status.
*/



SELECT MAX(launch_date) AS launch_date_method FROM products;
SELECT MIN(launch_date) AS launch_date_method_2 FROM products;

SELECT product_id,
		product_name,
		launch_date,
		CASE
			WHEN launch_date >= (SELECT MAX(launch_date) - INTERVAL '3 months' FROM products ) THEN 'Recently_Launched'
			ELSE 'Existing'
		END AS product_status
FROM products;




/*
Q15. Classify each product into "Affordable" if its price is below the average product price, "Premium" if its price is above the average product price, 
and "Average" if its price equals the average product price;
return product_id, product_name, price, and price_segment.
*/




SELECT product_id,
		product_name,
		price,
		(SELECT ROUND(AVG(price),2) AS average FROM products),
		CASE
			WHEN price < (SELECT AVG(price) FROM products) THEN 'Afforadable'
			WHEN price = (SELECT AVG(price) FROM products) THEN 'Average'
			ELSE 'Premium'
		END AS price_segment
FROM products;






/*
Q16. Classify each product as "Entry-Level", "Standard", or "Flagship" based on its price, using $300 and $1,500 as the classification boundaries;
return product_id, product_name, price, and product_tier;
sort the results by price descending.
*/



SELECT product_id,
		product_name,
		price,
		CASE
			WHEN price < 300 THEN 'Entry_Level'
			WHEN price >= 300 AND price < 1000 THEN 'Standard'
			ELSE 'Flagship'
		END AS price_tier
FROM products
ORDER BY price DESC;




-- ALL THE BELOW 8 FROM 17 TO 24 QUESTIONS ARE BASED ON THIS TOPICS --
/*
Aggregation & KPI Analysis
	COUNT
	SUM
	AVG
	MIN / MAX
	GROUP BY
	HAVING
	Revenue
	Units sold
	Average selling price
	Sales volume


Q17. Calculate the total number of sales and total units sold for each product;
return product_id, total_sales, and total_units_sold;
sort by total_units_sold from highest to lowest.
*/
















































