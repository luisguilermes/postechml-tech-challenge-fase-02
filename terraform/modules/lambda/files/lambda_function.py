import json
import boto3
import urllib.parse
import os
from datetime import datetime


def lambda_handler(event, context):
    """
    Lambda function to trigger Glue job when a parquet file is uploaded to S3
    """

    # Initialize Glue client
    glue_client = boto3.client("glue")

    # Get environment variables
    glue_job_name = os.environ["GLUE_JOB_NAME"]

    try:
        # Process each record in the event
        for record in event["Records"]:
            # Get bucket and object key from the event
            bucket = record["s3"]["bucket"]["name"]
            key = urllib.parse.unquote_plus(
                record["s3"]["object"]["key"], encoding="utf-8"
            )

            print(f"Processing file: s3://{bucket}/{key}")

            # Extract date from file path or use current date
            # Expecting path like: b3/2025-08-02/data.parquet
            try:
                path_parts = key.split("/")
                if len(path_parts) >= 2 and path_parts[0] == "b3":
                    # Extract date from path: b3/YYYY-MM-DD/data.parquet
                    date_ref = path_parts[1]
                    # Validate date format
                    datetime.strptime(date_ref, "%Y-%m-%d")
                else:
                    # Use current date if path structure doesn't match
                    date_ref = datetime.now().strftime("%Y-%m-%d")
            except (IndexError, ValueError):
                # Fallback to current date
                date_ref = datetime.now().strftime("%Y-%m-%d")

            # Prepare Glue job arguments
            job_arguments = {
                "--BUCKET": bucket, 
                "--DATE": date_ref,
                "--DATABASE_NAME": "b3_pipeline_database",
                "--TABLE_NAME": "ibov_refinado"
            }

            # Start Glue job
            response = glue_client.start_job_run(
                JobName=glue_job_name, Arguments=job_arguments
            )

            job_run_id = response["JobRunId"]

            print(f"Started Glue job: {glue_job_name}")
            print(f"Job Run ID: {job_run_id}")
            print(f"Processing date: {date_ref}")
            print(f"Input bucket: {bucket}")
            print(f"Triggered by file: {key}")

        return {
            "statusCode": 200,
            "body": json.dumps(
                {
                    "message": "Glue job triggered successfully",
                    "jobRunId": job_run_id,
                    "processedFiles": len(event["Records"]),
                    "bucket": bucket,
                    "date": date_ref,
                }
            ),
        }

    except Exception as e:
        print(f"Error triggering Glue job: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps(
                {"message": "Error triggering Glue job", "error": str(e)}
            ),
        }
