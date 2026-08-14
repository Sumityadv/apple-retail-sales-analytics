/*====================================================================
Project  : Apple Retail Sales Analytics
File     : 06_data_Transformation.sql
Purpose  : Business ready KPIs
Author   : Sumit Yadav
====================================================================*/

SET search_path TO apple;


SELECT * FROM sales;

-- Transformation 1 - Analytical View of sales

SELECT  sale_id,
		sale_date,
		EXTRACT(YEAR FROM sale_date) AS sale_year,
		TO_CHAR(sale_date,'FMMonth') AS sale_month,
		TO_CHAR(sale_date,'FMDay') AS sale_day,
		EXTRACT(QUARTER FROM sale_date) AS sale_Quarter
FROM sales;

-- WE HAVE USED FMMONTH IN 'TO_CHAR(sale_date,'FMMonth') AS sale_month,' BECAUSE IT REMOVE EXTRA SPACES TRALING FM= FILL MODE

SELECT * FROM products;

-- Transformation 2 - To get the revenue 

SELECT 
		s.sale_id,
		s.sale_date,
		p.product_name,
		p.price,
		s.quantity,
		(p.price * s.quantity) AS Revenue_in_$
FROM sales s
JOIN products p
ON s.product_id = p.product_id;


-- Transformation 3 - to get the age of products

SELECT 
		s.sale_id,
		p.product_name,
		s.sale_date,
		p.launch_date,
		(s.sale_date - p.launch_date) AS product_old_in_days
FROM sales s
JOIN products p
ON s.product_id = p.product_id;


-- Transformation 4 - to get the warranty flag (in warranty/not in warranty)

SELECT
		s.sale_id,
		w.claim_id,
		s.sale_date,
		CASE 
			-- WHEN s.sale_id = w.sale_id THEN 'YES'  both are correct ways to get the reusult
			WHEN w.claim_id IS NOT NULL THEN 'YES'
			ELSE 'NO'
		END AS warranty_flag
FROM sales s
LEFT JOIN warranty w
ON s.sale_id = w.sale_id;

-- Transformation 5 – Warranty Intelligence

SELECT
		s.sale_id,
		s.sale_date,
		w.claim_id,
		(w.claim_date - s.sale_date) AS days_to_claim
FROM sales s
JOIN warranty w
ON s.sale_id = w.sale_id;


-- Transformation 6 – Claim Within 180 Days (yes/no)


SELECT
		s.sale_id,
		s.sale_date,
		w.claim_id,
		(w.claim_date - s.sale_date) AS days_to_claim,
		CASE
			WHEN (w.claim_date - s.sale_date) <= 180 THEN 'Yes'
			ELSE 'No'
		END AS claim_within_180_days
FROM sales s
JOIN warranty w
ON s.sale_id = w.sale_id;



-- Transformation 7 – Revenue Segmentation by groups


SELECT 
		s.sale_id,
		s.sale_date,
		p.product_name,
		(p.price * s.quantity) AS revenue,
		CASE
			WHEN (p.price * s.quantity) < 500 THEN 'Entry_Level_Revenue'
			WHEN (p.price * s.quantity) >=500 AND (p.price * s.quantity) < 2500 THEN 'Low_Revenue'
			WHEN (p.price * s.quantity) >=2500 AND (p.price * s.quantity) < 10000 THEN 'Medium_Revenue'
			WHEN (p.price * s.quantity) >=10000 AND (p.price * s.quantity) < 30000 THEN 'High_Revenue'
			ELSE 'Premium_Revenue'
		END AS revenue_band
FROM sales s
JOIN products p
ON s.product_id = p.product_id;


-- Transformation 8 – Quantity Segmentation by groups

SELECT 
		s.sale_id,
		s.sale_date,
		p.product_name,
		s.quantity,
		CASE
			WHEN s.quantity < 5 THEN 'Low_Volume'
			WHEN s.quantity >=5 AND s.quantity < 10 THEN 'Medium_Volume'
			ELSE 'High_Volume'
		END AS quantity_band
FROM sales s
JOIN products p
ON s.product_id = p.product_id;



-- Transformation 9 – Product Price Segmentation


SELECT 
		product_id,
		product_name,
		price,
		CASE
			WHEN price < 100 THEN 'Entry_Level'
			WHEN price >=100 AND price < 500 THEN 'Low_Range'
			WHEN price >=500 AND price < 1000 THEN 'Medium_Range'
			WHEN price >=1000 AND price < 2000 THEN 'High_Range'
			ELSE 'Premium_Range'
		END AS price_band
FROM products;



-- DATA TRANSFORMATION HAS BEEN COMPLETED --





