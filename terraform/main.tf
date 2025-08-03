# tech-challenge-b3/terraform/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}

module "s3" {
  source              = "./modules/s3"
  raw_bucket_name     = "b3-raw-pipeline-data"
  refined_bucket_name = "b3-refined-pipeline-data"
  lambda_bucket_name  = "b3-lambda-pipeline-code"
  glue_script_key     = "scripts/etl_bovespa.py"
}

module "iam" {
  source             = "./modules/iam"
  raw_bucket_arn     = module.s3.raw_bucket_arn
  refined_bucket_arn = module.s3.refined_bucket_arn
  lambda_bucket_arn  = module.s3.lambda_bucket_arn
}

module "lambda" {
  source             = "./modules/lambda"
  lambda_bucket_name = module.s3.lambda_bucket_name
  glue_job_name      = module.glue.glue_job_name
  lambda_role_arn    = module.iam.lambda_role_arn
  raw_bucket_name    = module.s3.raw_bucket_name
}

module "glue" {
  source               = "./modules/glue"
  glue_role_arn        = module.iam.glue_role_arn
  glue_script_location = module.s3.glue_script_location
  refined_bucket_name  = module.s3.refined_bucket_name
  lambda_bucket_name   = module.s3.lambda_bucket_name
}

# Requisito 8: Módulo Athena para consultas
module "athena" {
  source                     = "./modules/athena"
  athena_results_bucket_name = "b3-athena-query-results-${random_id.bucket_suffix.hex}"
  database_name              = module.glue.database_name
  table_name                 = module.glue.table_name
}

# ID aleatório para garantir nomes únicos de buckets
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Outputs importantes para uso do Athena
output "athena_workgroup" {
  value       = module.athena.workgroup_name
  description = "Use este workgroup no Athena Console: b3-pipeline-workgroup"
}

output "database_name" {
  value       = module.glue.database_name
  description = "Nome do database no Glue Catalog: b3_pipeline_database"
}

output "table_name" {
  value       = module.glue.table_name
  description = "Nome da tabela catalogada: ibov_refinado"
}

output "sample_query" {
  value       = module.athena.sample_query
  description = "Query de exemplo para testar no Athena"
}

output "athena_results_bucket" {
  value       = module.athena.athena_results_bucket
  description = "Bucket S3 para resultados das consultas Athena"
}

output "instructions" {
  value       = <<EOF

=== INSTRUÇÕES PARA USAR O ATHENA ===

1. Acesse o AWS Athena Console
2. Selecione o workgroup: b3-pipeline-workgroup
3. Use esta query de teste:
   SELECT * FROM b3_pipeline_database.ibov_refinado LIMIT 10;

4. Ou use as Named Queries já criadas:
   - Daily_Market_Summary
   - Top_Stocks_by_Volume
   - Stock_Performance_Analysis

EOF
  description = "Instruções para usar o Athena"
}
