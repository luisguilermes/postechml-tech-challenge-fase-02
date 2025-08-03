# tech-challenge-b3/terraform/modules/athena/variables.tf

variable "athena_results_bucket_name" {
  type        = string
  description = "Nome do bucket S3 para resultados das consultas Athena"
}

variable "database_name" {
  type        = string
  description = "Nome do banco de dados no Glue Catalog"
}

variable "table_name" {
  type        = string
  description = "Nome da tabela no Glue Catalog"
}
