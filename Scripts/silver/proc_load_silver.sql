
--GRANT INSERT ON silver_schema.erp_px_cat_g1v2 TO silver_schema;

--GRANT SELECT ON bronze_schema.erp_px_cat_g1v2 TO silver_schema;

CREATE OR REPLACE PROCEDURE silver_schema.load_silver
AS
BEGIN

    ----------------------------------------------------------------------------
    -- CRM CUSTOMER INFORMATION
    ----------------------------------------------------------------------------

    DBMS_OUTPUT.PUT_LINE('>> Loading: CRM_CUST_INFO');

    EXECUTE IMMEDIATE 'TRUNCATE TABLE silver_schema.crm_cust_info';

    INSERT INTO silver_schema.crm_cust_info
    (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT
        src.cst_id,
        src.cst_key,
        TRIM(src.cst_firstname),
        TRIM(src.cst_lastname),

        CASE
            WHEN UPPER(TRIM(src.cst_marital_status)) = 'M' THEN 'Married'
            WHEN UPPER(TRIM(src.cst_marital_status)) = 'S' THEN 'Single'
            ELSE 'N/A'
        END AS cst_marital_status,

        CASE
            WHEN UPPER(TRIM(src.cst_gndr)) = 'M' THEN 'Male'
            WHEN UPPER(TRIM(src.cst_gndr)) = 'F' THEN 'Female'
            ELSE 'N/A'
        END AS cst_gndr,

        src.cst_create_date

    FROM
    (
        SELECT
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date,

            ROW_NUMBER() OVER
            (
                PARTITION BY cst_id
                ORDER BY cst_create_date DESC
            ) AS row_num

        FROM bronze_schema.crm_cust_info

    ) src
    WHERE src.row_num = 1;


    ----------------------------------------------------------------------------
    -- CRM PRODUCT INFORMATION
    ----------------------------------------------------------------------------

    DBMS_OUTPUT.PUT_LINE('>> Loading: CRM_PRD_INFO');

    EXECUTE IMMEDIATE 'TRUNCATE TABLE silver_schema.crm_prd_info';

    INSERT INTO silver_schema.crm_prd_info
    (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,

        REPLACE(
            SUBSTR(TRIM(prd_key), 1, 5),
            '-',
            '_'
        ) AS cat_id,

        SUBSTR(
            TRIM(prd_key),
            7,
            LENGTH(TRIM(prd_key))
        ) AS prd_key,

        prd_nm,

        COALESCE(prd_cost, 0) AS prd_cost,

        CASE UPPER(TRIM(prd_line))
            WHEN 'T' THEN 'Touring'
            WHEN 'S' THEN 'Other Sales'
            WHEN 'M' THEN 'Mountain'
            WHEN 'R' THEN 'Road'
            ELSE 'N/A'
        END AS prd_line,

        prd_start_dt,

        LEAD(prd_start_dt)
            OVER (
                PARTITION BY prd_key
                ORDER BY prd_start_dt
            ) - 1 AS prd_end_dt

    FROM bronze_schema.crm_prd_info;


    ----------------------------------------------------------------------------
    -- CRM SALES DETAILS
    ----------------------------------------------------------------------------

    DBMS_OUTPUT.PUT_LINE('>> Loading: CRM_SALES_DETAILS');

    EXECUTE IMMEDIATE 'TRUNCATE TABLE silver_schema.crm_sales_details';

    INSERT INTO silver_schema.crm_sales_details
    (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,

        CASE
            WHEN sls_order_dt = 0
                 OR LENGTH(sls_order_dt) != 8
            THEN NULL
            ELSE TO_DATE(
                    TO_CHAR(sls_order_dt),
                    'YYYYMMDD'
                 )
        END AS sls_order_dt,

        CASE
            WHEN sls_ship_dt = 0
                 OR LENGTH(sls_ship_dt) != 8
            THEN NULL
            ELSE TO_DATE(
                    TO_CHAR(sls_ship_dt),
                    'YYYYMMDD'
                 )
        END AS sls_ship_dt,

        CASE
            WHEN sls_due_dt = 0
                 OR LENGTH(sls_due_dt) != 8
            THEN NULL
            ELSE TO_DATE(
                    TO_CHAR(sls_due_dt),
                    'YYYYMMDD'
                 )
        END AS sls_due_dt,

        CASE
            WHEN sls_sales IS NULL
                 OR sls_sales < 0
                 OR sls_sales <> sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales,

        sls_quantity,

        CASE
            WHEN sls_price IS NULL
                 OR sls_price < 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END AS sls_price

    FROM bronze_schema.crm_sales_details;


    ----------------------------------------------------------------------------
    -- ERP CUSTOMER INFORMATION
    ----------------------------------------------------------------------------

    DBMS_OUTPUT.PUT_LINE('>> Loading: ERP_CUST_AZ12');

    EXECUTE IMMEDIATE 'TRUNCATE TABLE silver_schema.erp_cust_az12';

    INSERT INTO silver_schema.erp_cust_az12
    (
        cid,
        bdate,
        gen
    )
    SELECT
        CASE
            WHEN cid LIKE 'NAS%'
            THEN SUBSTR(cid, 4)
            ELSE cid
        END AS cid,

        CASE
            WHEN bdate > SYSDATE
            THEN NULL
            ELSE bdate
        END AS bdate,

        CASE
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE')
                THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')
                THEN 'Male'
            ELSE 'N/A'
        END AS gen

    FROM bronze_schema.erp_cust_az12;


    ----------------------------------------------------------------------------
    -- ERP LOCATION INFORMATION
    ----------------------------------------------------------------------------

    DBMS_OUTPUT.PUT_LINE('>> Loading: ERP_LOC_A101');

    EXECUTE IMMEDIATE 'TRUNCATE TABLE silver_schema.erp_loc_a101';

    INSERT INTO silver_schema.erp_loc_a101
    (
        cid,
        cntry
    )
    SELECT
        REPLACE(cid, '-', '') AS cid,

        CASE
            WHEN TRIM(cntry) = 'DE'
                THEN 'Germany'

            WHEN TRIM(cntry) IN ('US', 'USA')
                THEN 'United States'

            WHEN cntry IS NULL
                 OR TRIM(cntry) = ''
                THEN 'N/A'

            ELSE TRIM(cntry)
        END AS cntry

    FROM bronze_schema.erp_loc_a101;


    ----------------------------------------------------------------------------
    -- ERP PRODUCT CATEGORY
    ----------------------------------------------------------------------------

    DBMS_OUTPUT.PUT_LINE('>> Loading: ERP_PX_CAT_G1V2');

    EXECUTE IMMEDIATE 'TRUNCATE TABLE silver_schema.erp_px_cat_g1v2';

    INSERT INTO silver_schema.erp_px_cat_g1v2
    (
        id,
        cat,
        subcat,
        maintenance
    )
    SELECT
        id,
        cat,
        subcat,
        maintenance
    FROM bronze_schema.erp_px_cat_g1v2;


    ----------------------------------------------------------------------------
    -- COMMIT
    ----------------------------------------------------------------------------

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('>> Silver Layer Load Completed Successfully');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;

        DBMS_OUTPUT.PUT_LINE(
            'ERROR: ' || SQLCODE || ' - ' || SQLERRM
        );

        RAISE;
END load_silver;
/

EXEC silver_schema.load_silver;
