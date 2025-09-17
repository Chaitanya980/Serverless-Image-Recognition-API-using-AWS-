#!/bin/bash
# Deploy Lambda function and configure S3 trigger
set -e

BUCKET_NAME=$1
ACCOUNT_ID=$2

if [ -z "$BUCKET_NAME" ] || [ -z "$ACCOUNT_ID" ]; then
  echo "Usage: $0 <bucket-name> <account-id>"
  exit 1
fi

echo "Zipping code..."
zip function.zip lambda_function.py

echo "Creating Lambda function..."
aws lambda create-function --function-name image_classifier \
  --zip-file fileb://function.zip \
  --handler lambda_function.lambda_handler \
  --runtime python3.12 \
  --role arn:aws:iam::$ACCOUNT_ID:role/lambda-image-role \
  --timeout 30 --memory-size 1024 --region us-east-1

echo "Adding S3 trigger permission..."
aws lambda add-permission --function-name image_classifier \
  --statement-id s3-trigger --action lambda:InvokeFunction \
  --principal s3.amazonaws.com \
  --source-arn arn:aws:s3:::$BUCKET_NAME

echo "Configuring S3 trigger..."
aws s3api put-bucket-notification-configuration --bucket $BUCKET_NAME \
  --notification-configuration '{
    "LambdaFunctionConfigurations": [{
      "LambdaFunctionArn": "arn:aws:lambda:us-east-1:'$ACCOUNT_ID':function:image_classifier",
      "Events": ["s3:ObjectCreated:*"],
      "Filter": {
        "Key": {
          "FilterRules": [{"Name": "suffix", "Value": ".jpg"}, {"Name": "suffix", "Value": ".png"}, {"Name": "suffix", "Value": ".jpeg"}]
        }
      }
    }]
  }'

echo "Deployment complete."
