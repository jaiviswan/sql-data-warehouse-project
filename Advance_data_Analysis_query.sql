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

