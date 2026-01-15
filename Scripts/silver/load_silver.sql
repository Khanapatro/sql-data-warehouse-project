CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------------
    -- Variable Declarations
    ------------------------------------------------------------
    DECLARE 
        @batch_start_time   DATETIME2,
        @batch_end_time     DATETIME2,
        @step_start_time    DATETIME2,
        @step_end_time      DATETIME2;

    BEGIN TRY
        ------------------------------------------------------------
        -- Batch Start
        ------------------------------------------------------------
        SET @batch_start_time = SYSDATETIME();
        PRINT '====================================================';
        PRINT 'Silver Load Started at: ' + CONVERT(VARCHAR, @batch_start_time, 120);
        PRINT '====================================================';

        ------------------------------------------------------------
        -- Load silver.crm_cust_info
        ------------------------------------------------------------
        SET @step_start_time = SYSDATETIME();
        PRINT 'Loading table: silver.crm_cust_info';

        TRUNCATE TABLE silver.crm_cust_info;
 
        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_material_status,
            cst_gndr,
            cst_create_date
        )
        SELECT 
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE 
                WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END,
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END,
            cst_create_date
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER (
                       PARTITION BY cst_id
                       ORDER BY cst_create_date DESC
                   ) AS flg
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flg = 1;

        SET @step_end_time = SYSDATETIME();
        PRINT 'Completed silver.crm_cust_info in ' +
              CAST(DATEDIFF(SECOND, @step_start_time, @step_end_time) AS VARCHAR) + ' seconds';

        ------------------------------------------------------------
        -- Load silver.crm_prd_info
        ------------------------------------------------------------
        SET @step_start_time = SYSDATETIME();
        PRINT 'Loading table: silver.crm_prd_info';

        TRUNCATE TABLE silver.crm_prd_info;

        INSERT INTO silver.crm_prd_info (
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
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
            SUBSTRING(prd_key, 7, LEN(prd_key)),
            prd_nm,
            COALESCE(prd_cost, 0),
            CASE 
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'n/a'
            END,
            CAST(prd_start_dt AS DATE),
            CAST(
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key 
                    ORDER BY prd_start_dt
                ) - 1 AS DATE
            )
        FROM bronze.crm_prd_info;

        SET @step_end_time = SYSDATETIME();
        PRINT 'Completed silver.crm_prd_info in ' +
              CAST(DATEDIFF(SECOND, @step_start_time, @step_end_time) AS VARCHAR) + ' seconds';

        ------------------------------------------------------------
        -- Load silver.crm_sales_details
        ------------------------------------------------------------
        SET @step_start_time = SYSDATETIME();
        PRINT 'Loading table: silver.crm_sales_details';

        TRUNCATE TABLE silver.crm_sales_details;

        INSERT INTO silver.crm_sales_details (
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
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) <> 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END,
            CASE 
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) <> 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END,
            CASE 
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) <> 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END,
            CASE 
                WHEN sls_sales IS NULL 
                     OR sls_sales <= 0 
                     OR sls_sales <> sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END,
            sls_quantity,
            CASE 
                WHEN sls_price IS NULL OR sls_price <= 0
                THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END
        FROM bronze.crm_sales_details;

        SET @step_end_time = SYSDATETIME();
        PRINT 'Completed silver.crm_sales_details in ' +
              CAST(DATEDIFF(SECOND, @step_start_time, @step_end_time) AS VARCHAR) + ' seconds';

        ------------------------------------------------------------
        -- Batch End
        ------------------------------------------------------------
        SET @batch_end_time = SYSDATETIME();
        PRINT '====================================================';
        PRINT 'Silver Load Completed Successfully';
        PRINT 'Total Batch Duration: ' +
              CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR) + ' seconds';
        PRINT '====================================================';

    END TRY
    BEGIN CATCH
        ------------------------------------------------------------
        -- Error Handling
        ------------------------------------------------------------
        PRINT 'ERROR OCCURRED DURING SILVER LOAD';
        PRINT 'Error Number   : ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Severity : ' + CAST(ERROR_SEVERITY() AS VARCHAR);
        PRINT 'Error State    : ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT 'Error Line     : ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT 'Error Message  : ' + ERROR_MESSAGE();

        THROW;
    END CATCH
END;
GO
