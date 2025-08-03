# tech-challenge-b3/terraform/modules/lambda/main.tf

resource "aws_lambda_function" "trigger_glue_job" {
  function_name = "b3-pipeline-trigger-glue"
  role          = var.lambda_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  timeout       = 30

  filename         = "files/lambda_function.zip"
  source_code_hash = filebase64sha256("files/lambda_function.zip")

  environment {
    variables = {
      GLUE_JOB_NAME = var.glue_job_name
    }
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger_glue_job.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.raw_bucket_name}"
}

resource "aws_s3_bucket_notification" "s3_event" {
  bucket = var.raw_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.trigger_glue_job.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
  }

  depends_on = [
    aws_lambda_permission.allow_s3
  ]
}

output "lambda_function_name" {
  value = aws_lambda_function.trigger_glue_job.function_name
}
