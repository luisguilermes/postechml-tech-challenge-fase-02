# tech-challenge-b3/terraform/modules/iam/variables.tf

variable "raw_bucket_arn" {
  description = "ARN of the raw data S3 bucket"
  type        = string
  default     = ""
}

variable "refined_bucket_arn" {
  description = "ARN of the refined data S3 bucket"
  type        = string
  default     = ""
}

variable "lambda_bucket_arn" {
  description = "ARN of the lambda code S3 bucket"
  type        = string
  default     = ""
}
