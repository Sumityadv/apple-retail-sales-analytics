/*
====================================================================
FILE: 10_triggers.sql
PROJECT: Apple Retail Sales Analytics
DATABASE: PostgreSQL
PHASE: Triggers
====================================================================

PURPOSE:
This file contains PostgreSQL trigger functions and triggers
developed for the Apple Retail Sales Analytics project.

Triggers are used to automatically execute predefined database
logic when specific events occur on project tables.

TRIGGER CONCEPTS COVERED:
1. Basic Trigger
2. BEFORE INSERT Trigger
3. BEFORE UPDATE Trigger
4. AFTER INSERT Trigger
5. AFTER UPDATE Trigger
6. Data Validation Triggers
7. Audit / Logging Triggers
8. Sales-related Triggers
9. Warranty-related Triggers
10. Trigger Testing and Validation

KEY CONCEPTS:
- Trigger Functions
- CREATE TRIGGER
- BEFORE / AFTER
- INSERT / UPDATE / DELETE
- FOR EACH ROW
- NEW and OLD records
- RETURN NEW
- RETURN OLD
- Automatic database actions

IMPORTANT:
A Trigger Function contains the logic that should be executed,
while the Trigger defines when that function should automatically
execute.

Unlike stored procedures, triggers are not called manually using
CALL. They are automatically fired when their defined database
event occurs.

PROJECT SAFETY:
Triggers that modify data will be tested carefully because they
can execute automatically whenever the associated INSERT, UPDATE,
or DELETE operation occurs.

Transaction testing using BEGIN, COMMIT, and ROLLBACK will be used
where appropriate to safely verify trigger behaviour.

====================================================================
*/



SET search_path TO apple;



-- TRIGGER 1 - BEFORE INSERT, REMOVE ALL LEADING AND TRAILING SPACES WHILE ADDING NEW ENTRY


-- we have to make trigger function every time so we can tell what to execute after trigger is called.

CREATE OR REPLACE FUNCTION fn_clean_product_name()
RETURNS TRIGGER
LANGUAGE plpgsql

AS
$$

BEGIN
	-- we have just trim the product name
	NEW.product_name := TRIM(NEW.product_name);

	RETURN NEW;
END;
$$;

-- we have made trigger and give funtion to execute


CREATE TRIGGER trg_trim_product_name
BEFORE INSERT ON products
FOR EACH ROW
EXECUTE FUNCTION fn_clean_product_name();


-- we have tested here

BEGIN;

INSERT INTO products (
    product_id,
    product_name,
    category_id,
    launch_date,
    price
)
VALUES (
    'TEST001',
    '   Test Product   ',
    'CAT001',
    '2026-08-01',
    999.99
);

SELECT *
FROM products
WHERE product_id = 'TEST001';



ROLLBACK;


SELECT * FROM products ORDER BY product_id DESC LIMIT 10;




-- TRIGGER 2 - UPDATE AN PRICE BEFORE UPDATE

CREATE OR REPLACE FUNCTION fn_update_price_before()
RETURNS TRIGGER

LANGUAGE plpgsql

AS
$$

DECLARE
    v_price_change NUMERIC(10,2);
BEGIN

    -- Calculate the difference between new and old price
    v_price_change := NEW.price - OLD.price;

    RAISE NOTICE
        'Product: %, Old Price: %, New Price: %, Price Change: %',
        NEW.product_id,
        OLD.price,
        NEW.price,
        v_price_change;

    RETURN NEW;

END;
$$;



CREATE TRIGGER trg_validate_product_price
BEFORE UPDATE OF price ON products
FOR EACH ROW
EXECUTE FUNCTION fn_update_price_before();


BEGIN;

UPDATE products
SET price = 1299.0
WHERE product_id = 'IP023';


ROLLBACK;

SELECT * FROM products LIMIT 100;



-- TRIGGER 3- USE OF AFTER IN TRIGGER 


CREATE OR REPLACE FUNCTION fn_sale_insert_notice()
RETURNS TRIGGER
LANGUAGE plpgsql

AS
$$

BEGIN

	RAISE NOTICE
		'New sale inserted: Sale ID = %, Sale Date = % , Store ID = %, Product ID = %, Quantity = %',
		NEW.sale_id,
		NEW.sale_date,
		NEW.store_id,
		NEW.product_id,
		NEW.quantity;

	RETURN NEW;

END;
$$;


CREATE TRIGGER trg_sale_insert_notice
AFTER INSERT ON sales
FOR EACH ROW
EXECUTE FUNCTION fn_sale_insert_notice();


BEGIN;

INSERT INTO sales (
    sale_id,
    sale_date,
    store_id,
    product_id,
    quantity
)
VALUES (
    'TEST002',
    '2026-08-18',
    'ST100',
    'IP023',
    2
);

ROLLBACK;



-- TRIGGER 4 - USE OF AFTER ON UPDATE


CREATE TABLE product_price_audit(
	audit_id SERIAL PRIMARY KEY,
	product_id VARCHAR,
	old_price NUMERIC(10,2),
	new_price NUMERIC(10,2),
	price_change NUMERIC(10,2),
	change_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE FUNCTION fn_product_price_audit()
RETURNS TRIGGER

LANGUAGE plpgsql

AS
$$

BEGIN
	INSERT INTO product_price_audit(
		product_id,
		old_price,
		new_price,
		price_change
	)
	VALUES(
		OLD.product_id,
		OLD.price,
		NEW.price,
		NEW.price - OLD.price
	);
	RETURN NEW;

END;
$$;


CREATE TRIGGER trg_product_price_audit
AFTER UPDATE OF price ON products
FOR EACH ROW
EXECUTE FUNCTION fn_product_price_audit();


BEGIN;

UPDATE products
SET price = 1099.99
WHERE product_id = 'IP027';

SELECT *
FROM product_price_audit
ORDER BY audit_id DESC
LIMIT 1;

ROLLBACK;





-- TRIGGER 5 - GET THE RECORD FOR EVERY  NEW SALE INSERTED


CREATE TABLE sales_audit(
	audit_id SERIAL PRIMARY KEY,
    sale_id VARCHAR,
    sale_date DATE,
    store_id VARCHAR,
    product_id VARCHAR,
    quantity INTEGER,
    inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE FUNCTION fn_sales_audit()
RETURNS TRIGGER

LANGUAGE plpgsql

AS
$$

BEGIN

	INSERT INTO sales(
		sale_id,
        sale_date,
        store_id,
        product_id,
        quantity
	)
	VALUES(
		NEW.sale_id,
        NEW.sale_date,
        NEW.store_id,
        NEW.product_id,
        NEW.quantity
	);

	RETURN NEW;

END;
$$;


CREATE TRIGGER trg_sales_audit
AFTER INSERT ON sales
FOR EACH ROW
EXECUTE FUNCTION fn_sales_audit();







-- TRIGGER 6 - WARRANTY DATA STORED


CREATE TABLE warranty_audit (
    audit_id SERIAL PRIMARY KEY,
    claim_id VARCHAR,
    claim_date DATE,
    sale_id VARCHAR,
    repair_status VARCHAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE FUNCTION fn_warranty_audit()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
BEGIN

    INSERT INTO warranty_audit (
        claim_id,
        claim_date,
        sale_id,
        repair_status
    )
    VALUES (
        NEW.claim_id,
        NEW.claim_date,
        NEW.sale_id,
        NEW.repair_status
    );

    RETURN NEW;

END;
$$;



CREATE TRIGGER trg_warranty_audit
AFTER INSERT ON warranty
FOR EACH ROW
EXECUTE FUNCTION fn_warranty_audit();



BEGIN;

INSERT INTO warranty (
    claim_id,
    claim_date,
    sale_id,
    repair_status
)
VALUES (
    'TESTCLM001',
    '2026-08-18',
    'SALE130000',
    'Pending'
);

SELECT *
FROM warranty_audit
WHERE claim_id = 'TESTCLM001';


ROLLBACK;




-- REVIEWING OUR ALL TRIGERS


-- CHECK ALL TRIGGER FUNCTION

SELECT
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'apple'
  AND routine_name LIKE 'fn_%'
ORDER BY routine_name;


-- CHECK ALL TRIGGERS

SELECT
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing,
    action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'apple'
ORDER BY event_object_table, trigger_name;


-- CHECK AUDIT TABLES

-- you will not see any audit rows because we hadn't commit any changes we had just all ROLLEDBACK
SELECT *
FROM sales_audit
ORDER BY audit_id;

SELECT *
FROM warranty_audit
ORDER BY audit_id;

SELECT *
FROM product_price_audit
ORDER BY audit_id;



-- ALL NEEDED TRIGGERS HAS BEEN COMPLETED HERE --























































	









	




















