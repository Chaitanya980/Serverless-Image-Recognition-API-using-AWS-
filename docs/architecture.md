# System Architecture

This project uses AWS serverless services:

1. **Amazon S3**: Stores images. Triggers Lambda on upload (`s3:ObjectCreated:*`).
2. **AWS Lambda**: Runs Python code for processing (Python 3.12).
3. **Amazon Rekognition**: Classifies images (DetectLabels API).
4. **Amazon Bedrock**: Generates captions (Claude 3 Haiku).
5. **CloudWatch**: Logs results.

**Flow**:
1. Image uploaded to S3.
2. S3 event triggers Lambda.
3. Lambda calls Rekognition for labels.
4. Lambda calls Bedrock for caption using labels.
5. Results logged to CloudWatch.

