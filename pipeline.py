"""Run with spark-submit --master 'local[2]' pipeline.py --input hdfs:///iphone/raw."""
import argparse
from pyspark.sql import SparkSession, functions as F

parser = argparse.ArgumentParser()
parser.add_argument('--input', default='hdfs:///iphone/raw')
parser.add_argument('--warehouse', default='hdfs:///warehouse/tablespace/managed/hive')
args = parser.parse_args()
spark = (SparkSession.builder.appName('Ravi iPhone Sales Analytics')
         .config('spark.ui.enabled', 'false')
         .enableHiveSupport().getOrCreate())
spark.sql('CREATE DATABASE IF NOT EXISTS iphone_analytics')
spark.sql("ALTER DATABASE iphone_analytics SET DBPROPERTIES ('project.name'='Ravi iPhone Sales Analytics','project.student'='Ravi')")
spark.sql('USE iphone_analytics')
spark.conf.set('spark.sql.shuffle.partitions', '4')
spark.conf.set('spark.sql.sources.partitionOverwriteMode', 'static')

schemas = {
    'customers': [('customer_id','int'),('customer_name','string'),('city','string'),('state','string')],
    'products': [('product_id','int'),('product_name','string'),('category','string'),('unit_price','int')],
    'stores': [('store_id','int'),('store_name','string'),('city','string'),('state','string')],
    'sales': [('sale_id','int'),('product_id','int'),('customer_id','int'),('store_id','int'),('sale_date','date'),('quantity','int')],
}

def write(df, name, partition=None):
    writer = df.write.mode('overwrite').format('parquet').option('path', args.warehouse.rstrip('/') + '/' + name)
    if partition:
        writer = writer.partitionBy(partition)
    writer.saveAsTable(name)
    spark.sql("ALTER TABLE " + name + " SET TBLPROPERTIES ('project.name'='Ravi iPhone Sales Analytics','project.student'='Ravi')")

silver = {}
for source, fields in schemas.items():
    raw = spark.read.option('header', True).option('mode','FAILFAST').csv(args.input.rstrip('/') + '/' + source + '.csv')
    if raw.columns != [name for name, _ in fields]:
        raise ValueError('Unexpected CSV columns: ' + source)
    write(raw, 'bronze_' + source)
    clean = raw.select(*[F.trim(F.col(name)).cast(dtype).alias(name) for name, dtype in fields]).dropna()
    key = fields[0][0]
    clean = clean.filter(F.col(key) > 0)
    if source == 'sales':
        clean = clean.filter((F.col('quantity') > 0) & (F.col('product_id') > 0) & (F.col('customer_id') > 0) & (F.col('store_id') > 0))
    elif source == 'products':
        clean = clean.filter(F.col('unit_price') >= 0)
    else:
        clean = clean.withColumn('state', F.upper('state'))
    clean = clean.dropDuplicates()
    if clean.groupBy(key).count().filter('count > 1').count():
        raise ValueError('Conflicting duplicate keys: ' + source)
    silver[source] = clean

sales = silver['sales']
for source, key in [('products','product_id'),('customers','customer_id'),('stores','store_id')]:
    if sales.join(silver[source].select(key), key, 'left_anti').count():
        raise ValueError('Unmatched sales foreign key: ' + key)
for source, clean in silver.items():
    write(clean, 'silver_' + source, 'sale_date' if source == 'sales' else None)
for source, target in [('customers','dim_customer'),('products','dim_product'),('stores','dim_store')]:
    write(silver[source], target)
dates = sales.select(F.col('sale_date').alias('date_key')).distinct()
write(dates.select('date_key',F.year('date_key').alias('year'),F.month('date_key').alias('month'),F.dayofmonth('date_key').alias('day')), 'dim_date')
fact = sales.join(silver['products'], 'product_id').select('sale_id','customer_id','product_id','store_id',F.col('sale_date').alias('date_key'),'quantity',(F.col('quantity').cast('long')*F.col('unit_price').cast('long')).alias('total_amount'))
write(fact, 'fact_sales', 'date_key')
assert fact.count() == sales.count(), 'Unexpected fact row count'
for name in ['bronze_sales','silver_sales','fact_sales']:
    print(name, spark.table(name).count())
spark.sql('SELECT SUM(quantity) AS units, SUM(total_amount) AS revenue FROM fact_sales').show()
spark.stop()
