/*
============================================================
PROJECT : Apple Retail Sales Analytics
FILE    : 09_stored_procedures.sql
PHASE   : Stored Procedures
PURPOSE : Business operations and reusable database actions
============================================================

SAFETY PROTOCOL
------------------------------------------------------------
1. Backup critical tables before testing data-modifying
   procedures.
2. Use BEGIN before executing a modifying procedure.
3. Verify the result using SELECT statements.
4. Use COMMIT only after successful verification.
5. Use ROLLBACK if the result is incorrect.
6. Add validation and exception handling to procedures
   wherever required.
============================================================
09_stored_procedures.sql

1. Basic procedure                    ← START HERE
2. Procedure with parameters
3. IF / ELSE procedure
4. Validation procedure
5. INSERT procedure
6. UPDATE procedure
7. Warranty processing procedure
8. Error handling
9. Transaction handling
10. Complete sales workflow

*/



SET search_path TO apple;


-- PROCEDURE 1 - CHNAGE WARRANTY STATUS TO COMPLETE


CREATE OR REPLACE PROCEDURE sp_complete_warranty_claim(p_claim_id VARCHAR)

LANGUAGE plpgsql

AS
$$

	BEGIN

		UPDATE warranty
		SET repair_status = 'Completed'
		WHERE claim_id = p_claim_id;


	END;
$$;

-- CALLING THE PROCEDURE WITH SAFETY TRANSACTION FEATURES (BEGIN,COMMIT,ROLLBACK) FOR SAFETY MEASURES --

BEGIN;																		-------------

CALL sp_complete_warranty_claim('CLM000029');							-- USE THIS PART AT EVERY CALLING --

SELECT * 
FROM warranty WHERE claim_id = 'CLM000029';									-------------



/* HERE WE FACED AN ISSUE AFTER CALLING THE PROCEDURE THEN RUNNING BY SELECT * FROM warranty DIDN'T SHOWING THAT COLUMN THAT DOESNT MEAN ITS DELETED ITS JUST 
   UPDATED NEWLY SO POSTGRESQL DOESNT GAURNATEE ABOUT THE ROWS WHILE THIS CODE. BUT IF YOU USE ORDER BY THEN IT WILL SHOW.
   
Why did a row appear in SELECT * FROM warranty before an
UPDATE, but apparently disappear from the displayed result
after the UPDATE using PROCEDURE?

ANSWER:
SELECT * FROM warranty does NOT guarantee the order in which
rows are returned because there is no ORDER BY clause.

Before the UPDATE, PostgreSQL happened to return the rows in
an order where CLM000023 was visible in the displayed result.

After the UPDATE, PostgreSQL could return the rows in a
different physical/execution order. Therefore, CLM000023
might no longer appear in the portion of rows displayed by
the SQL client. */






ROLLBACK;
-- VERIFYING IT HAS BEEN ROLLED BACK OR NOT

SELECT * FROM warranty ORDER BY claim_id LIMIT 30;

COMMIT;
-- VERIFYING FINAL --

SELECT * FROM warranty ORDER BY claim_id LIMIT 30;


SELECT * FROM warranty;






-- PROCEDURE 2- PROCEDURE WITH PARAMETER

/*

New sale details
       ↓
Is sale_id already present?
       ↓
Does store_id exist?
       ↓
Does product_id exist?
       ↓
Is quantity > 0?
       ↓
Does sale_date exist?
       ↓
Is sale_date >= product launch_date?
       ↓
INSERT sale



*/


CREATE OR REPLACE PROCEDURE sp_insert_sale(p_sale_id VARCHAR,
		p_sale_date DATE, 
		p_store_id VARCHAR, 
		p_product_id VARCHAR, 
		p_quantity INT
)

LANGUAGE plpgsql
AS
$$

DECLARE v_launch_date DATE;

BEGIN

	-- 1 CHECK FOR DUPLICATE SALE ID
	IF EXISTS ( 
		SELECT 1
		FROM sales
		WHERE sale_id = p_sale_id
	) THEN
		RAISE EXCEPTION 'Sale ID % already exists',p_sale_id;
	END IF;

	-- 2 CHECK FOR STORE ID
	IF NOT EXISTS(
		SELECT 1
		FROM stores
		WHERE store_id = p_store_id
	)THEN
		RAISE EXCEPTION 'Store ID % does not exists',p_store_id;
	END IF;


	-- 3 CHECK PRODUCT ID & GET LAUNCH DATE
	SELECT
	launch_date
	INTO v_launch_date
	FROM products
	WHERE product_id = p_product_id;

	IF NOT FOUND THEN
		RAISE EXCEPTION 'Peoduct ID % does not exist',p_product_id;
	END IF;

	-- 4 CHECK QUANTITY GREATER THAN 0

	IF p_quantity <=0 THEN
		RAISE EXCEPTION 'Quantity must be greater than 0.';
	END IF;

	-- 5 CHECK SALE DATE NULL

	IF p_sale_date IS NULL THEN
		RAISE EXCEPTION 'Sale Date cannot be NULL';
	END IF;


	-- 6 CHECK SALE DATE IS NOT PRIOR TO LAUNCH DATE

	IF p_sale_date < v_launch_date THEN
		RAISE EXCEPTION 'Sale Date % cannot be prior to launch date %',p_sale_date,v_launch_date;
	END IF;


	-- INSERT THE NEW SALE

	INSERT INTO sales
    (
        sale_id,
        sale_date,
        store_id,
        product_id,
        quantity
    )
    VALUES
    (
        p_sale_id,
        p_sale_date,
        p_store_id,
        p_product_id,
        p_quantity
    );

END;
$$;

DROP PROCEDURE sp_insert_sale;
	

BEGIN;

CALL sp_insert_sale(
    'SALE130001',
    '2024-10-11',
    'ST002',
    'IP027',
    3
);

SELECT *
FROM sales
WHERE sale_id = 'SALE130001';

COMMIT;



SELECT * FROM sales;






-- PROCEDURE 3 TO CHANGE THE QUANTITY

CREATE OR REPLACE PROCEDURE sp_update_sales_quantity(p_sale_id VARCHAR, p_new_quantity INT)
LANGUAGE plpgsql

AS
$$

BEGIN
	-- CHECK SALE EXISTS
	IF NOT EXISTS(
		SELECT 1
		FROM sales
		WHERE sale_id = p_sale_id
	)THEN
		RAISE EXCEPTION 'Sale ID % does not exists',p_sale_id;
	END IF;

	-- CEHCK NEW QUANTITY IS POSITIVE
	IF p_new_quantity <= 0 THEN
		RAISE EXCEPTION 'Quantity must be positive value';
	END IF;


	-- UPDATE THE QUANTITY

	UPDATE sales
	SET quantity = p_new_quantity
	WHERE sale_id = p_sale_id;
END;
$$;	

BEGIN;
	CALL sp_update_sales_quantity('SALE130001',5);

SELECT * FROM sales WHERE sale_id = 'SALE130001';

COMMIT;




-- PROCEDURE 4 TO INSERT WARRANTY CLAIM


CREATE OR REPLACE PROCEDURE sp_insert_warranty_claim(p_claim_id VARCHAR, p_claim_date DATE, p_sale_id VARCHAR, p_repair_status VARCHAR)
LANGUAGE plpgsql

AS
$$

DECLARE v_sale_date DATE;

BEGIN

	-- CHECK CLAIM ID EXISTS

	IF EXISTS(
		SELECT 1
		FROM warranty
		WHERE claim_id = p_claim_id
	)THEN
		RAISE EXCEPTION 'Claim ID % already exists',p_claim_id;
	END IF;

	-- CHECK CLAIM DATE IS ADVANCE THAN SALE DATE

	SELECT sale_date
	INTO v_sale_date
	FROM sales
	WHERE sale_id = p_sale_id;
	-- CHECK SALE ID IS EXISTS 
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Sale ID % is not exists',p_sale_id;
	END IF;

	-- CLAIM DATE CANNOT BE BEFORE SALE DATE

	IF p_claim_date < v_sale_date THEN
		RAISE EXCEPTION 'Claim date % cannot be before sale date %.',
            p_claim_date,
            v_sale_date;
    END IF;
	

	-- CLAIM DATE SHOULD BE IN 540 WARRANTY DAYS

	IF (p_claim_date - v_sale_date) > 540 THEN
		RAISE EXCEPTION 'Claim date % is beyond the 540-day warranty period.',
            p_claim_date;
    END IF;


	-- 5. Validate repair status
    IF p_repair_status NOT IN (
        'Completed',
        'Paid Repaired',
        'Pending',
        'Rejected',
        'Replaced',
        'Warranty Void'
    ) THEN
        RAISE EXCEPTION
            'Invalid repair status: %. Valid statuses are: Completed, Paid Repaired, Pending, Rejected, Replaced, Warranty Void.',
            p_repair_status;
    END IF;


	-- INSERT WARRANTY CLAIM

	INSERT INTO warranty
    (
        claim_id,
        claim_date,
        sale_id,
        repair_status
    )
    VALUES
    (
        p_claim_id,
        p_claim_date,
        p_sale_id,
        p_repair_status
    );

END;
$$;

SELECT * FROM warranty ORDER BY claim_id DESC LIMIT 10;


BEGIN;

CALL sp_insert_warranty_claim(
    'CLM020281',
    '2025-02-12',
    'SALE130001',
    'Completed'
);

SELECT *
FROM warranty
WHERE claim_id = 'CLM020281';

COMMIT;



SELECT * FROM warranty;



-- PROCEDURE 5 — PROCESS AN EXISTING WARRANTY CLAIM


CREATE OR REPLACE PROCEDURE sp_update_warranty_claim(p_claim_id VARCHAR, p_repair_status VARCHAR)
LANGUAGE plpgsql

AS
$$

BEGIN

	-- CLAIM EXISTS OR NOT
	IF NOT EXISTS(
		SELECT 1
		FROM warranty
		WHERE claim_id = p_claim_id
	)THEN
		RAISE EXCEPTION 'Claim ID % does not exist',p_claim_id;
	END IF;

	-- CHECK IS NEW WARRANTY STATUS ID VALID
	IF p_repair_status NOT IN (
		'Completed',
        'Paid Repaired',
        'Pending',
        'Rejected',
        'Replaced',
        'Warranty Void'
	)THEN
		RAISE EXCEPTION 'Invalid repair status: %. Valid statuses are: Completed, Paid Repaired, Pending, Rejected, Replaced, Warranty Void.',
            p_repair_status;
    END IF;


	-- UPDATE THE CLAIM

	UPDATE warranty
	SET repair_status = p_repair_status
	WHERE claim_id = p_claim_id;

END;
$$;


BEGIN;

CALL sp_update_warranty_claim('CLM000047','Replaced');

SELECT * FROM warranty WHERE claim_id = 'CLM000047';

COMMIT;


-- PROCEDURE 6 - ADD NEW PRODUCT

SELECT * FROM products;

CREATE OR REPLACE PROCEDURE sp_add_new_product(p_product_id VARCHAR, p_product_name VARCHAR, p_category_id VARCHAR, p_launch_date DATE, p_price NUMERIC(10,2))
LANGUAGE plpgsql

AS
$$

BEGIN

	IF EXISTS (
		SELECT 1
		FROM products
		WHERE product_id = p_product_id
	)THEN 
		RAISE EXCEPTION 'Product ID % already exist',p_product_id;
	END IF;


	-- CHECK PRODUCT NAME
	IF EXISTS(
		SELECT 1
		FROM products
		WHERE product_name = p_product_name
	)THEN
		RAISE EXCEPTION 'Product name % already exists',p_product_name;
	END IF;



	-- CHECK PRICE POSITIVE
	IF p_price <= 0 THEN
		RAISE EXCEPTION 'Price % should be in positive',p_price;
	END IF;


	-- INSERT NEW PRODUCT

	INSERT INTO products (
    product_id,
    product_name,
    category_id,
    launch_date,
    price
	)
	VALUES (
    p_product_id,
    p_product_name,
    p_category_id,
    p_launch_date,
    p_price
);

END;
$$;

	
BEGIN;

CALL sp_add_new_product('IP000','iPhone 17','CAT01','2025-10-22',0.00);

ROLLBACK;



-- PROCEDURE 7 UPDATE PRODUCT PRICE


CREATE OR REPLACE PROCEDURE sp_update_product_price(p_product_id VARCHAR, p_price NUMERIC(10,2))
LANGUAGE plpgsql

AS
$$

BEGIN

	IF NOT EXISTS(
		SELECT 1
		FROM products
		WHERE product_id = p_product_id
	)THEN
		RAISE EXCEPTION 'Product ID % does not exist',p_product_id;
	END IF;



	-- CHECK PRICE IS POSITIVE OR NOT
	IF p_price <= 0 THEN
		RAISE EXCEPTION 'Price % must be a positive value',p_price;
	END IF;



	-- UPDATE PRICE
	UPDATE products
	SET price = p_price
	WHERE product_id = p_product_id;

END;
$$;

SELECT * FROM products;

	
BEGIN;

CALL sp_update_product_price('MAC002',1499);

SELECT * FROM products WHERE product_id = 'MAC002';

COMMIT;



-- PROCEDURE 8 - ADD NEW STORE

SELECT * FROM stores;


CREATE OR REPLACE PROCEDURE sp_add_new_store(p_store_id VARCHAR, p_store_name VARCHAR, p_city VARCHAR, p_country VARCHAR)
LANGUAGE plpgsql

AS
$$

BEGIN

	IF EXISTS (
		SELECT 1
		FROM stores
		WHERE store_id = p_store_id
	)THEN
		RAISE EXCEPTION 'Store ID % already exist',p_store_id;
	END IF;



	-- CHECKI ONE STORE WITH SAME NAME IN A PARTICULAR CITY
	IF EXISTS (
		SELECT 1
		FROM stores
		WHERE store_name = p_store_name
		AND city = p_city
	)THEN 
		RAISE EXCEPTION 'Only 1 Store % allowed in a particular city % with same name',p_store_name,p_city;
	END IF;
	

	-- ADDING NEW ENTRIES
	INSERT INTO stores(
		store_id,
		store_name,
		city,
		country
	)
	VALUES(
		p_store_id, 
		p_store_name,
		p_city,
		p_country
	);

END;
$$;

BEGIN;

CALL sp_add_new_store('ST101','Apple Galaxy','Lucknow','India');

SELECT * FROM stores WHERE store_id = 'ST101';

ROLLBACK;

SELECT * FROM stores ORDER BY store_id DESC LIMIT 10;



-- PROCEDURE 9 - UPDATE STORE

CREATE OR REPLACE PROCEDURE sp_update_store(p_store_id VARCHAR, p_store_name VARCHAR, p_city VARCHAR, p_country VARCHAR)
LANGUAGE plpgsql

AS
$$

BEGIN


	-- CHECK STORE ID PRESENT OR NOT
	IF NOT EXISTS (
		SELECT 1
		FROM stores
		WHERE store_id = p_store_id
	)THEN
		RAISE EXCEPTION 'Store ID % does not exist',p_store_id;
	END IF;
	

	-- UPDATE THE STORE NAME
	
	UPDATE stores
	SET store_name = p_store_name,
		city = p_city,
		country = p_country
	WHERE store_id = p_store_id;

END;
$$;

BEGIN;

CALL sp_update_store('ST100','Apple Gallary','Lucknow','India');

ROLLBACK;

SELECT * FROM stores ORDER BY store_id DESC LIMIT 10;




-- STORED PROCEDURES HAS BEEN COMPLETED HERE --






































	


	








