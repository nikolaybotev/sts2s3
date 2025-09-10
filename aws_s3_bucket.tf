# S3 Bucket
resource "aws_s3_bucket" "destination_bucket" {
  bucket = "${var.project_name}-${var.environment}-s3-destination"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "sts-transfer-destination"
  }
}

resource "aws_s3_bucket_versioning" "destination_bucket_versioning" {
  bucket = aws_s3_bucket.destination_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "destination_bucket_lifecycle" {
  bucket = aws_s3_bucket.destination_bucket.id

  rule {
    id     = "delete_old_versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}
