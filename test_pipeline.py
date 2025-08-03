import json
import boto3
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
from datetime import datetime
from io import BytesIO


def create_test_data():
    # Sample data matching the B3 API structure
    sample_data = [
        {
            "segment": None,
            "cod": "ALOS3",
            "asset": "ALLOS",
            "type": "ON      NM",
            "part": "0,503",
            "partAcum": None,
            "theoricalQty": "476.976.044",
        },
        {
            "segment": None,
            "cod": "PETR4",
            "asset": "PETROBRAS",
            "type": "PN      N2",
            "part": "8,125",
            "partAcum": None,
            "theoricalQty": "12.345.678.901",
        },
        {
            "segment": None,
            "cod": "VALE3",
            "asset": "VALE",
            "type": "ON      NM",
            "part": "7,892",
            "partAcum": None,
            "theoricalQty": "9.876.543.210",
        },
    ]

    hoje = datetime.today().strftime("%Y-%m-%d")

    # Create DataFrame and convert to parquet
    df = pd.DataFrame(sample_data)
    table = pa.Table.from_pandas(df)

    # Convert to parquet and upload to S3
    buffer = BytesIO()
    pq.write_table(table, buffer)

    s3_path = f"b3/{hoje}/test_data.parquet"
    s3_bucket = "b3-raw-pipeline-data"
    s3 = boto3.client("s3")

    print(f"Uploading test data to s3://{s3_bucket}/{s3_path}")
    s3.put_object(Bucket=s3_bucket, Key=s3_path, Body=buffer.getvalue())

    print(f"Test data uploaded successfully for date: {hoje}")
    return {"statusCode": 200, "body": json.dumps(f"Test data uploaded for {hoje}")}


if __name__ == "__main__":
    create_test_data()
