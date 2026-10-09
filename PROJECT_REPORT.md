# Ravi iPhone Sales Analytics Platform

The project transforms the assignment's four sales records into analytics-ready Hive tables backed by HDFS. Bronze retains the source CSV values, Silver standardizes types and validates identifiers, and Gold supplies a star schema for product, store, date, and customer reporting.

## Architecture

```text
Supplied CSV files
    -> HDFS /iphone/raw
    -> bronze_customers, bronze_products, bronze_stores, bronze_sales
    -> silver_customers, silver_products, silver_stores, silver_sales
    -> dim_customer, dim_product, dim_store, dim_date, fact_sales
```

Every warehouse table is stored as Parquet beneath `/warehouse/tablespace/managed/hive/`. Silver sales is partitioned by `sale_date`; fact sales is partitioned by `date_key`. The Hive database is `iphone_analytics`.

## Transformation logic

Bronze reads each CSV with its header and retains every source column as a string. Silver trims surrounding spaces, casts numeric identifiers and prices, parses dates, normalizes state abbreviations, rejects null/invalid records, removes exact duplicates, and fails on conflicting duplicate keys. Sales records must reference an existing customer, product, and store before Gold is loaded.

The fact table contains one row per sale identifier. It joins sales to products and calculates `total_amount = quantity * unit_price`. The source uses whole-number prices; fact amounts use a long integer to allow larger totals. Customer, product, and store dimensions retain natural source identifiers. Date attributes are derived from distinct observed sales dates.

## Design decisions

Parquet stores columns efficiently and supports compressed analytical reads. Separate Medallion layers retain an auditable raw source, reusable cleaned records, and business-ready tables. The star schema centralizes measures in a fact table and descriptive attributes in dimensions. Date partitions let time-filtered queries prune irrelevant directories.

This sample includes AirPods as well as iPhones because all supplied product and sales records belong to the input. Revenue queries therefore cover the complete provided retail dataset. For iPhone-only analysis, add a product-name or category filter appropriate to the intended report.

## Execution and evidence

The project runs in the existing Docker course container with HDFS, a MySQL-backed Hive metastore, HiveServer2, and PySpark. Spark uses two local processing threads and the shared Hive metastore; data storage remains actual HDFS. The screenshot directory and retained logs provide the execution evidence. See README.md for run commands and the screenshot checklist.

## Future production changes

Replace the full-snapshot overwrite with an explicit daily incremental ingestion strategy, retain rejected records for review, add ingestion timestamps and batch lineage, use decimal currency for fractional prices, and preserve historical product prices. Introduce surrogate keys and slowly changing dimensions if historical customer/store attributes are required. A complete calendar dimension would support days without sales.
