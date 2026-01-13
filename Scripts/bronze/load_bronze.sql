-- NOTE:
-- This stored procedure loads raw data into the Bronze layer tables
-- using BULK INSERT from CSV source files.
--
-- Each load operation:
--   - Truncates the target table
--   - Loads fresh data from source files
--   - Logs start time, end time, and duration
--
-- This procedure is intended for development or controlled environments.

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @batch_start_time DATETIME,
        @batch_end_time   DATETIME,
        @start_time       DATETIME,
        @end_time         DATETIME;

    BEGIN TRY
        -----------------------------------------------------------
        -- Batch Start
        -----------------------------------------------------------
        SET @batch_start_time = GETDATE();
        PRINT '=======================================';
        PRINT 'Starting Bronze Layer Load';
        PRINT 'Batch Start Time: ' + CAST(@batch_start_time AS NVARCHAR);
        PRINT '=======================================';

        -----------------------------------------------------------
        -- Load CRM Customer Info
        -----------------------------------------------------------
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_cust_info;

        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\khanapatro\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'crm_cust_info loaded in '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';

        -----------------------------------------------------------
        -- Load CRM Product Info
        -----------------------------------------------------------
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_prd_info;

        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\khanapatro\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'crm_prd_info loaded in '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';

        -----------------------------------------------------------
        -- Load CRM Sales Details
        -----------------------------------------------------------
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_sales_details;

        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\khanapatro\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'crm_sales_details loaded in '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';

        -----------------------------------------------------------
        -- Load ERP Customer Data
        -----------------------------------------------------------
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_cust_az12;

        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\khanapatro\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'erp_cust_az12 loaded in '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';

        -----------------------------------------------------------
        -- Load ERP Location Data
        -----------------------------------------------------------
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_loc_a101;

        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\khanapatro\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'erp_loc_a101 loaded in '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';

        -----------------------------------------------------------
        -- Load ERP Product Category Data
        -----------------------------------------------------------
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\khanapatro\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'erp_px_cat_g1v2 loaded in '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';

        -----------------------------------------------------------
        -- Batch End
        -----------------------------------------------------------
        SET @batch_end_time = GETDATE();
        PRINT '=======================================';
        PRINT 'Bronze Layer Load Completed';
        PRINT 'Total Batch Duration: '
              + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR)
              + ' seconds';
        PRINT '=======================================';

    END TRY
    BEGIN CATCH
        PRINT '=======================================';
        PRINT 'ERROR OCCURRED DURING BRONZE LAYER LOAD';
        PRINT 'Error Message : ' + ERROR_MESSAGE();
        PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State   : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=======================================';
    END CATCH
END;
GO


-- Execute Bronze Layer Load Procedure
EXEC bronze.load_bronze;
GO
