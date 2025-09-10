# S3 Bucket
resource "aws_s3_bucket" "destination_bucket" {
  bucket = "${var.project_name}-${var.environment}-s3-destination"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "sts-transfer-destination"
  }
}
