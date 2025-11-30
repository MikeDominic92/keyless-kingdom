output "subject_claim" {
  description = "The OIDC subject claim that will be used for authentication"
  value       = local.subject_claim
}

output "repository_owner" {
  description = "GitHub repository owner"
  value       = local.repo_owner
}

output "repository_name" {
  description = "GitHub repository name"
  value       = local.repo_name
}

output "credential_type" {
  description = "Type of credential created"
  value       = var.credential_type
}

output "oidc_issuer" {
  description = "OIDC issuer URL"
  value       = var.oidc_issuer
}

output "oidc_audience" {
  description = "OIDC audience"
  value       = var.oidc_audience
}

output "trust_policy_condition" {
  description = "Trust policy condition for cloud provider"
  value = {
    aws = {
      StringEquals = {
        "${replace(var.oidc_issuer, "https://", "")}:aud" = var.oidc_audience
        "${replace(var.oidc_issuer, "https://", "")}:sub" = local.subject_claim
      }
    }
    gcp = {
      attribute_mapping = {
        "google.subject"       = "assertion.sub"
        "attribute.actor"      = "assertion.actor"
        "attribute.repository" = "assertion.repository"
      }
      attribute_condition = "assertion.repository == '${var.github_repository}'"
    }
    azure = {
      issuer    = var.oidc_issuer
      subject   = local.subject_claim
      audiences = ["api://AzureADTokenExchange"]
    }
  }
}

output "example_workflow_snippet" {
  description = "Example GitHub Actions workflow snippet for this credential type"
  value = var.credential_type == "branch" ? <<-EOT
    # Use in workflows that run on the ${var.branch_name} branch
    on:
      push:
        branches:
          - ${var.branch_name}
  EOT : var.credential_type == "pull_request" ? <<-EOT
    # Use in workflows that run on pull requests
    on:
      pull_request:
        types: [opened, synchronize, reopened]
  EOT : var.credential_type == "environment" ? <<-EOT
    # Use in workflows that deploy to the ${var.environment_name} environment
    jobs:
      deploy:
        environment: ${var.environment_name}
        steps:
          - name: Deploy
            run: echo "Deploying to ${var.environment_name}"
  EOT : var.credential_type == "tag" ? <<-EOT
    # Use in workflows that run on tags matching ${var.tag_pattern}
    on:
      push:
        tags:
          - '${var.tag_pattern}'
  EOT : "# Custom credential - configure workflow as needed"
}
