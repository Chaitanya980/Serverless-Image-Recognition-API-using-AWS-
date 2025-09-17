#!/bin/bash
# Cleanup AWS resources
set -e

BUCKET_NAME=$1

if [ -z "$BUCKET_NAME" ]; then
  echo "Usage: $0 <bucket-name>"
  exit 1
fi

echo "Deleting Lambda function..."
aws lambda delete-function --function-name image_classifier || true

echo "Emptying and deleting S3 bucket..."
aws s3 rm s3://$BUCKET_NAME --recursive || true
aws s3 rb s3://$BUCKET_NAME || true

echo "Cleanup complete."
