USE iphone_analytics;
SHOW TBLPROPERTIES fact_sales ('project.student');
SELECT COUNT(*) AS bronze_sales_count FROM bronze_sales;
SELECT COUNT(*) AS silver_sales_count FROM silver_sales;
SELECT COUNT(*) AS fact_sales_count FROM fact_sales;
