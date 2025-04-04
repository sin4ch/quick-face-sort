provider "aws" {}

# Reference Bucket
resource "aws_s3_bucket" "reference_bucket" {
  bucket = "quicksort-reference-bucket-20250404"
}

# Reference bucket ownership control
resource "aws_s3_bucket_ownership_controls" "reference_bucket_ownership" {
  bucket = aws_s3_bucket.reference_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Reference Bucket
resource "aws_s3_bucket" "database_bucket" {
  bucket = "quicksort-database-bucket-20250404"
}

# Reference bucket ownership control
resource "aws_s3_bucket_ownership_controls" "database_bucket_ownership" {
  bucket = aws_s3_bucket.database_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

