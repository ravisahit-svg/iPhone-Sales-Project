# Ravi iPhone Sales Analytics Platform

Ravi's project runs in the existing course Docker container `takeo-de-env`. The course Linux account remains `takeo`. The project name and student name are stored as actual Hive database and table properties and in the HDFS project information file.

## Project identity

- Project name: Ravi iPhone Sales Analytics
- Student: Ravi
- Container project directory: /home/takeo/ravi-iphone-project
- Hive database: iphone_analytics
- Database and table properties: project.name and project.student
- HDFS project information: /iphone/project-info.txt

The assignment requires the database name iphone_analytics and the bronze, silver, fact, and dimension table names, so those names are retained. Infrastructure accounts are independent of the student's project name.

## Architecture and implementation

The four supplied CSV files are stored in HDFS at /iphone/raw. Bronze stores raw strings as Parquet. Silver trims and casts fields, normalizes states, removes invalid records and exact duplicates, rejects conflicting duplicate identifiers, and validates sales foreign keys. Gold contains dim_customer, dim_product, dim_store, dim_date, and fact_sales. Fact grain is one sale line; total_amount equals quantity times unit_price.

All 13 tables are Parquet tables with explicit paths under /warehouse/tablespace/managed/hive/. Silver sales is partitioned by sale_date; fact sales is partitioned by date_key. This is a full-snapshot sample pipeline. Production daily ingestion would need incremental loading, rejection logs, lineage, decimal currency, and historical price handling.

## Run the project

Open Docker Desktop normally. Run run-project.ps1 from Windows PowerShell to copy the project files and start the course services. Then open the existing account's shell:

```powershell
docker exec -it -u takeo takeo-de-env bash
```

Within the container:

```bash
cd /home/takeo/ravi-iphone-project
source env.sh
hadoop fs -mkdir -p /iphone/raw
hadoop fs -put -f data/*.csv /iphone/raw/
spark-submit --master 'local[2]' --driver-memory 1g pipeline.py --input hdfs:///iphone/raw
beeline -u jdbc:hive2://localhost:10004/ -n takeo --showHeader=true --outputformat=table -f sql/evidence.sql
```

The pipeline overwrites the sample tables. It writes Ravi's project properties after each table load. SQL in sql/project-metadata.sql applies the same informational properties to existing tables. PROJECT_INFO.txt is also stored at /iphone/project-info.txt in HDFS.

The course stack uses Hadoop 3.3.3, Hive 3.1.3, Spark 3.3.2, Java 8 and a MySQL-backed metastore. Spark uses local processing threads while retaining real HDFS storage and the shared Hive metastore. HiveServer2 uses a 2 GB heap and a 16 MB sorting buffer and is configured for local MapReduce, notification polling disabled, and the existing service identity. Java subprocesses use FORK to avoid the observed ARM emulation subprocess hang. The optional Spark UI is disabled to avoid its emulated shutdown issue.

## Screenshots and reports

The numbered PNG files in screenshots/ show Hive queries, HDFS directories, table schemas and project properties from the running course environment. Open screenshots/index.html to browse them. Corresponding command outputs are saved in logs/actual-evidence-*.log.

The APA project report is included at submission-documents/Ravi_iPhone_Sales_Report_APA.docx, with actual screenshots and results tables. Optional utilities for preparing documents, capturing screenshots and packaging the submission are kept locally and are not required to run the analytics pipeline.

## Sample verification

There are 13 tables, 4 sales records in each layer, 6 units and total revenue 4400. Product revenue is iPhone 14 2200, iPhone 13 1800 and AirPods 400. Store revenue is Apple Store NY 3100 and Apple Store SJ 1300. Four January 2023 dates are partitioned in Silver and Gold.

DESCRIBE metadata may show numRows as zero because Spark does not populate Hive row-count statistics. The actual COUNT queries provide row-count evidence.

credentials.txt contains private local connection details and is excluded from the submission ZIP. No new Linux user was created, and the original course container was not renamed.

## Screenshot order

| File | Actual check |
|---|---|
| 1.png | Database and table listing |
| 2.png | Silver sales schema |
| 3.png | Fact sales schema |
| 4.png | HDFS project information and directories |
| 5.png | Date partitions |
| 6.png | Product revenue |
| 7.png | Store revenue |
| 8.png | Sales row counts |
| 9.png | Silver data sample |
| 10.png | Fact data sample |
| 11.png | Daily monthly and customer reports |
| 12.png | Ravi project properties stored in Hive |


