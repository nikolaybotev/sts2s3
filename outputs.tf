output "gcs_bucket_name" {
  description = "Name of the GCS source bucket"
  value       = google_storage_bucket.source_bucket.name
}

output "gcs_bucket_url" {
  description = "URL of the GCS source bucket"
  value       = google_storage_bucket.source_bucket.url
}

output "s3_bucket_name" {
  description = "Name of the S3 destination bucket"
  value       = aws_s3_bucket.destination_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 destination bucket"
  value       = aws_s3_bucket.destination_bucket.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 destination bucket"
  value       = aws_s3_bucket.destination_bucket.bucket_domain_name
}

output "datasync_task_arn" {
  description = "ARN of the DataSync task"
  value       = aws_datasync_task.gcs_to_s3_transfer.arn
}

output "datasync_task_name" {
  description = "Name of the DataSync task"
  value       = aws_datasync_task.gcs_to_s3_transfer.name
}

output "datasync_gcs_location_arn" {
  description = "ARN of the DataSync GCS location"
  value       = aws_datasync_location_object_storage.gcs_source.arn
}

output "datasync_s3_location_arn" {
  description = "ARN of the DataSync S3 location"
  value       = aws_datasync_location_s3.s3_destination.arn
}
