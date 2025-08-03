# B3 Pipeline Deployment Guide

This Terraform configuration creates a complete AWS batch pipeline for processing B3 data with the following components:

## Architecture

1. **S3 Buckets**: Raw and refined data storage
2. **Lambda Function**: Triggered when parquet files are uploaded to the raw bucket
3. **Glue Job**: Processes the data from raw to refined bucket
4. **IAM Roles & Policies**: Proper permissions for all components

## Prerequisites

1. AWS CLI configured with appropriate permissions
2. Terraform installed (>= 1.0)
3. Python script for Glue job in `scripts/grue_transform.py`

## Deployment Steps

### 1. Package Lambda Function

```bash
./package_lambda.sh
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan Deployment

```bash
terraform plan
```

### 4. Apply Configuration

```bash
terraform apply
```

## Pipeline Flow

1. Your external script uploads parquet files to the raw S3 bucket
2. S3 bucket notification triggers the Lambda function
3. Lambda function starts the Glue job with appropriate parameters
4. Glue job processes the data and saves to the refined bucket

## File Structure Expected

The pipeline expects files to be uploaded in this structure:

```
s3://raw-bucket/data/YYYY/MM/DD/filename.parquet
```

If files don't follow this structure, the current date will be used.

## Configuration Variables

You can customize the deployment by modifying `variables.tf`:

- `s3_b3_raw_bucket_name`: Name of the raw data bucket
- `s3_b3_refined_bucket_name`: Name of the refined data bucket
- `aws_region`: AWS region for deployment
- `glue_job_max_capacity`: Glue job capacity (DPU units)
- `lambda_timeout`: Lambda function timeout

## Monitoring

- Lambda logs: `/aws/lambda/b3-trigger-glue-job` in CloudWatch
- Glue job logs: Available in AWS Glue console
- S3 access logs: Can be enabled if needed

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Troubleshooting

1. **Lambda not triggering**: Check S3 bucket notifications and Lambda permissions
2. **Glue job failing**: Check IAM roles and S3 permissions
3. **Access denied errors**: Verify IAM policies are correctly attached

## Cost Optimization

- Glue job uses 2 DPU by default (can be adjusted)
- Lambda is pay-per-use
- S3 storage costs depend on data volume
- Consider S3 lifecycle policies for cost management
