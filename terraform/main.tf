provider "aws" {}

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

