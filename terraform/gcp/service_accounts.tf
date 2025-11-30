# Service Account for GitHub Actions
# This service account will be impersonated by GitHub Actions via Workload Identity

resource "google_service_account" "github_actions" {
  account_id   = var.service_account_id
  display_name = "GitHub Actions Service Account"
  description  = "Service account for GitHub Actions workflows via Workload Identity Federation"
  project      = var.project_id
}

# Grant the Workload Identity Pool permission to impersonate this service account
# This binds the external identity (GitHub) to the GCP service account
resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
}

# Optional: Bind to all repositories in the organization
# Uncomment this and comment out the above binding for org-wide access
# resource "google_service_account_iam_member" "workload_identity_user_org" {
#   service_account_id = google_service_account.github_actions.name
#   role               = "roles/iam.workloadIdentityUser"
#   member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository_owner/${var.github_org}"
# }

# Grant service account permissions to GCP resources
# Following the principle of least privilege

# Storage permissions - for GCS bucket access
resource "google_project_iam_member" "storage_admin" {
  count   = var.enable_storage_access ? 1 : 0
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"

  condition {
    title       = "GCS access for deployment buckets"
    description = "Only allow access to deployment buckets"
    expression  = "resource.name.startsWith('projects/_/buckets/${var.deployment_bucket_prefix}')"
  }
}

# Artifact Registry permissions - for container image push/pull
resource "google_project_iam_member" "artifact_registry_writer" {
  count   = var.enable_artifact_registry_access ? 1 : 0
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Cloud Run permissions - for deploying serverless applications
resource "google_project_iam_member" "cloud_run_developer" {
  count   = var.enable_cloud_run_access ? 1 : 0
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Cloud Build permissions - for building containers
resource "google_project_iam_member" "cloud_build_builder" {
  count   = var.enable_cloud_build_access ? 1 : 0
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Service Account User - required for Cloud Run deployment
resource "google_project_iam_member" "service_account_user" {
  count   = var.enable_cloud_run_access ? 1 : 0
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Viewer role - for read-only access to verify deployments
resource "google_project_iam_member" "viewer" {
  count   = var.enable_viewer_access ? 1 : 0
  project = var.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Custom role for minimal permissions (optional)
# Uncomment to create a custom role with only the exact permissions needed
# resource "google_project_iam_custom_role" "github_actions_minimal" {
#   role_id     = "githubActionsMinimal"
#   title       = "GitHub Actions Minimal"
#   description = "Minimal permissions for GitHub Actions deployments"
#   project     = var.project_id
#   permissions = [
#     "storage.objects.create",
#     "storage.objects.delete",
#     "storage.objects.get",
#     "storage.objects.list",
#   ]
# }
#
# resource "google_project_iam_member" "github_actions_minimal" {
#   project = var.project_id
#   role    = google_project_iam_custom_role.github_actions_minimal.id
#   member  = "serviceAccount:${google_service_account.github_actions.email}"
# }
