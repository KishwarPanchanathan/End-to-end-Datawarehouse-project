
/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver_schema' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'silver_schema' Tables
===============================================================================
*/

-- crm_cust_info
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE silver_schema.crm_cust_info';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

CREATE TABLE silver_schema.crm_cust_info (
    cst_id              NUMBER(10),
    cst_key             VARCHAR2(50),
    cst_firstname       VARCHAR2(50),
    cst_lastname        VARCHAR2(50),
    cst_marital_status  VARCHAR2(50),
    cst_gndr            VARCHAR2(50),
    cst_create_date     DATE,
    dwh_create_date     DATE DEFAULT SYSDATE
);
/


  -- crm_prd_info
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE silver_schema.crm_prd_info';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

CREATE TABLE silver_schema.crm_prd_info (
    prd_id              NUMBER(10),
    cat_id              VARCHAR2(50),
    prd_key             VARCHAR2(50),
    prd_nm              VARCHAR2(50),
    prd_cost            NUMBER(10),
    prd_line            VARCHAR2(50),
    prd_start_dt        DATE,
    prd_end_dt          DATE,
    dwh_create_date     DATE DEFAULT SYSDATE
);
/

  -- crm_sales_details
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE silver_schema.crm_sales_details';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

CREATE TABLE silver_schema.crm_sales_details (
    sls_ord_num         VARCHAR2(50),
    sls_prd_key         VARCHAR2(50),
    sls_cust_id         NUMBER(10),
    sls_order_dt        DATE,
    sls_ship_dt         DATE,
    sls_due_dt          DATE,
    sls_sales           NUMBER(10),
    sls_quantity        NUMBER(10),
    sls_price           NUMBER(10),
    dwh_create_date     DATE DEFAULT SYSDATE
);
/

-- erp_loc_a101
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE silver_schema.erp_loc_a101';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

CREATE TABLE silver_schema.erp_loc_a101 (
    cid                 VARCHAR2(50),
    cntry               VARCHAR2(50),
    dwh_create_date     DATE DEFAULT SYSDATE
);
/


  -- erp_cust_az12
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE silver_schema.erp_cust_az12';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

CREATE TABLE silver_schema.erp_cust_az12 (
    cid                 VARCHAR2(50),
    bdate               DATE,
    gen                 VARCHAR2(50),
    dwh_create_date     DATE DEFAULT SYSDATE
);
/

-- erp_px_cat_g1v2
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE silver_schema.erp_px_cat_g1v2';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

CREATE TABLE silver_schema.erp_px_cat_g1v2 (
    id                  VARCHAR2(50),
    cat                 VARCHAR2(50),
    subcat              VARCHAR2(50),
    maintenance         VARCHAR2(50),
    dwh_create_date     DATE DEFAULT SYSDATE
);
/
