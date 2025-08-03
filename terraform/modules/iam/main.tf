# tech-challenge-b3/terraform/modules/iam/main.tf

resource "aws_iam_role" "glue_role" {
  name = "b3-pipeline-glue-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "glue_service" {
  name       = "b3-pipeline-glue-attach"
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Custom policy for Glue job to access S3 buckets
resource "aws_iam_policy" "glue_s3_policy" {
  name = "b3-pipeline-glue-s3-access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "${var.raw_bucket_arn}/*",
          "${var.refined_bucket_arn}/*",
          "${var.lambda_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          var.raw_bucket_arn,
          var.refined_bucket_arn,
          var.lambda_bucket_arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:CreatePartition",
          "glue:BatchCreatePartition",
          "glue:GetPartition",
          "glue:GetPartitions",
          "glue:BatchGetPartition",
          "glue:UpdatePartition",
          "glue:DeletePartition"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "glue_s3_attach" {
  name       = "b3-pipeline-glue-s3-attach"
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = aws_iam_policy.glue_s3_policy.arn
}

resource "aws_iam_role" "lambda_role" {
  name = "b3-pipeline-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_glue_invoke_policy" {
  name = "b3-pipeline-lambda-glue-invoke"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "glue:StartJobRun"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_attach" {
  name       = "b3-pipeline-lambda-policy-attach"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_glue_invoke_policy.arn
}

output "glue_role_arn" {
  value = aws_iam_role.glue_role.arn
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}
