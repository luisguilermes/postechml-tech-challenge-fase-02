# tech-challenge-b3/terraform/modules/glue/variables.tf

variable "glue_role_arn" {
  type        = string
  description = "ARN do papel IAM para execução do Glue Job"
}

variable "glue_script_location" {
  type        = string
  description = "Caminho S3 para o script do Glue"
}

variable "refined_bucket_name" {
  type        = string
  description = "Nome do bucket S3 para dados refinados"
}

variable "lambda_bucket_name" {
  type        = string
  description = "Nome do bucket S3 para código Lambda e logs"
}
