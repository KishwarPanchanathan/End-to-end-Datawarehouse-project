/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver_schema' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/


-- ====================================================================
-- Checking 'silver_schema.crm_cust_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results

-- Check for NULLs or Duplicate Customer IDs
SELECT
    cst_id,
    COUNT(*) cnt
FROM silver_schema.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;

-- Check for Leading / Trailing Spaces
SELECT cst_key
FROM silver_schema.crm_cust_info
WHERE cst_key <> TRIM(cst_key);

-- Check Marital Status Standardization
SELECT DISTINCT cst_marital_status
FROM silver_schema.crm_cust_info;

-- Check Gender Standardization
SELECT DISTINCT cst_gndr
FROM silver_schema.crm_cust_info;

-- ====================================================================
-- Checking 'silver_schema.crm_prd_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results

-- Duplicate Product IDs
SELECT
    prd_id,
    COUNT(*) cnt
FROM silver_schema.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;

-- Product Name Spaces
SELECT prd_nm
FROM silver_schema.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);

-- Negative or Null Product Cost
SELECT *
FROM silver_schema.crm_prd_info
WHERE prd_cost IS NULL
   OR prd_cost < 0;

-- Product Line Validation
SELECT DISTINCT prd_line
FROM silver_schema.crm_prd_info;

-- Invalid Product Date Ranges
SELECT *
FROM silver_schema.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- Overlapping Product History Records (SCD Validation)
SELECT
    prd_key,
    prd_start_dt,
    prd_end_dt
FROM silver_schema.crm_prd_info
WHERE prd_start_dt > prd_end_dt;


-- ====================================================================
-- Checking 'silver_schema.crm_sales_details'
-- ====================================================================
-- Check for Invalid Dates
-- Expectation: No Invalid Dates


-- Validate Order Date
SELECT *
FROM bronze_schema.crm_sales_details
WHERE sls_order_dt IS NULL
   OR LENGTH(TO_CHAR(sls_order_dt)) <> 8
   OR sls_order_dt > 20500101
   OR sls_order_dt < 19000101;

-- Invalid Ship Dates
SELECT *
FROM bronze_schema.crm_sales_details
WHERE sls_ship_dt IS NULL
   OR LENGTH(TO_CHAR(sls_ship_dt)) <> 8
   OR sls_ship_dt > 20500101
   OR sls_ship_dt < 19000101;

-- Invalid Due Dates
SELECT *
FROM bronze_schema.crm_sales_details
WHERE sls_due_dt IS NULL
   OR LENGTH(TO_CHAR(sls_due_dt)) <> 8
   OR sls_due_dt > 20500101
   OR sls_due_dt < 19000101;

-- Order Date Greater Than Ship Date
SELECT *
FROM silver_schema.crm_sales_details
WHERE sls_order_dt > sls_ship_dt;

-- Order Date Greater Than Due Date
SELECT *
FROM silver_schema.crm_sales_details
WHERE sls_order_dt > sls_due_dt;

-- Sales Consistency Check
SELECT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver_schema.crm_sales_details
WHERE sls_sales <> sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
ORDER BY
    sls_sales,
    sls_quantity,
    sls_price;

-- Duplicate Sales Orders
SELECT
    sls_ord_num,
    sls_prd_key,
    COUNT(*)
FROM silver_schema.crm_sales_details
GROUP BY
    sls_ord_num,
    sls_prd_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'silver_schema.erp_cust_az12'
-- ====================================================================
-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today

-- Birth Date Validation
SELECT DISTINCT bdate
FROM silver_schema.erp_cust_az12
WHERE bdate < DATE '1924-01-01'
   OR bdate > SYSDATE;

-- Gender Standardization
SELECT DISTINCT gen
FROM silver_schema.erp_cust_az12;

-- Customer ID Format Check
SELECT *
FROM silver_schema.erp_cust_az12
WHERE cid LIKE 'NAS%';

-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================
-- Data Standardization & Consistency

-- Country Standardization
SELECT DISTINCT cntry
FROM silver_schema.erp_loc_a101
ORDER BY cntry;

-- Country Null Check
SELECT *
FROM silver_schema.erp_loc_a101
WHERE cntry IS NULL;

-- Customer ID Cleanup Check
SELECT *
FROM silver_schema.erp_loc_a101
WHERE cid LIKE '%-%';

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================
-- Check for Unwanted Spaces
-- Expectation: No Results

-- Trim Validation
SELECT *
FROM silver_schema.erp_px_cat_g1v2
WHERE cat <> TRIM(cat)
   OR subcat <> TRIM(subcat)
   OR maintenance <> TRIM(maintenance);

-- Maintenance Standardization
SELECT DISTINCT maintenance
FROM silver_schema.erp_px_cat_g1v2;

-- Null Category Validation
SELECT *
FROM silver_schema.erp_px_cat_g1v2
WHERE cat IS NULL
   OR subcat IS NULL;
