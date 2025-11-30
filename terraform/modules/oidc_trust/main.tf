# Reusable OIDC Trust Module
# This module provides a standardized way to create OIDC trust relationships
# Can be used across different cloud providers and scenarios

terraform {
  required_version = ">= 1.5.0"
}

locals {
  # Parse GitHub repository into owner and name
  repo_parts = split("/", var.github_repository)
  repo_owner = local.repo_parts[0]
  repo_name  = local.repo_parts[1]

  # Generate subject claims for different scenarios
  branch_subject      = "repo:${var.github_repository}:ref:refs/heads/${var.branch_name}"
  pull_request_subject = "repo:${var.github_repository}:pull_request"
  environment_subject = "repo:${var.github_repository}:environment:${var.environment_name}"
  tag_subject        = "repo:${var.github_repository}:ref:refs/tags/${var.tag_pattern}"

  # Determine which subject to use based on type
  subject_claim = (
    var.credential_type == "branch" ? local.branch_subject :
    var.credential_type == "pull_request" ? local.pull_request_subject :
    var.credential_type == "environment" ? local.environment_subject :
    var.credential_type == "tag" ? local.tag_subject :
    var.custom_subject != "" ? var.custom_subject :
    "repo:${var.github_repository}:*" # Default: allow any from repo
  )

  # Common tags/labels
  common_tags = merge(
    var.tags,
    {
      GitHubRepo      = var.github_repository
      CredentialType  = var.credential_type
      ManagedBy       = "Terraform"
      Module          = "oidc_trust"
    }
  )
}
