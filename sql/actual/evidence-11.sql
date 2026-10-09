USE iphone_analytics;
SHOW TBLPROPERTIES fact_sales ('project.student');
SELECT date_key, SUM(quantity) AS units, SUM(total_amount) AS revenue FROM fact_sales GROUP BY date_key;
SELECT d.year, d.month, SUM(f.total_amount) AS revenue FROM fact_sales f JOIN dim_date d ON f.date_key=d.date_key GROUP BY d.year,d.month;
SELECT c.customer_name, COUNT(*) AS purchases, SUM(f.quantity) AS units, SUM(f.total_amount) AS revenue FROM fact_sales f JOIN dim_customer c ON f.customer_id=c.customer_id GROUP BY c.customer_name;
