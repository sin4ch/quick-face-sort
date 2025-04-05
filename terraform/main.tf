provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

# ----------------------------------------------------
# REFERENCE OBJECT BLOCK
# It contains:
# - The reference bucket declaration
# - The ownership control for the bucket
# - The bucket policy access block
# ----------------------------------------------------

resource "aws_s3_bucket" "reference_bucket" {
  bucket = "quicksort-reference-bucket-20250404"
}

resource "aws_s3_bucket_ownership_controls" "reference_bucket_ownership" {
  bucket = aws_s3_bucket.reference_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "reference_access_block" {
  bucket = aws_s3_bucket.reference_bucket.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
 
# ----------------------------------------------------
# DATABASE OBJECT BLOCK
# It contains:
# - The database bucket declaration
# - The ownership control for the bucket
# - The bucket policy access block
# ----------------------------------------------------

resource "aws_s3_bucket" "database_bucket" {
  bucket = "quicksort-database-bucket-20250404"
}

resource "aws_s3_bucket_ownership_controls" "database_bucket_ownership" {
  bucket = aws_s3_bucket.database_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "database_access_block" {
  bucket = aws_s3_bucket.database_bucket.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ----------------------------------------------------
# LAMBDA FUNCTION BLOCK
# It contains:
# - The Lambda IAM role
# - The Lambda function policy
# - The Lambda function definition
# ----------------------------------------------------

# Create ZIP file for Lambda code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../main.py"
  output_path = "${path.module}/lambda_function.zip"
}

# Lambda execution role
resource "aws_iam_role" "lambda_role" {
  name = "quicksort_lambda_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid = ""
    }]
  })
}

# Lambda basic execution policy (for CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom policy for S3 and Rekognition access
resource "aws_iam_policy" "lambda_policy" {
  name        = "quicksort_lambda_policy"
  description = "Allow Lambda to access S3 buckets and use Rekognition"
  
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
        Action = [
          "rekognition:CompareFaces"
        ],
        Resource = "*",
        Effect = "Allow"
      }
    ]
  })
}

# Attach custom policy to role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda function
resource "aws_lambda_function" "quicksort_function" {
  function_name    = "quicksort_face_processor"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.9"
  timeout          = 300  # 5 minutes
  memory_size      = 1024  # 1 GB
  
  environment {
    variables = {
      reference_bucket = aws_s3_bucket.reference_bucket.id
      database_bucket  = aws_s3_bucket.database_bucket.id
    }
  }
}

# ----------------------------------------------------
# S3 EVENT TRIGGER
# It triggers Lambda when new files are uploaded to database bucket
# ----------------------------------------------------

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.quicksort_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.database_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.database_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.quicksort_function.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

# ----------------------------------------------------
# CLOUDWATCH LOG GROUP
# For Lambda function logs with 30 day retention
# ----------------------------------------------------

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.quicksort_function.function_name}"
  retention_in_days = 30
}