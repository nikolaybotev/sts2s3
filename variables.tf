variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "sts2s3"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# AWS Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
  default     = ""
}

# GCP Variables
variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
  default     = "your-gcp-project-id"
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-east4"
}

variable "gcp_credentials_file" {
  description = "Path to GCP service account key file"
  type        = string
  default     = ""
}

# STS Transfer Variables
variable "overwrite_existing_objects" {
  description = "Whether to overwrite objects that already exist in the destination"
  type        = bool
  default     = false
}

variable "delete_objects_from_source" {
  description = "Whether to delete objects from source after transfer"
  type        = bool
  default     = false
}
