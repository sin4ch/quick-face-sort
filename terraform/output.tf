output "reference_bucket" {
  description = "The name of the S3 bucket containing reference face images"
  value       = aws_s3_bucket.reference_bucket.id
}

output "database_bucket" {
  description = "The name of the S3 bucket containing images to be sorted"
  value       = aws_s3_bucket.database_bucket.id
}

output "lambda_function_name" {
  description = "Name of the deployed Lambda function"
  value       = aws_lambda_function.quicksort_function.function_name
}

output "lambda_function_arn" {
  description = "ARN of the deployed Lambda function"
  value       = aws_lambda_function.quicksort_function.arn
}

output "cloudwatch_log_group" {
  description = "CloudWatch Log Group for Lambda function logs"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

