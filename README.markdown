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
  - S3: 5 GB standard storage, 20,000 GET requests, 2,000 PUT requests per month (always free).
  - Lambda: 1 million requests, 400,000 GB-seconds compute time per month (always free).
  - Rekognition: 5,000 images per month (12-month trial).
  - Bedrock: Model-dependent free inferences (e.g., Claude 3 Haiku) + up to $200 credits for new accounts (as of 2025).
- **Extensibility**: Easy setup via AWS Console for deployment and testing.



## Setup and Deployment
Follow these steps in the AWS Management Console to deploy the project. 

### 1. Prepare the Lambda Code
1. Clone or download this repository from [github.com/Chaitanya980/aws-serverless-image-recog](https://github.com/Chaitanya980/aws-serverless-image-recog).
2. Locate `lambda_function.py` in the repository 
        


### 2. Create IAM Role
1. Log in to the AWS Management Console at [console.aws.amazon.com](https://console.aws.amazon.com).
2. Search for "IAM" in the top search bar and select IAM.
3. Click "Roles" > "Create role" in the left navigation.
4. Choose "AWS service" > "Lambda" > "Next".
5. Attach the following policies:
   - `AmazonS3ReadOnlyAccess`
   - `AmazonRekognitionFullAccess`
   - `AmazonBedrockFullAccess`
   - `CloudWatchLogsFullAccess`
6. Click "Next".
7. Name the role `lambda-image-role` and click "Create role".
8. Note the ARN from the role’s summary page (e.g., `arn:aws:iam::YOURACCOUNTID:role/lambda-image-role`).

### 3. Create S3 Bucket
1. In the AWS Console, search for "S3" and select S3.
2. Click "Create bucket".
3. Enter a name to the bucker (e.g., `image-api-bucket`).
4. Select region: "US East (N. Virginia) us-east-1".
5. Keep defaults (e.g., block public access) and click "Create bucket".

### 4. Deploy Lambda Function
1. In the AWS Console, search for "Lambda" and select Lambda.
2. Click "Create function".
3. Select "Author from scratch".
4. Function name: `image_classifier`.
5. Runtime: "Python 3.12".
6. Execution role: Choose "Use an existing role" > Select `lambda-image-role`.
7. Click "Create function".
8. In the "Code" tab:
   - Click "Upload from" > ".zip file".
   - On your computer, create a ZIP file containing only `lambda_function.py` (no folders). In Windows, right-click the file > Send to > Compressed (zipped) folder. On macOS/Linux, use `zip function.zip lambda_function.py`.
   - Upload the ZIP file.
9. In the "Configuration" tab > "General configuration" > "Edit":
   - Timeout: 20-30 seconds.
   - Memory: 1024 MB.
   - Save changes.
10. Click "Deploy".

### 5. Configure S3 Trigger
1. In the Lambda function’s page, scroll to "Function overview" > "Add trigger".
2. Select "S3".
3. Bucket: Choose your bucket (e.g., `image-api-bucke`').
4. Event type: "All object create events".
5. Optional: Add suffix filters (e.g., `.jpg`, `.png`, `.jpeg`) by repeating this step for each.
6. Click "Add".
7. Confirm any permission prompts (Lambda will auto-add permissions).

### 6. Test the Project
1. In the S3 Console, navigate to your bucket.
2. Click "Upload" > "Add files".
3. Select a test image (e.g., `sample_images/test1.jpg` from the repo or any JPG/PNG).
4. Click "Upload".
5. Wait 10-30 seconds.
6. In the Lambda Console > `image_classifier` > "Monitor" tab > "Logs" > "View logs in CloudWatch".
7. Click the latest log stream.





## Future Improvements
- Store results in DynamoDB (25 GB free tier).
- Use Bedrock’s Converse API for direct image input (multimodal models).
- Add API Gateway for a REST endpoint (1M calls free).
- Implement custom ML (e.g., ResNet50) via Lambda Layers.

## Contributing
Fork, modify, and submit pull requests. Issues and suggestions are welcome!

---

Built by Chaitanya C. A learning project for serverless, ML, and LLM on AWS.
