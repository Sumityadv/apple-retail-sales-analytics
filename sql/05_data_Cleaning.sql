/*====================================================================
Project  : Apple Retail Sales Analytics
File     : 05_data_cleaning.sql
Purpose  : Business Rule Correction & Data cleaning
Author   : Sumit Yadav
====================================================================*/

SET search_path TO apple;

/*
BUSINESS RULE VALIDATION

Problem:
A product cannot be sold before its official launch date.

Validation Query:
*/

SELECT
    s.sale_id,
    p.product_id,
    p.product_name,
    p.launch_date,
    s.sale_date
FROM sales s
JOIN products p
    ON s.product_id = p.product_id
WHERE s.sale_date < p.launch_date;


/*
Observation

• Validation returned 66,030 records.
• This indicates a synthetic data generation issue rather than an ETL
  or data entry error.
• During data generation, sales were assigned independently of
  product launch dates, causing many sales to occur before launch.

Decision

Instead of modifying 66,030 sales records, the Product Master was
corrected by adjusting each product's launch date.

Business Assumption

Launch Date = 3 to 6 months before the product's first recorded sale.

Reason

• Only 146 product records require updating.
• Sales history remains unchanged.
• Product lifecycle analysis becomes valid.
• This follows a Master Data correction approach.
*/


/*
Preview New Launch Dates

Purpose:
Review the proposed launch dates before updating production data.
*/

SELECT
    p.product_id,
    p.product_name,
    p.launch_date AS old_launch_date,
    MIN(s.sale_date) AS first_sale,
    (
        MIN(s.sale_date)
        - ((FLOOR(RANDOM() * 4) + 3)::INT * INTERVAL '1 month')
    )::DATE AS new_launch_date
FROM products p
JOIN sales s
    ON p.product_id = s.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.launch_date
ORDER BY p.product_id;


/*
Update Product Launch Dates

Purpose:
Update launch dates to a random period of 3–6 months before
the first recorded sale.

Technique Used

• Common Table Expression (CTE)
• UPDATE ... FROM
• RANDOM()
*/

WITH product_launch_update AS
(
    SELECT
        p.product_id,
        (
            MIN(s.sale_date)
            - ((FLOOR(RANDOM() * 4) + 3)::INT * INTERVAL '1 month')
        )::DATE AS new_launch_date
    FROM products p
    JOIN sales s
        ON p.product_id = s.product_id
    GROUP BY p.product_id
)

UPDATE products p
SET launch_date = plu.new_launch_date
FROM product_launch_update plu
WHERE p.product_id = plu.product_id;


/*
Re-Validation

Expected Result:
0 Rows

Purpose:
Ensure no sales exist before the corresponding product launch date.
*/

SELECT
    s.sale_id,
    p.product_id,
    p.product_name,
    p.launch_date,
    s.sale_date
FROM sales s
JOIN products p
    ON s.product_id = p.product_id
WHERE s.sale_date < p.launch_date;


/*
Result

✓ Validation Passed Successfully

Business Rule Satisfied:
Every product sale now occurs on or after the product launch date.
*/


-- Check 1: Leading/trailing space check

SELECT * FROM products;

SELECT *
FROM stores
WHERE store_name <> TRIM(store_name)
		or city <> TRIM(city)
		or country <> TRIM(country);

SELECT * 
FROM products
WHERE product_name <> TRIM(product_name);

	-- HENCE WE HAVE NOT USED SO MUCH MESSY DATA SO I WILL STOP FOR ALL THE TABLE HERE.

-- Check 2: Inconsistent Text Case

SELECT DISTINCT product_name
FROM products
ORDER BY product_name;

--  if anything found then we will fix the captilisation by these function. INITCAP(),UPPER(),LOWER()

-- HENCE WE HAVE NOT USED SO MUCH MESSY DATA SO I WILL STOP FOR ALL THE TABLE HERE.

/*
At this point, Data Cleaning is complete.

we have covered:

NULL value verification
Foreign key integrity
Warranty date correction
Product launch date correction
Leading/trailing space check
Text case consistency check

*/


-- 		THIS PART HAS BEEN COMPLETED --














