import sys
from datetime import datetime
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from pyspark.sql.functions import (
    lit,
    col,
    count,
    sum as _sum,
    regexp_replace,
    datediff,
)
from awsglue.utils import getResolvedOptions
from awsglue.dynamicframe import DynamicFrame


# Parâmetros do job
args = getResolvedOptions(
    sys.argv, ["JOB_NAME", "BUCKET", "DATE", "DATABASE_NAME", "TABLE_NAME"]
)
bucket = args["BUCKET"]
data_referencia = args["DATE"]
database_name = args["DATABASE_NAME"]
table_name = args["TABLE_NAME"]

# Inicializa Glue e Spark
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# Caminhos
input_path = f"s3://{bucket}/b3/{data_referencia}/"
output_path = f"s3://b3-refined-pipeline-data/refined/b3/"

# Lê dados Parquet
df = spark.read.parquet(input_path)

# Converte a data de referência
data = datetime.strptime(data_referencia, "%Y-%m-%d")

# Renomeia colunas para nomes mais claros
df = (
    df.withColumnRenamed("cod", "ticker")
    .withColumnRenamed("asset", "empresa")
    .withColumnRenamed("theoricalQty", "quantidade_teorica")
    .withColumnRenamed("part", "participacao_pct")
)

# Remove colunas desnecessárias
df = df.drop("segment", "partAcum")

# Coluna de data de processamento
df = df.withColumn("data_processamento", lit(data_referencia))

# Converte strings para números
df = df.withColumn(
    "participacao_pct_num",
    regexp_replace(col("participacao_pct"), ",", ".").cast("double"),
)

df = df.withColumn(
    "quantidade_teorica_num",
    regexp_replace(col("quantidade_teorica"), "\\.", "").cast("double"),
)

# (Opcional) Exemplo de cálculo com data fictícia se quiser adicionar requisito C
df = df.withColumn("dias_desde_processamento", lit(0))  # ou datediff(...)

# Agrupamento
df_agg = df.groupBy("ticker", "empresa", "type").agg(
    count("*").alias("num_registros"),
    _sum("quantidade_teorica_num").alias("soma_quantidade_teorica"),
    _sum("participacao_pct_num").alias("soma_participacao_pct"),
)

# Cria colunas de partição
df_agg = (
    df_agg.withColumn("ano", lit(data.year))
    .withColumn("mes", lit(data.month))
    .withColumn("dia", lit(data.day))
)

# Escreve no S3 e cria tabela automaticamente no Glue Catalog
glueContext.write_dynamic_frame.from_options(
    frame=DynamicFrame.fromDF(df_agg, glueContext, "refined_df"),
    connection_type="s3",
    connection_options={
        "path": output_path,
        "partitionKeys": ["ano", "mes", "dia", "ticker"],
        "catalogDatabase": database_name,
        "catalogTableName": table_name,
    },
    format="parquet",
)
