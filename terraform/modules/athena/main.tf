# tech-challenge-b3/terraform/modules/athena/main.tf

# Requisito 8: Configurar Athena para consultar dados
resource "aws_s3_bucket" "athena_results" {
  bucket        = var.athena_results_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "athena_results_versioning" {
  bucket = aws_s3_bucket.athena_results.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena_results_encryption" {
  bucket = aws_s3_bucket.athena_results.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Workgroup do Athena para organizar consultas
resource "aws_athena_workgroup" "b3_workgroup" {
  name = "b3-pipeline-workgroup"

  configuration {
    enforce_workgroup_configuration    = false # Allow users to override settings
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/query-results/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }

  tags = {
    Name        = "B3 Pipeline Workgroup"
    Environment = "production"
    Project     = "b3-pipeline"
  }
}

# Named Query para consultas frequentes
resource "aws_athena_named_query" "top_stocks_by_volume" {
  name      = "Top_Stocks_by_Volume"
  workgroup = aws_athena_workgroup.b3_workgroup.id
  database  = var.database_name

  description = "Consulta para obter os top 10 ativos por volume"

  query = <<EOF
SELECT
    ticker,
    empresa,
    SUM(soma_quantidade_teorica) as total_volume,
    AVG(soma_participacao_pct) as avg_participation,
    COUNT(*) as num_registros_total
FROM "${var.database_name}"."${var.table_name}"
WHERE ano = YEAR(CURRENT_DATE)
    AND mes = MONTH(CURRENT_DATE)
GROUP BY ticker, empresa
ORDER BY total_volume DESC
LIMIT 10;
EOF
}

resource "aws_athena_named_query" "daily_market_summary" {
  name      = "Daily_Market_Summary"
  workgroup = aws_athena_workgroup.b3_workgroup.id
  database  = var.database_name

  description = "Resumo diário do mercado"

  query = <<EOF
SELECT
    CONCAT(CAST(ano AS VARCHAR), '-',
           LPAD(CAST(mes AS VARCHAR), 2, '0'), '-',
           LPAD(CAST(dia AS VARCHAR), 2, '0')) as data_pregao,
    COUNT(DISTINCT ticker) as total_ativos,
    SUM(soma_quantidade_teorica) as volume_total_dia,
    AVG(soma_participacao_pct) as participacao_media
FROM "${var.database_name}"."${var.table_name}"
WHERE ano >= YEAR(CURRENT_DATE) - 1
GROUP BY ano, mes, dia
ORDER BY ano DESC, mes DESC, dia DESC
LIMIT 30;
EOF
}

resource "aws_athena_named_query" "stock_performance_analysis" {
  name      = "Stock_Performance_Analysis"
  workgroup = aws_athena_workgroup.b3_workgroup.id
  database  = var.database_name

  description = "Análise de performance individual de ações"

  query = <<EOF
WITH daily_data AS (
    SELECT
        ticker,
        empresa,
        ano, mes, dia,
        soma_quantidade_teorica,
        soma_participacao_pct,
        ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY ano DESC, mes DESC, dia DESC) as rn
    FROM "${var.database_name}"."${var.table_name}"
    WHERE ticker = 'PETR4' -- Substitua pelo ticker desejado
)
SELECT
    ticker,
    empresa,
    CONCAT(CAST(ano AS VARCHAR), '-',
           LPAD(CAST(mes AS VARCHAR), 2, '0'), '-',
           LPAD(CAST(dia AS VARCHAR), 2, '0')) as data_pregao,
    soma_quantidade_teorica,
    soma_participacao_pct,
    LAG(soma_quantidade_teorica, 1) OVER (ORDER BY ano, mes, dia) as volume_anterior,
    CASE
        WHEN LAG(soma_quantidade_teorica, 1) OVER (ORDER BY ano, mes, dia) > 0
        THEN ((soma_quantidade_teorica - LAG(soma_quantidade_teorica, 1) OVER (ORDER BY ano, mes, dia)) / LAG(soma_quantidade_teorica, 1) OVER (ORDER BY ano, mes, dia)) * 100
        ELSE NULL
    END as variacao_volume_pct
FROM daily_data
WHERE rn <= 30
ORDER BY ano DESC, mes DESC, dia DESC;
EOF
}

# Outputs para referência
output "workgroup_name" {
  value       = aws_athena_workgroup.b3_workgroup.name
  description = "Nome do workgroup Athena para usar nas consultas"
}

output "sample_query" {
  value       = "SELECT * FROM ${var.database_name}.${var.table_name} LIMIT 10;"
  description = "Query de exemplo para testar a integração"
}
