output "workload_identity_pool_id" {
  description = "ID of the Workload Identity Pool"
  value       = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
}

output "workload_identity_pool_name" {
  description = "Full name of the Workload Identity Pool"
  value       = google_iam_workload_identity_pool.github_pool.name
}

output "workload_identity_provider_id" {
  description = "ID of the Workload Identity Provider"
  value       = google_iam_workload_identity_pool_provider.github_provider.workload_identity_pool_provider_id
}

output "workload_identity_provider_name" {
  description = "Full name of the Workload Identity Provider - use this in GitHub Actions"
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}

output "service_account_email" {
  description = "Email of the service account - use this in GitHub Actions"
  value       = google_service_account.github_actions.email
}

output "service_account_id" {
  description = "ID of the service account"
  value       = google_service_account.github_actions.account_id
}

output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}

output "project_number" {
  description = "GCP project number"
  value       = data.google_project.project.number
}

output "workflow_configuration" {
  description = "Configuration snippet for GitHub Actions workflow"
  value = {
    workload_identity_provider = google_iam_workload_identity_pool_provider.github_provider.name
    service_account           = google_service_account.github_actions.email
    example_workflow_step = <<-EOT
      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: '${google_iam_workload_identity_pool_provider.github_provider.name}'
          service_account: '${google_service_account.github_actions.email}'
    EOT
  }
}

output "principal_set" {
  description = "Principal set for IAM bindings"
  value       = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
}
