provider "aws" {}

resource "aws_s3_bucket" "reference_bucket" {
  bucket = "reference_bucket"
}

resource "aws_s3_bucket_acl" "reference_bucket_acl" {
    bucket = aws_s3_bucket.reference_bucket.id
    acl   = "private"
}

resource "aws_s3_bucket_acl" "database_bucket_acl" {
    bucket = aws_s3_bucket.database_bucket.id
    acl   = "private"
}

resource "aws_s3_bucket" "database_bucket" {
  bucket = "database_bucket"
}