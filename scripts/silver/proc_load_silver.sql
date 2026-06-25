INSERT INTO silver.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
Select
cst_id,
cst_key,
COALESCE(TRIM(cst_firstname), 'n/a') as cst_firstname,
COALESCE(TRIM(cst_lastname), 'n/a') as cst_lastname,
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
ELSE 'n/a'
END cst_marital_status,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
ELSE 'n/a'
END cst_gndr,
cst_create_date
from (
select 
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
from bronze.crm_cust_info
)t
WHERE flag_last = 1
