import json
import boto3
import urllib.parse

# AWS clients (initialized once for efficiency)
s3_client = boto3.client('s3')
rekognition_client = boto3.client('rekognition')
bedrock_client = boto3.client('bedrock-runtime', region_name='us-east-1')

def lambda_handler(event, context):
    """Lambda function triggered by S3 upload. Classifies image with Rekognition and generates caption with Bedrock."""
    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(record['s3']['object']['key'], encoding='utf-8')
        print(f"Processing file: {key} from bucket: {bucket_name}")

        if not key.lower().endswith(('.png', '.jpg', '.jpeg')):
            print("Not an image file. Skipping.")
            return {'statusCode': 200}

        response = rekognition_client.detect_labels(
            Image={'S3Object': {'Bucket': bucket_name, 'Name': key}},
            MaxLabels=3,
            MinConfidence=70
        )
        labels = [(label['Name'], label['Confidence']) for label in response['Labels']]
        print(f"Top classifications: {labels}")

        image_obj = s3_client.get_object(Bucket=bucket_name, Key=key)
        image_bytes = image_obj['Body'].read()
        
        prompt = "Generate a descriptive caption for this image based on the following labels: " + str(labels) + ". Be creative and detailed."
        body = json.dumps({
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 100,
            "messages": [{"role": "user", "content": [{"type": "text", "text": prompt}]}]
        })
        model_id = 'anthropic.claude-3-haiku-20240307-v1:0'
        response = bedrock_client.invoke_model(
            body=body,
            modelId=model_id,
            accept='application/json',
            contentType='application/json'
        )
        result = json.loads(response.get('body').read())
        caption = result['content'][0]['text']
        print(f"Caption: {caption}")

    return {'statusCode': 200, 'body': json.dumps('Processing complete.')}
