# AWS Serverless Image Recognition API

This project implements a serverless image recognition API using the AWS Free Tier. When an image is uploaded to an Amazon S3 bucket, it triggers an AWS Lambda function that:
1. **Classifies** the image using Amazon Rekognition's DetectLabels API (a pre-trained model similar to ResNet50 on ImageNet).
2. **Generates** a descriptive caption using Amazon Bedrock's Claude 3 Haiku model (a multimodal LLM).
3. **Logs** the results (labels and caption) to Amazon CloudWatch for viewing.

Designed for aspiring cloud developers, this project leverages AWS's serverless services to keep costs at $0 within Free Tier limits (e.g., <5,000 images/month). It’s an excellent way to learn AWS Lambda, S3, Rekognition, and Bedrock while building a practical ML-powered application.

## Features
- **Trigger**: Image upload to S3 (supports JPG, PNG, JPEG).
- **Classification**: Rekognition identifies top 3 objects with confidence scores (e.g., "Dog: 95%").
- **Captioning**: Bedrock generates creative captions based on detected labels.
- **Output**: Results logged to CloudWatch (viewable in AWS Console).
- **Cost**: Free within AWS Free Tier:
  - S3: 5 GB storage, 20,000 GET, 2,000 PUT requests/month (always free).
  - Lambda: 1M requests, 400,000 GB-seconds compute/month (always free).
  - Rekognition: 5,000 images/month (12-month trial).
  - Bedrock: Model-dependent free inferences (e.g., Claude 3 Haiku) + $200 credits for new accounts (as of 2025).
- **Extensibility**: Scripts for easy deployment and cleanup.




## Setup and Deployment
Follow these steps on your laptop to deploy the project.

### 1. Clone the Repository
```bash
git clone https://github.com/Chaitanya980/aws-serverless-image-recog.git
cd aws-serverless-image-recog
```

### 2. Configure AWS CLI
- Install AWS CLI: Follow [docs.aws.amazon.com/cli](https://docs.aws.amazon.com/cli).
- Run:
  ```bash
  aws configure
  ```
- Enter Access Key ID, Secret Access Key, region (`us-east-1`), and output format (`json`).
- Create keys in AWS Console > IAM > Users > Add User > Attach `AdministratorAccess` (restrict later).

### 3. Create IAM Role
- In AWS Console > IAM > Roles > Create Role:
  - Trusted entity: AWS service > Lambda.
  - Attach policies: `AmazonS3ReadOnlyAccess`, `AmazonRekognitionFullAccess`, `AmazonBedrockFullAccess`, `CloudWatchLogsFullAccess`.
- Name: `lambda-image-role`.
- Note ARN (e.g., `arn:aws:iam::123456789012:role/lambda-image-role`).

### 4. Create S3 Bucket
- Run:
  ```bash
  aws s3 mb s3://your-unique-bucket-name --region us-east-1
  ```
- Use a globally unique name (e.g., `image-upload-bucket-yourname-2025`).
- Or use AWS Console > S3 > Create Bucket.

### 5. Deploy Lambda Function
- Use the provided script:
  ```bash
  chmod +x scripts/deploy.sh
  ./scripts/deploy.sh your-unique-bucket-name your-account-id
  ```
- This zips `lambda_function.py`, creates the Lambda function, and configures the S3 trigger.
- Manual alternative:
  ```bash
  zip function.zip lambda_function.py
  aws lambda create-function --function-name image_classifier \
    --zip-file fileb://function.zip \
    --handler lambda_function.lambda_handler \
    --runtime python3.12 \
    --role arn:aws:iam::YOUR_ACCOUNT_ID:role/lambda-image-role \
    --timeout 30 --memory-size 1024 --region us-east-1
  aws lambda add-permission --function-name image_classifier \
    --statement-id s3-trigger --action lambda:InvokeFunction \
    --principal s3.amazonaws.com \
    --source-arn arn:aws:s3:::your-unique-bucket-name
  aws s3api put-bucket-notification-configuration --bucket your-unique-bucket-name \
    --notification-configuration '{
      "LambdaFunctionConfigurations": [{
        "LambdaFunctionArn": "arn:aws:lambda:us-east-1:YOUR_ACCOUNT_ID:function:image_classifier",
        "Events": ["s3:ObjectCreated:*"],
        "Filter": {
          "Key": {
            "FilterRules": [{"Name": "suffix", "Value": ".jpg"}, {"Name": "suffix", "Value": ".png"}, {"Name": "suffix", "Value": ".jpeg"}]
          }
        }
      }]
    }'
  ```

### 6. Test the Project
- Upload a test image:
  ```bash evenly
  aws s3 cp sample_images/test1.jpg s3://your-unique-bucket-name/
  ```
- Wait 10-30 seconds.
- Check logs in AWS Console > Lambda > image_classifier > Monitor > Logs, or:
  ```bash
  aws logs filter-log-events --log-group-name /aws/lambda/image_classifier --limit 100
  ```
- Expected output: e.g., `Top classifications: [('Dog', 95.0)] Caption: A happy dog running in the park.`

### 7. Cleanup
- Delete resources to avoid charges:
  ```bash
  chmod +x scripts/cleanup.sh
  ./scripts/cleanup.sh your-unique-bucket-name
  ```
- Or manually:
  ```bash
  aws lambda delete-function --function-name image_classifier
  aws s3 rm s3://your-unique-bucket-name --recursive
  aws s3 rb s3://your-unique-bucket-name
  ```
- Delete IAM role via Console > IAM > Roles.



## Future Improvements
- Store results in DynamoDB (25 GB free tier).
- Use Bedrock’s Converse API for direct image input (multimodal models).
- Add API Gateway for a REST endpoint (1M calls free).
- Implement custom ML (e.g., ResNet50) via Lambda Layers.



## Contributing
Fork, modify, and submit pull requests. Issues and suggestions are  welcome!

---

Built by Chaitanya C. A learning project for serverless, ML, and LLM on AWS.
