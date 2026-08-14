-- ==========================================
-- Project: Apple Retail Sales Analytics
-- File: 01_create_Database&Tables.sql
-- Purpose: Create Database and Tables schemas.
-- ==========================================
SET search_path TO apple;

 CREATE TABLE category(
	category_id VARCHAR(10) PRIMARY KEY NOT NULL,
	category_name VARCHAR(30) NOT NULL UNIQUE
);

ALTER TABLE category
ALTER category_id TYPE VARCHAR(30),
ALTER category_name TYPE VARCHAR(50)

SELECT * FROM category;
-- Category table has been made.

CREATE TABLE products(
	product_id VARCHAR(30) PRIMARY KEY,
	product_name VARCHAR(50) NOT NULL UNIQUE,
	category_id VARCHAR(30) REFERENCES category(category_id),
	launch_date DATE,
	price NUMERIC(10,2) CHECK(price>=0)
);

SELECT * FROM products;
-- Products table has been made.

CREATE TABLE stores(
	store_id VARCHAR(30) PRIMARY KEY UNIQUE,
	store_name VARCHAR(100) NOT NULL,
	city VARCHAR(50),
	country VARCHAR(50) NOT NULL
);

SELECT * FROM stores;
-- Stores table has been made.

CREATE TABLE sales(
	sale_id VARCHAR(30) PRIMARY KEY NOT NULL,
	sale_date DATE NOT NULL,
	store_id VARCHAR(30) REFERENCES stores(store_id) NOT NULL,
	product_id VARCHAR(30) REFERENCES products(product_id) NOT NULL,
	quantity INTEGER CHECK(quantity>0)
);

SELECT * FROM sales;
-- Sales table has been made.

CREATE TABLE warranty(
	claim_id VARCHAR(30) PRIMARY KEY NOT NULL,
	claim_date DATE NOT NULL,
	sale_id VARCHAR(30) REFERENCES sales(sale_id) NOT NULL UNIQUE,
	repair_status VARCHAR(50) CHECK(repair_status IN('Completed','Paid Repaired','Replaced','Warranty Void','Pending','Rejected'))NOT NULL
);

DROP TABLE warranty;

SELECT * FROM warranty;
-- Warranty table has been made.


