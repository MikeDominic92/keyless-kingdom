variable "github_repository" {
  description = "GitHub repository in the format 'owner/repo'"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+/[a-zA-Z0-9-_]+$", var.github_repository))
    error_message = "Repository must be in the format 'owner/repo'."
  }
}

variable "credential_type" {
  description = "Type of credential to create (branch, pull_request, environment, tag, custom)"
  type        = string
  default     = "branch"

  validation {
    condition     = contains(["branch", "pull_request", "environment", "tag", "custom", "any"], var.credential_type)
    error_message = "Credential type must be one of: branch, pull_request, environment, tag, custom, any."
  }
}

variable "branch_name" {
  description = "Branch name for branch-type credentials (e.g., 'main', 'develop')"
  type        = string
  default     = "main"
}

variable "environment_name" {
  description = "GitHub environment name for environment-type credentials"
  type        = string
  default     = "production"
}

variable "tag_pattern" {
  description = "Tag pattern for tag-type credentials (e.g., 'v*')"
  type        = string
  default     = "*"
}

variable "custom_subject" {
  description = "Custom subject claim for custom-type credentials"
  type        = string
  default     = ""
}

variable "oidc_issuer" {
  description = "OIDC issuer URL"
  type        = string
  default     = "https://token.actions.githubusercontent.com"

  validation {
    condition     = can(regex("^https://", var.oidc_issuer))
    error_message = "OIDC issuer must be an HTTPS URL."
  }
}

variable "oidc_audience" {
  description = "OIDC audience (varies by cloud provider)"
  type        = string
  default     = "sts.amazonaws.com"
}

variable "cloud_provider" {
  description = "Cloud provider (aws, gcp, azure)"
  type        = string
  default     = "aws"

  validation {
    condition     = contains(["aws", "gcp", "azure"], var.cloud_provider)
    error_message = "Cloud provider must be aws, gcp, or azure."
  }
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds (AWS only)"
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "Session duration must be between 1 hour (3600s) and 12 hours (43200s)."
  }
}

variable "additional_conditions" {
  description = "Additional conditions to add to the trust policy (cloud provider specific)"
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "description" {
  description = "Description for the OIDC trust relationship"
  type        = string
  default     = ""
}
