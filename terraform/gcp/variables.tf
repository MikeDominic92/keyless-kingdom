variable "project_id" {
  description = "GCP project ID"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be 6-30 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "workload_identity_pool_id" {
  description = "ID for the Workload Identity Pool"
  type        = string
  default     = "github-pool"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{3,31}$", var.workload_identity_pool_id))
    error_message = "Pool ID must be 4-32 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "workload_identity_provider_id" {
  description = "ID for the Workload Identity Provider"
  type        = string
  default     = "github-provider"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{3,31}$", var.workload_identity_provider_id))
    error_message = "Provider ID must be 4-32 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "service_account_id" {
  description = "ID for the service account (will be suffixed with @project-id.iam.gserviceaccount.com)"
  type        = string
  default     = "github-actions"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{5,29}$", var.service_account_id))
    error_message = "Service account ID must be 6-30 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "github_org" {
  description = "GitHub organization or user name"
  type        = string
  default     = "MikeDominic92"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.github_org))
    error_message = "GitHub org must contain only alphanumeric characters and hyphens."
  }
}

variable "github_repo" {
  description = "GitHub repository in the format 'owner/repo'"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+/[a-zA-Z0-9-_]+$", var.github_repo))
    error_message = "Repository must be in the format 'owner/repo'."
  }
}

variable "deployment_bucket_prefix" {
  description = "Prefix for GCS buckets that can be accessed by GitHub Actions"
  type        = string
  default     = "keyless-kingdom-deploy"
}

variable "enable_storage_access" {
  description = "Grant Storage Object Admin role to the service account"
  type        = bool
  default     = true
}

variable "enable_artifact_registry_access" {
  description = "Grant Artifact Registry Writer role to the service account"
  type        = bool
  default     = false
}

variable "enable_cloud_run_access" {
  description = "Grant Cloud Run Developer role to the service account"
  type        = bool
  default     = false
}

variable "enable_cloud_build_access" {
  description = "Grant Cloud Build Builder role to the service account"
  type        = bool
  default     = false
}

variable "enable_viewer_access" {
  description = "Grant Viewer role to the service account for read-only access"
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default = {
    managed_by = "terraform"
    project    = "keyless-kingdom"
  }
}
