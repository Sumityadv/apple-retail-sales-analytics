-- ==========================================
-- Project: Apple Retail Sales Analytics
-- File: 04_data_validation.sql
-- Purpose: Data Validation
-- ==========================================

SET search_path TO apple;

-- checking duplicates value for primary key

SELECT
	product_id, COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- checking duplicates value for primary key

SELECT 
	sale_id, COUNT(*) AS duplicate_count
FROM sales
GROUP BY sale_id
HAVING COUNT(*) > 1;

-- CHECKING NULL VALUES FOR CATEGORY TABLE 


SELECT *
FROM category
WHERE category_id IS NULL
OR category_name IS NULL;

-- CHECKING NULL VALUES FOR PRODUCTS TABLE

SELECT *
FROM products
WHERE product_id IS NULL
   OR product_name IS NULL
   OR category_id IS NULL
   OR launch_date IS NULL
   OR price IS NULL;

-- CHECKING NULL VALUES FOR STORES TABLE

SELECT *
FROM stores
WHERE store_id IS NULL
   OR store_name IS NULL
   OR city IS NULL
   OR country IS NULL;


-- CHECKING NULL VALUES FOR SALES TABLE

SELECT *
FROM sales
WHERE sale_id IS NULL
   OR sale_date IS NULL
   OR store_id IS NULL
   OR product_id IS NULL
   OR quantity IS NULL;

-- CHECKING NULL VALUES FOR WARRANTY TABLE

SELECT *
FROM warranty
WHERE claim_id IS NULL
   OR claim_date IS NULL
   OR sale_id IS NULL
   OR repair_status IS NULL;


-- CHECKING FOREIGN KEY INTEGRITY

-- Every category_id in products must exist in category.

SELECT *
FROM products p
LEFT JOIN category c
ON p.category_id = c.category_id
WHERE c.category_id IS NULL;



-- Every store_id in sales must exist in stores.

SELECT * 
FROM sales s
LEFT JOIN stores st
ON s.store_id = st.store_id
WHERE st.store_id IS NULL;

-- Every product_id in sales must exist in products.

SELECT *
FROM sales s
LEFT JOIN products p
ON s.product_id = p.product_id
WHERE p.product_id IS NULL;


-- Every sale_id in warranty must exist in sales.


SELECT *
FROM warranty w
LEFT JOIN sales s
ON w.sale_id = s.sale_id
WHERE s.sale_id IS NULL;


-- Validate Business Rule Validation
-- Warranty claim date is not before the sale date. ⭐ (Very important)



SELECT
    w.claim_id,
    w.sale_id,
    s.product_id,
    s.sale_date,
    w.claim_date,
    w.repair_status
FROM warranty w
JOIN sales s
ON w.sale_id = s.sale_id
WHERE w.claim_date < s.sale_date;

/* since there is one record showing claim date is prior to sale date,
now we will fix it by making same sale date to claim date.
*/

UPDATE warranty
SET claim_date = '2022-10-28'
WHERE claim_id = 'CLM005875';       

-- this is very simple way because there is one record.

UPDATE warranty
SET claim_date = (
    SELECT sale_date
    FROM sales
    WHERE sales.sale_id = warranty.sale_id
)
WHERE claim_date < (
    SELECT sale_date
    FROM sales
    WHERE sales.sale_id = warranty.sale_id
);

/* but supoose if there wre more records then we cant do it manually so it will fetch the sale date
from sales table and set the exact date to claim date. (USED SUBQUEIRES) */

-- Sales quantity is greater than 0.
SELECT sale_id,quantity
FROM sales
WHERE quantity <= 0;

-- Repair status contains only valid values.
SELECT DISTINCT repair_status 
FROM warranty;

SELECT claim_id,sale_id,repair_status
FROM warranty
WHERE repair_status NOT IN ('Rejected','Replaced','Completed','Pending','Warranty Void','Paid Repaired');

-- Launch date is not in the future.

SELECT p.product_id,s.sale_id,s.sale_date,p.launch_date
FROM sales s
JOIN products p
ON s.product_id = p.product_id
WHERE p.launch_date > s.sale_date;

SELECT p.product_id,s.sale_id,s.sale_date,p.launch_date
FROM sales s
JOIN products p
ON s.product_id = p.product_id
WHERE p.launch_date <= s.sale_date;

/*

Problem:
A product cannot be sold before its official launch date.

Observation

• Validation returned 66,030 records.
• This indicates a synthetic data generation issue rather than an ETL
  or data entry error.
• During data generation, sales were assigned independently of
  product launch dates, causing many sales to occur before launch.
  
	SEE NEXT PART ' 05_data_cleaning.csv'

*/

