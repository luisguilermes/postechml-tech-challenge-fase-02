# tech-challenge-b3/terraform/modules/s3/variables.tf

variable "raw_bucket_name" {
  type        = string
  description = "Nome do bucket S3 para dados brutos"
}

variable "refined_bucket_name" {
  type        = string
  description = "Nome do bucket S3 para dados refinados"
}

variable "lambda_bucket_name" {
  type        = string
  description = "Nome do bucket S3 para código da Lambda e scripts Glue"
}

variable "glue_script_key" {
  type        = string
  description = "Caminho do script Glue dentro do bucket da Lambda"
}
