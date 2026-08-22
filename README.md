# Apple Retail Sales Analytics

**Status:**  Under Development — Expected completion: Tuesday, 25 August 2026

An end-to-end retail sales analytics project built using **PostgreSQL, SQL, and Power BI**.

The project is focused on analysing sales, products, stores, revenue, and warranty activity from a retail business perspective. The main objective is not just to write SQL queries, but to build the complete workflow — starting from raw data and database design and moving towards business analysis and an interactive Power BI dashboard.

> **Note:** The project is currently under development. The GitHub repository and supporting files will be updated phase by phase as the project progresses.

---

## 1. Project Overview

Retail businesses generate a large amount of transactional data, but raw sales data by itself does not provide much business value.

This project takes a retail sales dataset and turns it into a structured analytical system using PostgreSQL. The data is cleaned, validated, transformed and organised into reusable database objects before being used for business analysis and Power BI reporting.

The project covers areas such as:

* Sales and revenue performance
* Product performance
* Store performance
* Quantity and order analysis
* Product pricing and segmentation
* Warranty claims
* Monthly sales trends
* Business KPIs
* Advanced SQL analysis
* Power BI reporting

The project is being developed in phases so that every stage can be checked and documented before moving to the next one.

---

## 2. Objectives

The main objectives of the project are:

1. Build a properly structured relational database for retail sales data.
2. Understand and validate the raw dataset before analysis.
3. Clean and transform the data using SQL.
4. Create reusable SQL views for analytical reporting.
5. Build PostgreSQL functions for reusable business calculations.
6. Develop stored procedures for controlled database operations.
7. Use triggers for database-level automation and validation.
8. Perform detailed business analysis using SQL.
9. Build an interactive Power BI dashboard.
10. Convert the analysis into useful business insights and recommendations.

---

## 3. Tools & Technologies

| Tool             | Purpose                                                   |
| ---------------- | --------------------------------------------------------- |
| **PostgreSQL**   | Database management and SQL analysis                      |
| **SQL**          | Data validation, cleaning, transformation and analysis    |
| **Power BI**     | Interactive dashboard and reporting                       |
| **GitHub**       | Version control and project documentation                 |
| **Google Drive** | Supporting files, dashboard screenshots and documentation |

---

## 4. Project Workflow

The project follows an end-to-end workflow:

```text
Raw Dataset
     ↓
Data Understanding
     ↓
Database Design
     ↓
Create Database & Tables
     ↓
Import Raw Data
     ↓
Data Validation
     ↓
Data Cleaning
     ↓
Data Transformation
     ↓
Views
     ↓
Functions
     ↓
Stored Procedures
     ↓
Triggers
     ↓
Business Analysis
     ↓
Power BI Dashboard
     ↓
Business Insights
     ↓
Documentation
```

The workflow is being completed incrementally rather than doing the dashboard or analysis directly on the raw dataset.

---

## 5. Dataset

The project uses a retail sales dataset containing transactional sales information along with product, store and warranty-related information.

The product catalogue currently contains **146 products**, with product prices maintained in **US dollars (USD)**.

The dataset includes different types of Apple products and accessories, with information that can be used to analyse:

* Product sales
* Selling price
* Quantity sold
* Revenue
* Store performance
* Sales dates
* Warranty claims
* Claim status
* Time taken to raise warranty claims

The exact table structure and data dictionary will be documented separately as the database phase is finalised.

---

## 6. Database Development

The database was designed before beginning the analytical work.

The development process includes:

### Data Validation

Initial checks were performed to identify:

* Missing values
* Duplicate records
* Invalid values
* Incorrect data types
* Unexpected categories
* Referential integrity issues

### Data Cleaning

Cleaning operations were performed where required without unnecessarily modifying valid business data.

### Data Transformation

The transformation phase includes creating analytical fields and classifications such as:

* Sale year
* Sale month
* Sale day
* Sale quarter
* Product age
* Warranty status
* Days to warranty claim
* Warranty claim eligibility
* Revenue bands
* Quantity bands
* Price bands

The transformations are designed to make later analysis easier and more consistent.

---

## 7. SQL Views

Reusable views were created to avoid repeatedly writing the same joins and aggregations.

Current analytical views include:

```text
vw_sales_details
vw_store_performance
vw_product_performance
vw_warranty_analysis
vw_monthly_sales
```

### `vw_sales_details`

Acts as the main analytical sales view by combining the required information from the underlying tables.

It provides the base for several downstream analytical views.

### `vw_store_performance`

Provides store-level KPIs such as:

* Total orders
* Total quantity sold
* Total revenue
* Average order value
* Warranty claims

### `vw_product_performance`

Provides product-level KPIs including:

* Total orders
* Products sold
* Revenue
* Average order value
* Warranty claims
* Claim rate
* Product age

### `vw_warranty_analysis`

Used to analyse warranty activity, including claim timing and repair status.

### `vw_monthly_sales`

Provides monthly sales-level metrics such as:

* Total orders
* Products sold
* Revenue
* Average order value
* Warranty claims
* Claim rate

---

## 8. PostgreSQL Functions

The project also includes reusable PostgreSQL functions for commonly required business calculations.

Functions have been designed around three main patterns:

### Scalar Functions

Return a single value.

Examples include:

```text
fn_total_revenue_by_store()
fn_total_revenue_by_product()
fn_total_orders_by_store()
fn_claim_rate_by_product()
fn_average_order_value_by_store()
```

### Table-Returning Functions

Return multiple rows and columns.

Examples include functions for:

```text
Product performance
Store performance
Monthly sales
Warranty analysis
Category sales
```

### Parameterised Business Functions

Accept one or more business parameters to make the analysis reusable.

Examples include:

```text
Sales between dates
Store sales for a date range
Product sales by store
Top N products by category
Store-product performance
```

The functions are being developed around actual business requirements rather than being created only to demonstrate SQL syntax.

---

## 9. Stored Procedures

The stored procedure phase is currently in progress.

The purpose of this phase is to handle controlled database operations rather than only returning analytical results.

The planned procedures cover areas such as:

* Updating warranty claim status
* Inserting sales
* Updating records
* Validating business conditions
* Processing warranty claims
* Handling errors
* Using transactions safely

The first procedure has already been created:

```text
sp_complete_warranty_claim()
```

It updates the repair status of a selected warranty claim.

Transactions using:

```sql
BEGIN;
COMMIT;
ROLLBACK;
```

are also being used when testing procedures that modify the main dataset.

---

## 10. Triggers

Triggers will be added after completing the stored procedure phase.

The planned trigger work includes:

* Validation before data changes
* Automatic database actions
* Audit-related operations
* Sales-related automation
* Warranty-related automation

The final trigger list will be documented after implementation.

---

## 11. Business Analysis

After completing the database object layer, the project will move into detailed business analysis.

The analysis will cover:

### Sales & Revenue

* Total revenue
* Monthly revenue
* Revenue by product
* Revenue by category
* Revenue by store
* Revenue contribution
* Average order value
* Sales trends

### Product Performance

* Best-selling products
* Highest-revenue products
* Lowest-performing products
* Quantity sold
* Price-band performance
* Category performance

### Store Performance

* Top-performing stores
* Low-performing stores
* Store revenue
* Store order volume
* Average order value
* Warranty claim performance

### Warranty

* Total warranty claims
* Claim rate
* Claims by product
* Claims by store
* Repair status
* Days to claim
* Warranty performance

Advanced SQL techniques will also be used where appropriate, including:

* CTEs
* Subqueries
* Window functions
* Ranking
* Running totals
* Percentage contribution
* Month-over-month analysis
* Year-over-year analysis

---

## 12. Power BI Dashboard

The final SQL output will be connected to Power BI to create an interactive reporting layer.

The planned dashboard will contain multiple pages covering:

### Executive Overview

Key KPIs and overall business performance.

### Sales & Revenue

Revenue trends, product/category performance and sales contribution.

### Product Analysis

Product rankings, quantity sold, revenue and pricing segmentation.

### Store & Geographic Analysis

Store-level and location-level performance.

### Warranty Analysis

Warranty claims, claim rates, repair status and claim timing.

The dashboard will also include appropriate slicers, KPIs, drill-throughs and interactive reporting features.

---

## 13. Project Documentation

The final documentation will include:

* Project overview
* Business problem
* Objectives
* Dataset information
* Database design
* Data dictionary
* Data cleaning process
* Data transformation process
* SQL views
* Functions
* Stored procedures
* Triggers
* Business analysis
* Power BI dashboard
* Key insights
* Business recommendations
* Future scope

Supporting documentation and dashboard screenshots will be maintained separately.

---

## 14. Repository Structure

The repository will be organised approximately as follows:

```text
apple-retail-sales-analytics/
│
├── README.md
│
├── sql/
│   ├── 01_database_schema.sql
│   ├── 02_data_import.sql
│   ├── 03_data_validation.sql
│   ├── 04_data_cleaning.sql
│   ├── 05_data_transformation.sql
│   ├── 06_views.sql
│   ├── 07_data_objects.sql
│   ├── 08_functions.sql
│   ├── 09_stored_procedures.sql
│   ├── 10_triggers.sql
│   └── 11_business_analysis.sql
│
├── documentation/
│   ├── project_documentation.pdf
│   └── data_dictionary.xlsx
│
├── powerbi/
│   └── Apple_Retail_Analytics.pbix
│
├── screenshots/
│   └── dashboard/
│
└── data/
    └── raw/
```

The structure will be updated if additional files are introduced during development.

---

## 15. Project Resources

### GitHub Repository

**Coming soon — repository is currently under development.**

### Project Documentation & Dashboard Screenshots

**Google Drive:** Coming soon

The links will be added once the repository and supporting documentation are ready.

---

## 16. Current Status

```text
Database Design
Data Import 
Data Validation 
Data Cleaning
Data Transformation 
Views 
Functions  
Stored Procedures 
Triggers   
Business Analysis  
Power BI Dashboard  
Documentation 
GitHub Repository 
```

> **Project Status: Under Development**
>
> The project is currently being developed phase by phase and is expected to be completed by **Monday, 17 August 2026**. The repository and supporting files will be updated as each phase is completed.

---

## 17. Future Scope

Once the core project is completed, the analysis can be extended with:

* More advanced customer-level analysis
* Predictive sales analysis
* Automated reporting
* Additional Power BI measures
* Forecasting
* Customer segmentation
* Automated database workflows
* Further performance optimisation

---

## 18. Author

**Sumit Yadav**

*Data Analytics Project — SQL + Power BI*
