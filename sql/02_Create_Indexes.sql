-- ==========================================
-- Project: Apple Retail Sales Analytics
-- File: 03_create_indexes.sql
-- Purpose: Create indexes for query optimization
-- ==========================================

-- Sales Table Indexes

-- Products Table Indexes

-- Warranty Table Indexes

SET search_path TO apple;

CREATE INDEX idx_sales_product
ON sales(product_id);

-- index on product id is made

CREATE INDEX idx_sales_store
ON stores(store_id);

-- index on sales id is made

CREATE INDEX idx_sales_date
ON sales(sale_date);

-- index on sale_date id is made

