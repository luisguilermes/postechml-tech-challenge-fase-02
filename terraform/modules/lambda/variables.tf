# tech-challenge-b3/terraform/modules/lambda/variables.tf

variable "lambda_bucket_name" {
  type        = string
  description = "Nome do bucket onde está o código da Lambda"
}

variable "lambda_role_arn" {
  type        = string
  description = "ARN do papel IAM para execução da Lambda"
}

variable "glue_job_name" {
  type        = string
  description = "Nome do job Glue que a Lambda irá acionar"
}

variable "raw_bucket_name" {
  type        = string
  description = "Nome do bucket S3 que aciona a Lambda via evento"
}
