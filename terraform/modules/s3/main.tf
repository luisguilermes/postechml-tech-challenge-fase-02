# tech-challenge-b3/terraform/modules/s3/main.tf

resource "aws_s3_bucket" "raw" {
  bucket        = var.raw_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket" "refined" {
  bucket        = var.refined_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket" "lambda" {
  bucket        = var.lambda_bucket_name
  force_destroy = true
}

resource "aws_s3_object" "glue_script" {
  bucket = aws_s3_bucket.lambda.id
  key    = var.glue_script_key
  source = "../glue-scripts/etl_bovespa.py"
  etag   = filemd5("../glue-scripts/etl_bovespa.py")
}

output "raw_bucket_name" {
  value = aws_s3_bucket.raw.id
}

output "refined_bucket_name" {
  value = aws_s3_bucket.refined.id
}

output "lambda_bucket_name" {
  value = aws_s3_bucket.lambda.id
}

output "raw_bucket_arn" {
  value = aws_s3_bucket.raw.arn
}

output "refined_bucket_arn" {
  value = aws_s3_bucket.refined.arn
}

output "lambda_bucket_arn" {
  value = aws_s3_bucket.lambda.arn
}

output "glue_script_location" {
  value = "s3://${aws_s3_bucket.lambda.id}/${var.glue_script_key}"
}
