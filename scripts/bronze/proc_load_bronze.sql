CREATE OR ALTER PROCEDURE bronze.load_bronze as 
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
			SET @batch_start_time = GETDATE();
			PRINT '========================================================================='
			PRINT 'Loading Bronze Layer Tables';
			PRINT '========================================================================='

			PRINT'--------------------------------------------------------------------------'
			PRINT 'Loading CRM Tables';
			PRINT'--------------------------------------------------------------------------'

			SET @start_time = GETDATE();
			PRINT '>>Truncating Table: bronze.crm_cust_info';
				TRUNCATE TABLE bronze.crm_cust_info;

			PRINT '>>Inserting Data into bronze.crm_cust_info';
				BULK INSERT bronze.crm_cust_info
				FROM 'F:\SQL\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
				WITH(
					FIRSTROW = 2,
					FIELDTERMINATOR =',',
					TABLOCK
				);
				SET @end_time = GETDATE();
				PRINT '>>Time taken: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';


				SET @start_time = GETDATE();
			PRINT '>>Truncating Table: bronze.crm_prd_info';
				TRUNCATE TABLE bronze.crm_prd_info;
			PRINT '>>Inserting Data into bronze.crm_prd_info';
				BULK INSERT bronze.crm_prd_info
				FROM 'F:\SQL\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
				WITH(
					FIRSTROW = 2,
					FIELDTERMINATOR =',',
					TABLOCK
				);
				SET @end_time = GETDATE();
				PRINT '>>Time taken: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';


				SET @start_time = GETDATE();
			PRINT '>>Truncating Table: bronze.crm_sales_details';
				TRUNCATE TABLE bronze.crm_sales_details;
			PRINT '>>Inserting Data into bronze.crm_sales_details';
				BULK INSERT bronze.crm_sales_details
				FROM 'F:\SQL\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
				WITH(
					FIRSTROW = 2,
					FIELDTERMINATOR =',',
					TABLOCK
				);
				SET @end_time = GETDATE();
				PRINT '>>Time taken: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';
			
			
			SET @start_time = GETDATE();
			PRINT'--------------------------------------------------------------------------'
			PRINT 'Loading ERP Tables';
			PRINT'--------------------------------------------------------------------------'

			PRINT '>>Truncating Table: bronze.erp_CUST_AZ12';
				TRUNCATE TABLE bronze.erp_CUST_AZ12;
			PRINT '>>Inserting Data into bronze.erp_CUST_AZ12';
				BULK INSERT bronze.erp_CUST_AZ12
				FROM 'F:\SQL\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
				WITH(
					FIRSTROW = 2,
					FIELDTERMINATOR =',',
					TABLOCK
				);
				SET @end_time = GETDATE();
				PRINT '>>Time taken: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';

				
				SET @start_time = GETDATE();
			PRINT '>>Truncating Table: bronze.erp_LOC_A101';
				TRUNCATE TABLE bronze.erp_LOC_A101;
			PRINT '>>Inserting Data into bronze.erp_LOC_A101';
				BULK INSERT bronze.erp_LOC_A101
				FROM 'F:\SQL\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
				WITH(
					FIRSTROW = 2,
					FIELDTERMINATOR =',',
					TABLOCK
				);
				SET @end_time = GETDATE();
				PRINT '>>Time taken: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';
				
				
				SET @start_time = GETDATE();
			PRINT '>>Truncating Table: bronze.erp_PX_CAT_G1V2';
				TRUNCATE TABLE bronze.erp_PX_CAT_G1V2;
			PRINT '>>Inserting Data into bronze.erp_PX_CAT_G1V2';
				BULK INSERT bronze.erp_PX_CAT_G1V2
				FROM 'F:\SQL\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
				WITH(
					FIRSTROW = 2,
					FIELDTERMINATOR =',',
					TABLOCK
				);
				SET @end_time = GETDATE();
				PRINT '>>Time taken: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';
				
				SET @batch_end_time = GETDATE();
				PRINT'===================================================================='
				PRINT'Batch Completed at:' + CAST(DATEDIFF(SECOND,@batch_start_time, @batch_end_time) as NVARCHAR) + ' seconds';
				PRINT'===================================================================='
	
	END TRY
BEGIN CATCH
	PRINT '========================================================================='
	PRINT 'Error occurred while loading Bronze Layer Tables';
	PRINT 'Error message: ' + ERROR_MESSAGE();
	PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
	PRINT '========================================================================='
END CATCH
END
