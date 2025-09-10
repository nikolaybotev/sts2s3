# GCS Bucket
resource "google_storage_bucket" "source_bucket" {
  name          = "${var.project_name}-${var.environment}-gcs-source"
  location      = var.gcp_region
  force_destroy = true

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = var.environment
    project     = var.project_name
    purpose     = "sts-transfer-source"
  }
}
