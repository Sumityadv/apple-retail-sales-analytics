-- ==========================================
-- Project: Apple Retail Sales Analytics
-- File: 03_import_data.sql
-- Purpose: importing data from scv files
-- ==========================================

SET search_path TO apple;

COPY category
FROM 'E:\1Sumit\SQL Project\Apple Datasets\CSV_format\category_table_csv.csv'
DELIMITER ','
CSV HEADER;

SELECT COUNT(*)
FROM products;

COPY products
FROM 'E:\1Sumit\SQL Project\Apple Datasets\CSV_format\products_table_csv.csv'
DELIMITER ','
CSV HEADER;

COPY stores
FROM 'E:\1Sumit\SQL Project\Apple Datasets\CSV_format\stores_table_csv.csv'
DELIMITER ','
CSV HEADER;

COPY sales
FROM 'E:\1Sumit\SQL Project\Apple Datasets\CSV_format\sales_fact_table_csv.csv'
DELIMITER ','
CSV HEADER;

COPY warranty
FROM 'E:\1Sumit\SQL Project\Apple Datasets\CSV_format\warranty_table_csv.csv'
DELIMITER ','
CSV HEADER;