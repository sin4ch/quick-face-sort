# Quick Face Sort

An automated solution to sort images based on facial recognition. This tool scans through folders with large amounts of files and organizes media containing specific people you want to keep.

![](https://github.com/sin4ch/quick-face-sort/blob/main/images/automate-instead.jpg)

## Motivation

WhatsApp and other messaging apps often consume large portions of phone storage with unwanted media that we download but don't need long-term. However, some images contain important people (family, friends) that we want to keep. Manually sorting through hundreds or thousands of images is tedious.

Quick Face Sort automates this process using AWS Rekognition to identify and organize images based on faces.

## Architecture

![](https://github.com/sin4ch/quick-face-sort/blob/main/images/quick-face-sort-cloud.png)

## Project Structure

quick-face-sort/
├── README.md
├── main.py
├── test_locally.py
├── requirements.txt
├── .gitignore
├── images/
│   ├── automate-instead.jpg
│   ├── quick-face-sort.png
│   ├── quick-face-sort-cloud.png
│   └── quick-face-sort-local.png
└── terraform/
    ├── main.tf
    ├── output.tf
    └── .terraform.lock.hcl


## Setup Requirements

### Prerequisites
- AWS Account
- AWS CLI installed and configured
- Terraform installed
- Python 3.9+
- Boto3 library

### AWS Configuration

1. **Install AWS CLI**
   - [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) following the official documentation
   - Verify installation with: `aws --version`

2. **Configure AWS Credentials**
   ```bash
   aws configure
   ```
   You'll need to provide:
    - AWS Access Key ID
    - AWS Secret Access Key
    - Default region name (e.g., us-east-1)
    - Default output format (json recommended)
    - Learn more about creating and managing AWS credentials

3. **Required IAM Permissions** Ensure your AWS user has permissions for:
    - S3 (CreateBucket, PutObject, GetObject, etc.)
    - Lambda
    - IAM Role creation
    - CloudWatch Logs
    - Rekognition

    Consider using the AWS managed policies:
    - AmazonS3FullAccess
    - AmazonRekognitionFullAccess
    - AWSLambda_FullAccess
    - IAMFullAccess
    - CloudWatchLogsFullAccess


### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/sin4ch/quick-face-sort.git
   cd quick-face-sort
   ```
2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```
3. **Deploy infrastructure with Terraform**
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```
4. **Upload reference images**
  - Upload photos of people you want to identify to the reference S3 bucket
  - Each person should have at least one clear facial image
5. **Upload images to sort**
- Upload images to the database S3 bucket
- The Lambda function will automatically process these images
6. **View Results**
- Images will be organized into folders named after the reference images
- Check CloudWatch logs for processing details

### Supported Image Formats
AWS Rekognition supports the following image formats:
- JPEG
- PNG
- Note: Other formats may not be properly analyzed

## How It Works

- Reference photos are stored in a dedicated S3 bucket
- New photos uploaded to the database bucket trigger a Lambda function
- The Lambda function uses AWS Rekognition to compare faces
- Images with matching faces are organized into folders
- Logs are stored in CloudWatch for monitoring

## Future Plans

- **Local Version**: A local command-line version may be developed to process images (and videos) directly on your computer.

- **API Version**: An API version may be developed to allow integration with other application

Other relevant information to add:

1. **Cost Warning**: 
   ### AWS Service Costs
   This project uses several AWS services that may incur costs:
   - S3 storage for your images
   - Lambda function invocations
   - Rekognition API calls
   - CloudWatch Logs

   Please review [AWS pricing](https://aws.amazon.com/pricing/) to understand potential costs.

## Troubleshooting

### Common Issues
- **"Access Denied" errors**: Check your AWS credentials and IAM permissions
- **Terraform errors**: Ensure your account has permissions to create all resources
- **Image not recognized**: Ensure faces are clearly visible and well-lit
- **Lambda timeout**: For large images or many comparisons, consider increasing the Lambda timeout in terraform/main.tf

### Viewing Logs
Check CloudWatch Logs for detailed information:
1. Open the AWS Console
2. Navigate to CloudWatch > Log Groups
3. Find the log group named "/aws/lambda/quicksort_face_processor"

### Local Testing
To test the face recognition functionality locally:

1. Configure AWS credentials as described above
2. Run the main.py script directly:
   ```bash
   python main.py
   ```
3. This will process images using your local AWS credentials but still requires connectivity to AWS services
