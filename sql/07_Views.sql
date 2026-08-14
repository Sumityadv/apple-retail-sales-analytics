/*====================================================================
Project  : Apple Retail Sales Analytics
File     : 07_Views.sql
Purpose  : Create Views for Business Analytics & Reporting
Author   : Sumit Yadav
====================================================================*/

SET search_path TO apple;

-- VIEW 1 - ANALYTICAL VIEW


CREATE OR REPLACE VIEW vw_sales_details AS 
	SELECT
		s.sale_id,
		s.sale_date,
		s.quantity,
		p.product_id,
		p.product_name,
		p.price,
		c.category_name,
		st.store_id,
		st.store_name,
		st.city,
		st.country,
		w.claim_id,
		w.claim_date,
		w.repair_status,

		EXTRACT(YEAR FROM sale_date) AS sale_year,
		TO_CHAR(sale_date,'FMMonth') AS sale_month,
		TO_CHAR(sale_date,'FMDay') AS sale_day,
		EXTRACT(QUARTER FROM sale_date) AS sale_Quarter,

		(p.price * s.quantity) AS Revenue,

		(s.sale_date - p.launch_date) AS product_old_in_days,

		CASE 
			-- WHEN s.sale_id = w.sale_id THEN 'YES'  both are correct ways to get the reusult
			WHEN w.claim_id IS NOT NULL THEN 'YES'
			ELSE 'NO'
		END AS warranty_flag,

		(w.claim_date - s.sale_date) AS days_to_claim,

		CASE
			WHEN (p.price * s.quantity) < 500 THEN 'Entry_Level_Revenue'
			WHEN (p.price * s.quantity) >=500 AND (p.price * s.quantity) < 2500 THEN 'Low_Revenue'
			WHEN (p.price * s.quantity) >=2500 AND (p.price * s.quantity) < 10000 THEN 'Medium_Revenue'
			WHEN (p.price * s.quantity) >=10000 AND (p.price * s.quantity) < 30000 THEN 'High_Revenue'
			ELSE 'Premium_Revenue'
		END AS revenue_band,

		CASE
			WHEN s.quantity < 5 THEN 'Low_Volume'
			WHEN s.quantity >=5 AND s.quantity < 10 THEN 'Medium_Volume'
			ELSE 'High_Volume'
		END AS quantity_band,


		CASE
			WHEN price < 100 THEN 'Entry_Level'
			WHEN price >=100 AND price < 500 THEN 'Low_Range'
			WHEN price >=500 AND price < 1000 THEN 'Medium_Range'
			WHEN price >=1000 AND price < 2000 THEN 'High_Range'
			ELSE 'Premium_Range'
		END AS price_band


		
FROM sales s

INNER JOIN products p
ON s.product_id = p.product_id

INNER JOIN category c
ON p.category_id = c.category_id

INNER JOIN stores st
ON s.store_id = st.store_id

LEFT JOIN warranty w
ON s.sale_id = w.sale_id;



SELECT *
FROM vw_sales_details
LIMIT 10;


-- WE HAVE MADE AN ANALYTICAL VIEW OF SALES IN ONE PLACE WE HAVE JOINED ALL THE TABLES AND REQUIRED COLUMNS NOW WE CAN USE IT EVERYTIME.




-- VIEW 2 - STORE PERFORMANCE VIEW


CREATE OR REPLACE VIEW vw_store_performance AS 

	SELECT
		store_id,
		store_name,
		city,
		country,
		COUNT(sale_id) AS total_orders,
		SUM(quantity) AS total_products_sold,
		SUM(revenue)  total_revenue,
		ROUND(AVG (revenue),2)  AS average_order_value,
		COUNT(claim_id) AS total_warranty_claims,
		ROUND((COUNT(claim_id) * 100.0) / COUNT(sale_id),2) AS claim_rate,
		ROUND(AVG(product_old_in_days),2) AS average_product_age_days

FROM vw_sales_details 
GROUP BY store_id,
		 store_name,
		 city,
		 country;


-- SO HERE I WANT TO CHNAGE THE COLUMN NAME BUT IT WILL NOT CHANGE DIRECTLY YOU HAVE TO USE ALTER VIEW RENAME COLUMN 2. METHOD DROP THE VIEW THEN RERUN , IT SAVE TIME.

-- ALTER VIEW vw_store_performance RENAME COLUMN "total_claims_by_store" to "total_warranty_claims";

SELECT *
FROM vw_store_performance
LIMIT 10;



-- VIEW 3 - PRODUCT PERFORMANCE VIEW


CREATE OR REPLACE VIEW vw_product_performance AS 

	SELECT
		product_id,
		product_name,
		category_name,
		price,
		price_band,
		COUNT(sale_id) AS total_orders,
		SUM(quantity) AS total_products_sold,
		SUM(revenue)  AS total_revenue,
		ROUND(AVG (revenue),2)  AS average_order_value,
		COUNT(claim_id) AS total_warranty_claims,
		ROUND((COUNT(claim_id) * 100.0) / COUNT(sale_id),2) AS claim_rate,
		ROUND(AVG(product_old_in_days),2) AS average_product_age_days

FROM vw_sales_details 
GROUP BY product_id,
		 product_name,
		 category_name,
		 price,
		 price_band;


SELECT *
FROM vw_product_performance
LIMIT 10;


-- VIEW 4 - WARRANTY analysis VIEW

CREATE OR REPLACE VIEW vw_warranty_analysis AS 

	SELECT
		repair_status,
		COUNT(claim_id) AS total_claims,
		ROUND(AVG(days_to_claim),2) AS average_days_to_claim,
		MIN(days_to_claim) AS minimum_days_to_claim,
		MAX(days_to_claim) AS maximum_days_to_claim

FROM vw_sales_details 
GROUP BY repair_status;



SELECT *
FROM vw_warranty_analysis
LIMIT 10;


-- VIEW 5 - MONTHLY SALES VIEW


CREATE OR REPLACE VIEW vw_monthly_sales AS 

	SELECT
		sale_year,
		EXTRACT(MONTH FROM sale_date) AS month_number,
		sale_month,
		COUNT(sale_id) AS total_orders,
		SUM(quantity) AS total_products_sold,
		SUM(revenue)  AS total_revenue,
		ROUND(AVG (revenue),2)  AS average_order_value,
		COUNT(claim_id) AS total_warranty_claims,
		ROUND((COUNT(claim_id) * 100.0) / COUNT(sale_id),2) AS claim_rate

FROM vw_sales_details 
GROUP BY sale_year,
		 EXTRACT(MONTH FROM sale_date),
		 sale_month;

SELECT *
FROM vw_monthly_sales
LIMIT 10;



-- VIEW 6--
-- we are making a VIEW FROM EXISTING VIEW --

CREATE OR REPLACE VIEW vw_category_performance AS
		SELECT 
			s.category_name,
			s.quantity,
			s.store_id,
			s.store_name,
			s.city,
			s.country,
			p.claim_rate,
			s.sale_year,
			s.sale_month,
			s.revenue,
			s.revenue_band,
			s.quantity_band

		FROM vw_sales_details s
		JOIN vw_product_performance p
		ON s.product_id = p.product_id;

SELECT *
FROM vw_category_performance;



-- VIEWS PART HAS BEEN COMPLETED HERE --

