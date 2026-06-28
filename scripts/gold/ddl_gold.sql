IF OBJECT_ID('gold.dim_customers','V') IS NOT NULL
  DROP VIEW gold.dim_customers;

GO
  
CREATE VIEW gold.dim_customers as
select
ROW_NUMBER() OVER (ORDER BY cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_nuumber,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	la.CNTRY as country,
	ci.cst_marital_status as marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		ELSE COALESCE(ca.GEN,'n/a')
	END as gender,
	ca.BDATE as birthdate,
	ci.cst_create_date as create_date	
from silver.crm_cust_info as ci
LEFT JOIN silver.erp_CUST_AZ12 ca
ON ci.cst_key = ca.CID
LEFT JOIN silver.erp_LOC_A101 la
ON ci.cst_key = la.CID

GO
    
IF OBJECT_ID('gold.dim_product','V') IS NOT NULL
  DROP VIEW gold.dim_product;

GO
    
 CREATE VIEW gold.dim_product as 
select 
ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt,pn.prd_key) as product_key,
	pn.prd_id as product_id,
	pn.prd_key as product_number,
	pn.prd_nm as product_name,
	pn.cat_id as category_id,
	pc.CAT as category,
	pc.SUBCAT as subcategory,
	pc.MAINTENANCE as maintenance,
	pn.prd_cost as cost,
	pn.prd_line as product_line,
	pn.prd_start_dt as start_date
from silver.crm_prd_info pn
LEFT JOIN silver.erp_PX_CAT_G1V2 pc
ON pn.cat_id = pc.ID
WHERE prd_end_dt IS NULL -- Filter out all historical data

GO
    
IF OBJECT_ID('gold.fact_sales','V') IS NOT NULL
  DROP VIEW gold.fact_sales;

GO

CREATE VIEW gold.fact_sales AS
SELECT
	sd.sls_ord_num as order_number,
	pr.product_key,
	cu.customer_id,
	sd.sls_order_dt as order_date,
	sd.sls_ship_dt as shipping_date,
	sd.sls_due_dt as due_date,
	sd.sls_sales as sales_amount,
	sd.sls_quantity as quantity,
	sd.sls_price
from silver.crm_sales_details sd
LEFT JOIN gold.dim_product pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id

GO
