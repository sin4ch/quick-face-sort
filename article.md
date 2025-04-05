# Building a Serverless Image Organizer with AWS Rekognition and Terraform

## Introduction

Have you ever found yourself drowning in thousands of photos, desperately looking for pictures of specific people? In this article, I'll walk you through building **Quick Face Sort**, an automated solution that uses AWS's facial recognition capabilities to organize your images.

## The Problem: Digital Photo Overload

Most of us accumulate thousands of images through messaging apps like WhatsApp. While a lot of these are memes or screenshots we don't need to keep, some contain precious moments with family and friends. Manually sorting through this digital pile is time-consuming and tedious.


![Automate Instead](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/uy66aiw3ynlm0gv4rref.png)

## The Solution: Quick Face Sort

Quick Face Sort is a serverless application that:
1. Takes reference photos of people you want to find
2. Scans through your image collection
3. Automatically groups photos containing those people

The entire process is event-driven and serverless, meaning it scales automatically and you only pay for what you use.

## Architecture Overview

![Architecture Diagram](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/t3awwxjpbpi9pxau8iqe.png)

The solution uses these AWS services:
- **S3**: Two buckets, one for reference faces and another for images to be sorted
- **Lambda**: Serverless function that processes images using facial recognition
- **Rekognition**: AWS's AI service for image analysis 
- **CloudWatch**: For monitoring and logging

## How It Works

1. You upload reference photos to the reference S3 bucket
2. You upload your unsorted photos to the database S3 bucket
3. S3 event notifications trigger the Lambda function
4. The Lambda function uses AWS Rekognition to compare faces
5. Images with matching faces (>95% similarity) are organized into folders
6. Results are logged to CloudWatch for monitoring

## Building the Solution with Terraform

Let's dive into the code. We'll use Terraform to define our infrastructure as code:

### 1. S3 Buckets for Image Storage

```terraform
resource "aws_s3_bucket" "reference_bucket" {
  bucket = "quicksort-reference-bucket-20250404"
}

resource "aws_s3_bucket" "database_bucket" {
  bucket = "quicksort-database-bucket-20250404"
}

# Set security controls
resource "aws_s3_bucket_public_access_block" "reference_access_block" {
  bucket = aws_s3_bucket.reference_bucket.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### 2. Lambda Function with Python

The Lambda function uses Python and the Boto3 SDK to:
- List images in both buckets
- Compare faces using Rekognition
- Organize matches into folders

```terraform
def compare_faces(source_image, target_image, similarity_threshold=90):
    try:
        response = rekognition.compare_faces(
            SourceImage={
                'S3Object': {
                    'Bucket': reference_bucket,
                    'Name': source_image
                }
            },
            TargetImage={
                'S3Object': {
                    'Bucket': database_bucket,
                    'Name': target_image
                }
            },
            SimilarityThreshold=similarity_threshold
        )
        return response
    except Exception as e:
        logger.error(f"Error comparing faces: {str(e)}")
        return None
```
### 3. IAM Roles and Permissions

```terraform
resource "aws_iam_role" "lambda_role" {
  name = "quicksort_lambda_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow"
    }]
  })
}

# Custom policy for S3 and Rekognition access
resource "aws_iam_policy" "lambda_policy" {
  name = "quicksort_lambda_policy"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:CopyObject",
          "s3:ListBucket",
        ],
        Resource = [
          aws_s3_bucket.reference_bucket.arn,
          "${aws_s3_bucket.reference_bucket.arn}/*",
          aws_s3_bucket.database_bucket.arn,
          "${aws_s3_bucket.database_bucket.arn}/*"
        ],
        Effect = "Allow"
      },
      {
        Action = ["rekognition:CompareFaces"],
        Resource = "*",
        Effect = "Allow"
      }
    ]
  })
}
```

### 4. S3 Event Notifications

```terraform
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.database_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.quicksort_function.arn
    events              = ["s3:ObjectCreated:*"]
  }
}
```

## Deployment and Usage
Deploying the solution is straightforward:

### 1. Clone the repository:

```bash
git clone https://github.com/sin4ch/quick-face-sort.git
cd quick-face-sort
```
### 2. Deploy with Terraform:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Cost Considerations
This solution uses several AWS services that incur costs:

- S3 storage for your images
- Lambda function invocations
- Rekognition API calls
- CloudWatch Logs

The good news is that AWS's pricing model means you only pay for what you use. For personal photo libraries, costs should be minimal.

## Security Notes

The application uses best practices for security:

- Private S3 buckets with no public access
- Least-privilege IAM permissions
- No long-term storage of facial recognition data

## Conclusion

Quick Face Sort demonstrates the power of combining serverless computing and AI services to solve real-world problems. With minimal code and maintenance, you can build a solution that automatically organizes thousands of photos, saving hours of manual work.

The complete code is available on [GitHub](https://github.com/sin4ch/quick-face-sort) - feel free to use it, contribute, or adapt it for your needs.

---

Have you built something similar? How do you organize your photo collections? I'd love to hear your thoughts and questions in the comments! 😊🧡