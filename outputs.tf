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
