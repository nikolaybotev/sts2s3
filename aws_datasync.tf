# DataSync Location for GCS (Source)
resource "aws_datasync_location_object_storage" "gcs_source" {
  bucket_name     = google_storage_bucket.source_bucket.name
  server_hostname = "storage.googleapis.com"
  server_protocol = "HTTPS"

  # Enhanced mode - no agent required
  agent_arns = []

  # GCS credentials
  access_key = var.gcs_access_key_id
  secret_key = var.gcs_secret_access_key

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "datasync-gcs-source"
  }
}

# DataSync Location for S3 (Destination)
resource "aws_datasync_location_s3" "s3_destination" {
  s3_bucket_arn = aws_s3_bucket.destination_bucket.arn
  subdirectory  = "/"

  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync_s3_role.arn
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "datasync-s3-destination"
  }
}

# IAM Role for DataSync to access S3
resource "aws_iam_role" "datasync_s3_role" {
  name = "${var.project_name}-${var.environment}-datasync-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "datasync.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "datasync-s3-access"
  }
}

# IAM Policy for DataSync S3 access
resource "aws_iam_role_policy" "datasync_s3_policy" {
  name = "${var.project_name}-${var.environment}-datasync-s3-policy"
  role = aws_iam_role.datasync_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = aws_s3_bucket.destination_bucket.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:GetObjectTagging",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
          "s3:PutObjectTagging",
          "s3:GetObjectVersion",
          "s3:GetObjectVersionTagging",
          "s3:DeleteObjectVersion"
        ]
        Resource = "${aws_s3_bucket.destination_bucket.arn}/*"
      }
    ]
  })
}

# Data source to reference the AWS DataSync log group
data "aws_cloudwatch_log_group" "datasync_logs" {
  name = "/aws/datasync"
}

# DataSync Task (without schedule - manual execution)
resource "aws_datasync_task" "gcs_to_s3_transfer" {
  name                     = "${var.project_name}-${var.environment}-gcs-to-s3-task"
  source_location_arn      = aws_datasync_location_object_storage.gcs_source.arn
  destination_location_arn = aws_datasync_location_s3.s3_destination.arn
  cloudwatch_log_group_arn = data.aws_cloudwatch_log_group.datasync_logs.arn
  task_mode                = "ENHANCED"

  options {
    verify_mode                    = var.datasync_verify_mode
    overwrite_mode                 = var.datasync_overwrite_mode
    preserve_deleted_files         = var.datasync_preserve_deleted_files
    preserve_devices               = "NONE"
    posix_permissions              = "NONE"
    uid                            = "NONE"
    gid                            = "NONE"
    atime                          = "BEST_EFFORT"
    mtime                          = "PRESERVE"
    task_queueing                  = "ENABLED"
    log_level                      = var.datasync_log_level
    transfer_mode                  = "CHANGED"
    security_descriptor_copy_flags = "NONE"
    object_tags                    = "NONE"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "gcs-to-s3-transfer"
  }

  depends_on = [
    aws_datasync_location_object_storage.gcs_source,
    aws_datasync_location_s3.s3_destination,
    aws_iam_role_policy.datasync_s3_policy,
  ]
}
