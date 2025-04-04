output "reference_bucket" {
  value = aws.aws_s3_bucket.reference_bucket.id
}

output "database_bucket" {
  value = aws.aws_s3_bucket.database_bucket.id
}

