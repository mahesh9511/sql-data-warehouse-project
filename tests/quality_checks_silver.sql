/*
===============================================================================
Quality Assurance / Data Quality Checks: Silver Layer
===============================================================================
Script Purpose:
    This script contains a suite of data quality checks designed to validate 
    the integrity, consistency, and standardization of the data within the 
    'silver' layer. 

    These queries are used to verify that the ETL transformations (applied 
    in the load_silver stored procedure) were successful.

    Key Checks Performed:
    - Primary Key Integrity: Ensuring no duplicates or NULL values exist.
    - Data Standardization: Verifying that unwanted spaces are trimmed and 
      categorical values (e.g., gender, marital status, country) are uniformly mapped.
    - Business Logic Rules: Confirming mathematical accuracy (e.g., Sales = 
      Quantity * Price) and checking for invalid negative/zero values.
    - Logical Consistency: Validating date sequences (e.g., start date before 
      end date; order date before ship/due dates).
    - Data Range Bounds: Identifying out-of-range dates (e.g., future birth dates).

Usage:
    Run these queries individually or as a batch. 
    Expectation: For queries checking for errors (e.g., finding NULLs, 
    duplicates, or invalid logic), the ideal result set is EMPTY (0 rows).
===============================================================================
*/

-- for crm_cust_info
-- Check For Nulls or Duplicates in Primary Key
-- Expectation : No Results

SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

--Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

SELECT DISTINCT cst_material_status
FROM silver.crm_cust_info;

SELECT * FROM silver.crm_cust_info;

--- for crm_prd_info
SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

select * from silver.crm_prd_info;

-- checks for NULLS pr NEGATIVE Numbers 
--- EXPEXTATION: NO Results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- DATA STANDARDIZATION & CONSISTENCY
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Check for Invalid Date Orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

--- for crm_sales_details
---- CHECK FOR INAVLID DATE ORDERS
SELECT
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

---- CHECK DATA CONSISTENCY: BETWEEN SALES, QUANTITY, AND PRICE
--->> SALES = QUANTITY * PRICE
--->> VALUES MUST NOT BE NULL, ZERO, OR NEGATIVE.

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_quantity, sls_price

--- for erp_cust_az12
--- Identify Out-of-Range Dates
SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

--- DATA STANDARDIZATION & CONSISTENCY
SELECT DISTINCT
gen
FROM silver.erp_cust_az12 

select * from silver.erp_cust_az12

---- for erp_loc_a101 table
SELECT
REPLACE(cid,'-','') cid,
cntry
FROM silver.erp_loc_a101

------ DATA STANDARDIZATION & CONSISTENCY
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry

---- for erp_px_cat_g1v2 table
SELECT
id,
cat,
subcat,
maintenance
FROM silver.erp_px_cat_g1v2

--chevk unwanted spaces
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

--- DATA STANDARDIZATION & CONSISTENCY
SELECT DISTINCT
cat,
subcat,
maintenance
FROM silver.erp_px_cat_g1v2
