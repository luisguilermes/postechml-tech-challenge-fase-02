# tech-challenge-b3/terraform/modules/glue/main.tf

# Requisito 7: Criar banco de dados no Glue Catalog
resource "aws_glue_catalog_database" "b3_database" {
  name        = "b3_pipeline_database"
  description = "Database for B3 pipeline data"
}

# Data source para obter informações da conta AWS
data "aws_caller_identity" "current" {}

# Requisito 7: Criar tabela no Glue Catalog para dados refinados
resource "aws_glue_catalog_table" "ibov_refinado" {
  name          = "ibov_refinado"
  database_name = aws_glue_catalog_database.b3_database.name
  description   = "Tabela com dados refinados do IBOV"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification"            = "parquet"
    "compressionType"           = "none"
    "typeOfData"                = "file"
    "has_encrypted_data"        = "false"
    "projection.enabled"        = "true"
    "projection.ano.type"       = "integer"
    "projection.ano.range"      = "2020,2030"
    "projection.mes.type"       = "integer"
    "projection.mes.range"      = "1,12"
    "projection.dia.type"       = "integer"
    "projection.dia.range"      = "1,31"
    "projection.ticker.type"    = "enum"
    "projection.ticker.values"  = "PETR4,VALE3,ITUB4" # ajuste conforme necessário
    "storage.location.template" = "s3://${var.refined_bucket_name}/refined/b3/$${ano}/$${mes}/$${dia}/$${ticker}/"
  }

  partition_keys {
    name = "ano"
    type = "int"
  }

  partition_keys {
    name = "mes"
    type = "int"
  }

  partition_keys {
    name = "dia"
    type = "int"
  }

  partition_keys {
    name = "ticker"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${var.refined_bucket_name}/refined/b3/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "empresa"
      type = "string"
    }

    columns {
      name = "type"
      type = "string"
    }

    columns {
      name = "num_registros"
      type = "bigint"
    }

    columns {
      name = "soma_quantidade_teorica"
      type = "double"
    }

    columns {
      name = "soma_participacao_pct"
      type = "double"
    }

    columns {
      name = "data_processamento"
      type = "string"
    }
  }
}


# Glue Job
resource "aws_glue_job" "etl_bovespa" {
  name     = "b3-pipeline-etl-bovespa"
  role_arn = var.glue_role_arn

  command {
    name            = "glueetl"
    script_location = var.glue_script_location
    python_version  = "3"
  }

  default_arguments = {
    "--enable-metrics"               = "true"
    "--enable-spark-ui"              = "true"
    "--spark-event-logs-path"        = "s3://${var.lambda_bucket_name}/spark-logs/"
    "--enable-job-insights"          = "false"
    "--enable-observability-metrics" = "true"
    "--job-bookmark-option"          = "job-bookmark-enable"
    "--TempDir"                      = "s3://${var.lambda_bucket_name}/temp/"
    "--DATABASE_NAME"                = aws_glue_catalog_database.b3_database.name
    "--TABLE_NAME"                   = aws_glue_catalog_table.ibov_refinado.name
  }

  glue_version      = "4.0"
  max_retries       = 1
  number_of_workers = 2
  worker_type       = "G.1X"

  execution_property {
    max_concurrent_runs = 1
  }

  depends_on = [
    aws_glue_catalog_database.b3_database,
    aws_glue_catalog_table.ibov_refinado
  ]
}

# Outputs para outros módulos
output "glue_job_name" {
  value = aws_glue_job.etl_bovespa.name
}

output "database_name" {
  value = aws_glue_catalog_database.b3_database.name
}

output "table_name" {
  value = aws_glue_catalog_table.ibov_refinado.name
}
