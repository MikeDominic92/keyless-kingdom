# GCP Workload Identity Pool and Provider for GitHub Actions
# This enables passwordless authentication from GitHub Actions to GCP

# Create a Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions OIDC authentication"
  project                   = var.project_id
  disabled                  = false
}

# Create a Workload Identity Provider for GitHub
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_provider_id
  display_name                       = "GitHub Provider"
  description                        = "OIDC provider for GitHub Actions"
  project                            = var.project_id
  disabled                           = false

  # Attribute mapping from GitHub OIDC token to GCP attributes
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.ref"        = "assertion.ref"
  }

  # OIDC configuration for GitHub
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  # Attribute condition to restrict which repositories can authenticate
  # This is a critical security control
  attribute_condition = "assertion.repository_owner == '${var.github_org}'"
}

# Optional: More restrictive attribute condition for specific repo and branch
# Uncomment this resource and comment out the one above for production use
# resource "google_iam_workload_identity_pool_provider" "github_provider_strict" {
#   workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
#   workload_identity_pool_provider_id = "${var.workload_identity_provider_id}-strict"
#   display_name                       = "GitHub Provider (Strict)"
#   description                        = "OIDC provider for GitHub Actions with strict repository restrictions"
#   project                            = var.project_id
#   disabled                           = false
#
#   attribute_mapping = {
#     "google.subject"       = "assertion.sub"
#     "attribute.actor"      = "assertion.actor"
#     "attribute.repository" = "assertion.repository"
#     "attribute.ref"        = "assertion.ref"
#   }
#
#   oidc {
#     issuer_uri = "https://token.actions.githubusercontent.com"
#   }
#
#   # Restrict to specific repository and main branch only
#   attribute_condition = "assertion.repository == '${var.github_repo}' && assertion.ref == 'refs/heads/main'"
# }
