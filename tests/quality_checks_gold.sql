/*
===============================================================================
Quality Assurance / Data Quality Checks: Gold Layer
===============================================================================
Script Purpose:
    This script contains a suite of data quality checks designed to validate 
    the integrity, consistency, and accuracy of the Gold Layer Star Schema 
    (Fact and Dimension tables).

    These queries are used to ensure the final reporting layer is free of 
    anomalies and ready for BI tools (like Power BI).

    Key Checks Performed:
    - Surrogate Key Integrity: Ensuring unique and non-null keys in Dimensions.
    - Referential Integrity: Ensuring Foreign Keys in the Fact table map correctly 
      to Primary Keys in the Dimension tables (No orphaned records).
    - Measure Validation: Confirming final mathematical accuracy of fact measures.
    - Data Integration Validation: Checking if master data resolution (e.g., 
      resolving conflicts between CRM and ERP) was successful.

Usage:
    Run these queries individually or as a batch. 
    Expectation: For queries checking for errors (e.g., finding NULLs, 
    duplicates, or orphaned facts), the ideal result set is EMPTY (0 rows).
===============================================================================
*/

-- ============================================================================
-- DIM_CUSTOMERS CHECKS
-- ============================================================================

-- Check for NULLs or Duplicates in the Surrogate Key
-- Expectation: No Results
SELECT 
    customer_key, 
    COUNT(*) AS count_of_records
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1 OR customer_key IS NULL;

-- Check Master Data Resolution (Gender)
-- Expectation: Only clean, standardized values ('Male', 'Female', 'n/a')
SELECT DISTINCT 
    gender 
FROM gold.dim_customers;


-- ============================================================================
-- DIM_PRODUCTS CHECKS
-- ============================================================================

-- Check for NULLs or Duplicates in the Surrogate Key
-- Expectation: No Results
SELECT 
    product_key, 
    COUNT(*) AS count_of_records
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1 OR product_key IS NULL;

-- Check for Historical Data Leakage
-- Expectation: No Results (Since we filtered out historical rows where prd_end_dt IS NOT NULL)
-- We check if any natural product number appears more than once in the active gold dimension.
SELECT 
    product_number, 
    COUNT(*) AS count_of_records
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;


-- ============================================================================
-- FACT_SALES CHECKS
-- ============================================================================

-- Referential Integrity: Check for Orphaned Sales Records (Missing Products)
-- Expectation: No Results (Every product_key in Fact must exist in dim_products)
SELECT 
    f.order_number,
    f.product_key
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL;

-- Referential Integrity: Check for Orphaned Sales Records (Missing Customers)
-- Expectation: No Results (Every customer_key in Fact must exist in dim_customers)
SELECT 
    f.order_number,
    f.customer_key
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;

-- Check Measure Logic & Consistency
-- Expectation: No Results (Sales = Quantity * Price, and no negatives/NULLs)
SELECT 
    sales_amount,
    quantity,
    price
FROM gold.fact_sales
WHERE sales_amount != quantity * price
   OR sales_amount IS NULL 
   OR quantity IS NULL 
   OR price IS NULL 
   OR sales_amount <= 0 
   OR quantity <= 0 
   OR price <= 0;

-- Check Date Logic
-- Expectation: No Results (Order date cannot be after shipping or due dates)
SELECT 
    order_date,
    shipping_date,
    due_date
FROM gold.fact_sales
WHERE order_date > shipping_date 
   OR order_date > due_date;
