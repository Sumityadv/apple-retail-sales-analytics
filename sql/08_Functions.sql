/*====================================================================
Project  : Apple Retail Sales Analytics
File     : 08_Function.sql
Purpose  : Create functions for Business Analytics & Reporting
Author   : Sumit Yadav
====================================================================*/

SET search_path TO apple;

-- (SCALER FUNCTION) --

-- FUNCTION 1 - TO GET THE REVENUE BY STORE

CREATE OR REPLACE FUNCTION fn_total_revenue_by_store(p_store_id VARCHAR)
RETURNS NUMERIC
LANGUAGE plpgsql

AS
$$

DECLARE 
	v_total_revenue NUMERIC;

BEGIN
	
	SELECT total_revenue
	INTO v_total_revenue
	FROM vw_store_performance
	WHERE store_id = p_store_id;

	RETURN v_total_revenue;

END;

$$;


SELECT fn_total_revenue_by_store('ST005');



-- FUNCTION 2- GET THE REVENUE BY PRODUCT ID --



CREATE OR REPLACE FUNCTION fn_total_revenue_by_product_id(p_product_id VARCHAR)

RETURNS NUMERIC
LANGUAGE plpgsql

AS
$$

DECLARE v_total_revenue NUMERIC;

BEGIN

	SELECT 
		total_revenue
		INTO v_total_revenue
		FROM vw_product_performance
		WHERE product_id = p_product_id;

		RETURN v_total_revenue;
END;
$$;


SELECT *
FROM fn_total_revenue_by_product_id('IP001');
SELECT * 
FROM vw_store_performance;




-- FUNCTION 3 - TOTAL ORDERS BY STORE  --


CREATE OR REPLACE FUNCTION fn_total_orders_by_store(p_store_id VARCHAR)
RETURNS TABLE
(
	store_id VARCHAR,
	store_name VARCHAR,
	city VARCHAR,
	country VARCHAR,
	total_orders BIGINT
)

LANGUAGE plpgsql

AS
$$

BEGIN

	RETURN QUERY

		SELECT  v.store_id,
				v.store_name,
				v.city,
				v.country,
				v.total_orders

		FROM vw_store_performance v
		WHERE v.store_id = p_store_id;

END;
$$;


SELECT *
FROM fn_total_orders_by_store('ST004');
SELECT * FROM vw_store_performance;



-- FUNCTION 4 - CLAIM RATE BY CATEGORY

CREATE OR REPLACE FUNCTION fn_claim_rate_by_category(p_category VARCHAR)
RETURNS NUMERIC

LANGUAGE plpgsql

AS
$$

	DECLARE v_claim_rate NUMERIC;
	
BEGIN

	SELECT claim_rate
	INTO v_claim_rate
	FROM vw_product_performance

	WHERE category_name = p_category;

	RETURN v_claim_rate;
END;
$$;

SELECT *
FROM fn_claim_rate_by_category('iPhone');


-- FUNCTION 5 - TO GET AVERAGE ORDER VALUE BY STORE

CREATE OR REPLACE FUNCTION fn_avg_order_value_by_store(p_store_id VARCHAR)
RETURNS NUMERIC

LANGUAGE plpgsql

AS
$$

	DECLARE v_avg_order_value NUMERIC;
	
BEGIN

	SELECT average_order_value
	INTO v_avg_order_value
	FROM vw_store_performance

	WHERE store_id = p_store_id;

	RETURN v_avg_order_value;
END;
$$;

SELECT *
FROM fn_avg_order_value_by_store('ST006');


-- 5 FUNCTIONS OF SCALER FUNCTIONS HAS BEEN MADE HERE --

-- (TABLE FUNCTION) --


-- FUNCTION 6 - GET PRODUCT PERFORMANCE BY PRODUCT ID ( USED TABLES RETURNS)

CREATE OR REPLACE FUNCTION fn_product_performance(p_product_id VARCHAR)

RETURNS TABLE
(
	product_id VARCHAR,
    product_name VARCHAR,
    category_name VARCHAR,
    price NUMERIC,
    price_band TEXT,
    total_orders BIGINT,
    total_products_sold BIGINT,
    total_revenue NUMERIC,
    average_order_value NUMERIC,
    total_warranty_claims BIGINT,
    claim_rate NUMERIC,
    average_product_age_days NUMERIC

)

LANGUAGE plpgsql

AS
$$

BEGIN 
	
	RETURN QUERY

	SELECT
		v.product_id,
        v.product_name,
        v.category_name,
        v.price,
        v.price_band,
        v.total_orders,
        v.total_products_sold,
        v.total_revenue,
        v.average_order_value,
        v.total_warranty_claims,
        v.claim_rate,
        v.average_product_age_days

	FROM vw_product_performance v

	WHERE v.product_id = p_product_id;

END;
$$;

SELECT *
FROM fn_product_performance('IP001');
SELECT * 
FROM vw_monthly_sales;


-- FUNCTION 7 - 

SELECT *
FROM vw_store_performance;

CREATE OR REPLACE FUNCTION fn_store_performance(p_store_id VARCHAR)
RETURNS TABLE (
	store_id VARCHAR,
	store_name VARCHAR,
	city VARCHAR,
	country VARCHAR,
	total_orders BIGINT,
	total_products_sold BIGINT,
	total_revenue NUMERIC,
	average_order_value NUMERIC,
	total_warranty_claims BIGINT,
	claim_rate NUMERIC

)
LANGUAGE plpgsql

AS
$$

BEGIN 
	RETURN QUERY

		SELECT
			v.store_id,
			v.store_name,
			v.city,
			v.country,
			v.total_orders,
			v.total_products_sold,
			v.total_revenue,
			v.average_order_value,
			v.total_warranty_claims ,
			v.claim_rate

		FROM vw_store_performance v

		WHERE v.store_id = p_store_id;
END;
$$;

SELECT *
FROM fn_store_performance('ST008');



-- FUNCTION 08 - TO GET THE REPAIR STATUS

SELECT *
FROM vw_warranty_analysis;


CREATE OR REPLACE FUNCTION fn_warranty_status(p_status VARCHAR)
RETURNS TABLE(
	repair_status VARCHAR,
	total_claims BIGINT,
	average_days_to_claim NUMERIC

)
LANGUAGE plpgsql

AS 
$$

	BEGIN

		RETURN QUERY
			SELECT
				v.repair_status,
				v.total_claims,
				v.average_days_to_claim

			FROM vw_warranty_analysis v
			WHERE v.repair_status = p_status;
	END;
$$;

SELECT *
FROM fn_warranty_status('Completed');


-- FUNCTION 09 - TO GET THE SALES BY CATEGORY -- this one is tricky

SELECT *
FROM vw_sales_details;

SELECT *
FROM vw_store_performance;

SELECT *
FROM vw_product_performance;

SELECT *
FROM vw_category_performance;


CREATE OR REPLACE FUNCTION fn_sales_by_category(p_category VARCHAR)
RETURNS TABLE(
	category_name VARCHAR,
	quantity BIGINT,
	country TEXT,
	claim_rate NUMERIC,
	sale_year NUMERIC,
	sale_month TEXT,
	revenue NUMERIC,
	revenue_band TEXT,
	quantity_band TEXT
)
LANGUAGE plpgsql

AS
$$

BEGIN

	RETURN QUERY

		SELECT
			v.category_name,
        	SUM(v.quantity),                 -- WE HAVE USED AGGREGATE FUNCTION BECAUSE COLUMN WILL GIVE MULTIPLE ROWS SO WE HAVE JUST USED THESE FUNCTION. FOR EVERY COLUMN
        	MAX(v.country),
        	MAX(v.claim_rate),
        	MAX(v.sale_year),
        	MAX(v.sale_month),
        	SUM(v.revenue),
        	MAX(v.revenue_band),
        	MAX(v.quantity_band)

			FROM vw_category_performance v

			WHERE v.category_name = p_category
			GROUP BY v.category_name;

		END;
$$;

SELECT *
FROM fn_sales_by_category('Mac');


-- 4 FUNCTIONS OF TABLE FUNCTIONS HAS BEEN MADE HERE --


-- (MULTI-PARAMETRIZED FUNCTION) --

-- FUNCTION 10 - TO GET THE MONTHLY SALES


CREATE FUNCTION fn_monthly_sales(p_year INT, p_month_number INT)

RETURNS TABLE (
	sale_year NUMERIC,
    month_number NUMERIC,
    sale_month TEXT,
    total_orders BIGINT,
    total_products_sold BIGINT,
    total_revenue NUMERIC,
    average_order_value NUMERIC,
    total_warranty_claims BIGINT,
    claim_rate NUMERIC
)

LANGUAGE plpgsql

AS
$$

BEGIN

	RETURN QUERY

		SELECT
        v.sale_year,
        v.month_number,
        v.sale_month,
        v.total_orders,
        v.total_products_sold,
        v.total_revenue,
        v.average_order_value,
        v.total_warranty_claims,
        v.claim_rate

		FROM vw_monthly_sales v

		WHERE v.sale_year = p_year 
		AND v.month_number = p_month_number;
END;
$$;


SELECT *
FROM fn_monthly_sales(2024, 7);


SELECT * FROM vw_sales_details;

-- FUNCTION 11 - TO GET THE SALES BETWEEN DATE RANGE


CREATE OR REPLACE FUNCTION fn_sales_between_dates(p_start_date DATE , p_end_date DATE)
RETURNS TABLE (
		sale_date DATE,
		sale_id VARCHAR,
		quantity INTEGER,
		product_id VARCHAR,
		product_name VARCHAR,
		price NUMERIC(10,2),
		category_name VARCHAR,
		store_id VARCHAR,
		store_name VARCHAR,
		city VARCHAR,
		country VARCHAR,
		claim_id VARCHAR,
		claim_date DATE,
		repair_status VARCHAR,
		sale_year NUMERIC,
		sale_month TEXT,
		sale_day TEXT,
		sale_quarter NUMERIC,
		revenue NUMERIC,
		product_old_in_days INT,
		warranty_flag TEXT,
		days_to_claim INT,
		revenue_band TEXT,
		quantity_band TEXT,
		price_band TEXT

)
LANGUAGE plpgsql

AS
$$

BEGIN
	RETURN QUERY
	
	SELECT
		v.sale_date,
		v.sale_id,
		v.quantity,
		v.product_id,
		v.product_name,
		v.price,
		v.category_name,
		v.store_id,
		v.store_name,
		v.city,
		v.country,
		v.claim_id,
		v.claim_date,
		v.repair_status,
		v.sale_year,
		v.sale_month,
		v.sale_day,
		v.sale_quarter,
		v.revenue,
		v.product_old_in_days,
		v.warranty_flag,
		v.days_to_claim,
		v.revenue_band,
		v.quantity_band,
		v.price_band

	FROM vw_sales_details v
	WHERE v.sale_date BETWEEN p_start_date AND p_end_date
	ORDER BY v.sale_date ASC;

END;
$$;

SELECT *
FROM fn_sales_between_dates('2024-07-01','2024-10-30');



-- FUNCTION 12 - TO GET THE SALES BY STORE ID FOR DATE RANGE 


CREATE OR REPLACE FUNCTION fn_store_sales_by_date(p_store_id VARCHAR, p_start_date DATE, p_end_date DATE)
RETURNS TABLE (
		sale_date DATE,
		store_id VARCHAR,
		store_name VARCHAR,
		city VARCHAR,
		country VARCHAR,
		sale_id VARCHAR,
		quantity INTEGER,
		product_id VARCHAR,
		product_name VARCHAR,
		price NUMERIC(10,2),
		category_name VARCHAR,
		claim_id VARCHAR,
		claim_date DATE,
		repair_status VARCHAR,
		sale_year NUMERIC,
		sale_month TEXT,
		sale_day TEXT,
		sale_quarter NUMERIC,
		revenue NUMERIC,
		product_old_in_days INT,
		warranty_flag TEXT,
		days_to_claim INT,
		revenue_band TEXT,
		quantity_band TEXT,
		price_band TEXT

)
LANGUAGE plpgsql

AS
$$

BEGIN
	RETURN QUERY
	
	SELECT
		v.sale_date,
		v.store_id,
		v.store_name,
		v.city,
		v.country,
		v.sale_id,
		v.quantity,
		v.product_id,
		v.product_name,
		v.price,
		v.category_name,
		v.claim_id,
		v.claim_date,
		v.repair_status,
		v.sale_year,
		v.sale_month,
		v.sale_day,
		v.sale_quarter,
		v.revenue,
		v.product_old_in_days,
		v.warranty_flag,
		v.days_to_claim,
		v.revenue_band,
		v.quantity_band,
		v.price_band

	FROM vw_sales_details v
	WHERE v.sale_date BETWEEN p_start_date AND p_end_date AND v.store_id = p_store_id
	ORDER BY v.sale_date ASC;

END;
$$;


SELECT *
FROM fn_store_sales_by_date('ST008','2024-07-01','2024-10-30');




-- FUNCTION 13 - TO GET THE SALES BY STORE ID and PRODUCT ID  


SELECT * FROM vw_sales_details;



CREATE OR REPLACE FUNCTION fn_product_sales_by_store_id_and_product_id (p_product_id VARCHAR, p_store_id VARCHAR)
RETURNS TABLE (
		product_id VARCHAR,
		store_id VARCHAR,
		sale_date DATE,
		sale_id VARCHAR,
		quantity INTEGER,
		product_name VARCHAR,
		price NUMERIC(10,2),
		category_name VARCHAR,
		store_name VARCHAR,
		city VARCHAR,
		country VARCHAR,
		claim_id VARCHAR,
		claim_date DATE,
		repair_status VARCHAR,
		sale_year NUMERIC,
		sale_month TEXT,
		sale_day TEXT,
		sale_quarter NUMERIC,
		revenue NUMERIC,
		product_old_in_days INT,
		warranty_flag TEXT,
		days_to_claim INT,
		revenue_band TEXT,
		quantity_band TEXT,
		price_band TEXT

)
LANGUAGE plpgsql

AS
$$

BEGIN
	RETURN QUERY
	
	SELECT
		v.product_id,
		v.store_id,
		v.sale_date,
		v.sale_id,
		v.quantity,
		v.product_name,
		v.price,
		v.category_name,
		v.store_name,
		v.city,
		v.country,
		v.claim_id,
		v.claim_date,
		v.repair_status,
		v.sale_year,
		v.sale_month,
		v.sale_day,
		v.sale_quarter,
		v.revenue,
		v.product_old_in_days,
		v.warranty_flag,
		v.days_to_claim,
		v.revenue_band,
		v.quantity_band,
		v.price_band

	FROM vw_sales_details v
	WHERE v.product_id = p_product_id
	AND v.store_id = p_store_id;

END;
$$;


SELECT * 
FROM fn_product_sales_by_store_id_and_product_id('IP073','ST010');





-- FUNCTION 14 - TOP 5 PRODUCTS SOLD BY CATEGORY




CREATE OR REPLACE FUNCTION fn_top_products( p_limit_n INT,p_category_name VARCHAR)
RETURNS TABLE
(
    product_id VARCHAR,
    product_name VARCHAR,
    category_name VARCHAR,
	price NUMERIC(10,2),
    total_orders BIGINT,
    total_products_sold BIGINT,
    total_revenue NUMERIC,
    average_order_value NUMERIC,
	total_warranty_claims BIGINT,
	claim_rate NUMERIC
)
LANGUAGE plpgsql
AS
$$
BEGIN

    RETURN QUERY

    SELECT
        v.product_id,
        v.product_name,
        v.category_name,
		v.price,
        v.total_orders,
        v.total_products_sold,
        v.total_revenue,
        v.average_order_value,
		v.total_warranty_claims,
		v.claim_rate

    FROM vw_product_performance v
	WHERE v.category_name = p_category_name
	ORDER BY v.total_products_sold DESC
	LIMIT p_limit_n;

END;
$$;

SELECT *
FROM fn_top_products(6,'iPhone');




-- FUNCTION 15 - TO GET THE STORE PERFORMANCE BY STORE ID AND PRODUCT ID


CREATE OR REPLACE FUNCTION fn_store_product_performance(p_store_id VARCHAR, p_product_id VARCHAR )
RETURNS TABLE(
		product_id VARCHAR,
		store_id VARCHAR,
		sale_date DATE,
		sale_id VARCHAR,
		quantity INTEGER,
		product_name VARCHAR,
		category_name VARCHAR,
		store_name VARCHAR,
		city VARCHAR,
		country VARCHAR,
		revenue NUMERIC,
		revenue_band TEXT,
		quantity_band TEXT,
		price_band TEXT

)
LANGUAGE plpgsql

AS 
$$

BEGIN

	 RETURN QUERY

		 SELECT
		v.product_id,
		v.store_id,
		v.sale_date,
		v.sale_id,
		v.quantity,
		v.product_name,
		v.category_name,
		v.store_name,
		v.city,
		v.country,
		v.revenue,
		v.revenue_band,
		v.quantity_band,
		v.price_band

		FROM vw_sales_details v
		WHERE v.product_id = p_product_id
		AND v.store_id = p_store_id;

	END;
$$;


SELECT * 
FROM fn_store_product_performance('ST004','IP073');



-- FUNCTIONS PART HAS BEEN DONE HERE --






















