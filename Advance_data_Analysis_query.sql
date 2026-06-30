--Calculate the total sales per month 
--and the running total of sales over time 

SELECT
Sale_month,
Total_sales,
SUM(Total_sales) OVER(ORDER BY Sale_month) as Running_Total,
SUM(AVG_price) OVER(ORDER BY Sale_month) as Running_AVG_Total
From
(
	Select
	DATETRUNC(MONTH,Order_date) as Sale_month,
	SUM(sales_amount) as Total_sales,
	AVG(sls_price) as AVG_price
	from gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH,Order_date)
)t


/* Analyze the Yearly performance of the product by comparing their sales 
to both the average sales performance of the product and the previous year' sales */

WITH Yearly_product_sales as (
Select 
YEAR(f.order_date) as Order_Year,
p.product_name,
SUM(f.sales_amount) as Current_sales
From gold.fact_sales f
LEFT JOIN gold.dim_product p
ON p.product_key = f.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(f.order_date), 
		 p.product_name
)

Select
Order_Year,
product_name,
Current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) Avg_sales,
Current_sales - AVG(current_sales) OVER (PARTITION BY product_name) as Variance_avg_vs_Current_sale,
CASE WHEN Current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
	 WHEN Current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
	 ELSE 'Avg'
END AVG_Positions,
LAG(Current_sales) OVER (PARTITION BY product_name ORDER BY order_year) as PY_sales,
Current_sales - LAG(Current_sales) OVER (PARTITION BY product_name ORDER BY order_year) as Variance_PY_vs_Current_sale,
CASE WHEN Current_sales - LAG(Current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	 WHEN Current_sales - LAG(Current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	 ELSE 'No Change'
END PY_Positions
from Yearly_product_sales
ORDER BY product_name, Order_Year

-- Which categories contributes the most to overall sales?
WITH Category_sales as (
select
p.category,
SUM(f.sales_amount) as Total_sales
from gold.fact_sales f
LEFT JOIN gold.dim_product p
ON p.product_key = f.product_key
GROUP BY p.category
)
Select 
category,
Total_sales,
SUM(Total_sales) OVER() as Overall_Sales,
CONCAT(ROUND((CAST(Total_sales as FLOAT)/SUM(Total_sales) OVER())*100,2),'%') as Percentage_of_Total_Sales
from category_sales
ORDER BY Total_sales DESC

/*Segment based on cost Range using Case statment and CTE*/
WITH product_segment as (
select 
product_key,
product_name,
cost,
CASE WHEN cost < 100 then 'Below 100'
	 WHEN cost BETWEEN 100 and 500 then '100-500'
	 WHEN cost BETWEEN 500 and 1000 then '500-1000'
	 ELSE 'Above 1000'
END cost_range
from gold.dim_product
)
select 
cost_range,
COUNT(Product_key) as Total_Product
from product_segment
GROUP BY cost_range
ORDER BY Total_Product DESC

-- Calculate the customer spending based on 12 months Orders and sales
with Customer_spending as
(
Select 
c.customer_key,
sum(f.sales_amount) as Total_Spending,
MIN(order_date) as first_order,
MAX(order_date) as last_order,
DATEDIFF(MONTH,MIN(order_date), MAX(order_date)) as Life_Span
From gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_id
WHERE customer_key IS NOT NULL
GROUP BY c.customer_key
)
select
Customer_segment,
COUNT(customer_key) Total_customers
From (
Select 
customer_key,
CASE WHEN Life_Span >=12 AND Total_Spending >5000 THEN 'VIP'
	 WHEN Life_Span >=12 AND Total_Spending <5000 THEN 'Regular'
	 ELSE 'New'
END Customer_segment
From customer_spending)t
GROUP BY Customer_segment
ORDER BY Total_customers DESC

--FINAL Report (gold.report_customers)
-- this is base query using CTE to use for aggregation
CREATE VIEW gold.report_customers as
WITH base_query as
(
SELECT 
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_nuumber,
CONCAT(c.first_name, ' ', c.last_name) as customer_name,
DATEDIFF(year,c.birthdate, GETDATE()) age
from gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_id
WHERE order_date IS NOT NULL AND customer_key IS NOT NULL )

--this is customer aggreation details
, customer_aggregation as (
Select 
	customer_key,
	customer_nuumber,
	customer_name,
	age,
	COUNT(DISTINCT order_number) as Total_orders,
	SUM(sales_amount) as Total_sales,
	SUM(quantity) as Total_Quantity,
	COUNT(product_key) as Total_product,
	MAX(order_date) as Last_order,
	DATEDIFF(month,MIN(order_date),MAX(order_date)) as Life_span
From base_query
GROUP BY
	customer_key,
	customer_nuumber,
	customer_name,
	age
)

--Final query
select 
customer_key,
customer_nuumber,
customer_name,
age,
CASE 
	 WHEN age < 20 THEN 'Under 20'
	 WHEN age between 20 and 29 THEN '20-29'
	 WHEN age between 30 and 39 THEN '30-39'
	 WHEN age between 40 and 49 THEN '40-49'
	 ELSE '50 and above'
END age_group,
CASE 
	 WHEN Life_Span >=12 AND Total_sales >5000 THEN 'VIP'
	 WHEN Life_Span >=12 AND Total_sales <5000 THEN 'Regular'
	 ELSE 'New'
END customer_segment,
Total_orders,
Total_sales,
Total_Quantity,
Total_product,
Last_order,
DATEDIFF(MONTH,last_order,GETDATE()) as recency,
Life_span,
--Computation of avg order value 
CASE 
	WHEN Total_sales = 0 THEN 0
	ELSE Total_sales/Total_orders
 END avg_order_value,

 --Compute avgerage monthly spend
CASE WHEN Life_span = 0 THEN Total_sales
	 ELSE Total_sales/Life_span
END avg_spend
from customer_aggregation
