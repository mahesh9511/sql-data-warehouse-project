/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
    Run this script to re-define the DDL structure of 'silver' Tables.
    
    Note: The Silver layer represents cleansed, standardized, and conformed data. 
    Data types have been adjusted from the Bronze layer (e.g., INT dates converted 
    to DATE), and auditing columns (dwh_create_date) have been added.
===============================================================================
*/

IF OBJECT_ID ('silver.crm_cust_info','U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
-- DDL for cust_info.csv
Create table silver.crm_cust_info(
cst_id INT,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname NVARCHAR(50),
cst_material_status NVARCHAR(50),
cst_gndr NVARCHAR(50),
cst_create_date DATE,
dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.crm_prd_info','U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
-- DDL for prd_info.csv
CREATE TABLE silver.crm_prd_info (
    prd_id INT,
    cat_id NVARCHAR(50),
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(255),
    prd_cost FLOAT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.crm_sales_details','U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE, -- Converted from INT to DATE
    sls_ship_dt DATE,  -- Converted from INT to DATE
    sls_due_dt DATE,   -- Converted from INT to DATE
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME2 CONSTRAINT DF_crm_sales_details_dwh_create DEFAULT SYSDATETIME()
);

IF OBJECT_ID ('silver.erp_cust_az12','U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
-- DDL for CUST_AZ12.csv
CREATE TABLE silver.erp_cust_az12 (
    CID NVARCHAR(50),
    BDATE DATE,
    GEN NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.erp_loc_a101','U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
-- DDL for LOC_A101.csv
CREATE TABLE silver.erp_loc_a101 (
    CID NVARCHAR(50),
    CNTRY NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.erp_px_cat_g1v2','U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
-- DDL for PX_CAT_G1V2.csv
CREATE TABLE silver.erp_px_cat_g1v2 (
    ID NVARCHAR(50),
    CAT NVARCHAR(50),
    SUBCAT NVARCHAR(50),
    MAINTENANCE NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
