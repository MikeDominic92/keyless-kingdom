variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "bucket_prefix" {
  description = "Prefix for GCS bucket name"
  type        = string
  default     = "keyless-kingdom-deploy"
}

variable "github_actions_service_account" {
  description = "Email of the GitHub Actions service account (from terraform/gcp output)"
  type        = string
  # Example: "github-actions@project-id.iam.gserviceaccount.com"
}

variable "force_destroy" {
  description = "Allow Terraform to destroy bucket even if it contains objects"
  type        = bool
  default     = false
}
