variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "github_repo" {
  description = "GitHub repository in the format 'owner/repo' (e.g., 'MikeDominic92/keyless-kingdom')"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+/[a-zA-Z0-9-_]+$", var.github_repo))
    error_message = "Repository must be in the format 'owner/repo'."
  }
}

variable "github_actions_role_name" {
  description = "Name of the IAM role for GitHub Actions"
  type        = string
  default     = "github-actions-role"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.github_actions_role_name))
    error_message = "Role name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "deployment_bucket_prefix" {
  description = "Prefix for S3 buckets that GitHub Actions can access"
  type        = string
  default     = "keyless-kingdom-deploy"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.deployment_bucket_prefix))
    error_message = "Bucket prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "enable_readonly_access" {
  description = "Whether to attach ReadOnlyAccess managed policy to the role"
  type        = bool
  default     = false
}

variable "create_prod_role" {
  description = "Whether to create a separate production role with restricted permissions"
  type        = bool
  default     = false
}

variable "allowed_branches" {
  description = "List of branch patterns allowed to assume the role (not currently used in trust policy)"
  type        = list(string)
  default     = ["main", "develop"]
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
