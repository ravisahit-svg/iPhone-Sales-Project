from pathlib import Path

root=Path(__file__).parent
folder=root/'sql'/'actual'
folder.mkdir(exist_ok=True)
checks={
 '01': "SHOW DATABASES;\nUSE iphone_analytics;\nSHOW TABLES;",
 '02': "DESCRIBE FORMATTED silver_sales;",
 '03': "DESCRIBE FORMATTED fact_sales;",
 '05': "SHOW PARTITIONS silver_sales;\nSHOW PARTITIONS fact_sales;",
 '06': "SELECT p.product_name, SUM(f.total_amount) AS revenue FROM fact_sales f JOIN dim_product p ON f.product_id=p.product_id GROUP BY p.product_name;",
 '07': "SELECT s.store_name, SUM(f.total_amount) AS revenue FROM fact_sales f JOIN dim_store s ON f.store_id=s.store_id GROUP BY s.store_name;",
 '08': "SELECT COUNT(*) AS bronze_sales_count FROM bronze_sales;\nSELECT COUNT(*) AS silver_sales_count FROM silver_sales;\nSELECT COUNT(*) AS fact_sales_count FROM fact_sales;",
 '09': "SELECT * FROM silver_sales LIMIT 10;",
 '10': "SELECT * FROM fact_sales LIMIT 10;",
 '11': "SELECT date_key, SUM(quantity) AS units, SUM(total_amount) AS revenue FROM fact_sales GROUP BY date_key;\nSELECT d.year, d.month, SUM(f.total_amount) AS revenue FROM fact_sales f JOIN dim_date d ON f.date_key=d.date_key GROUP BY d.year,d.month;\nSELECT c.customer_name, COUNT(*) AS purchases, SUM(f.quantity) AS units, SUM(f.total_amount) AS revenue FROM fact_sales f JOIN dim_customer c ON f.customer_id=c.customer_id GROUP BY c.customer_name;",
 '12': "DESCRIBE DATABASE EXTENDED iphone_analytics;\nSHOW TBLPROPERTIES fact_sales;",
}
for number,sql in checks.items():
    preamble="USE iphone_analytics;\n" + ("" if number in ['02','03','12'] else "SHOW TBLPROPERTIES fact_sales ('project.student');\n")
    (folder/('evidence-'+number+'.sql')).write_text(preamble+sql+'\n',encoding='utf-8')
print('Prepared real-command SQL files for all required captures')
