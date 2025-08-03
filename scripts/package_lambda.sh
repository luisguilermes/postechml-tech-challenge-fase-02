#!/bin/bash

# Create Lambda deployment package
echo "Creating Lambda deployment package..."

# Create a temporary directory
mkdir -p temp_lambda

# Copy Lambda function to temp directory
cp scripts/lambda_function.py temp_lambda/

# Create ZIP file
cd temp_lambda
zip -r ../files/lambda_function.zip .
cd ..

# Clean up temp directory
rm -rf temp_lambda

echo "Lambda deployment package created: lambda_function.zip"
