output "subscription_id" {
  description = "Azure subscription ID"
  value       = var.subscription_id
}

output "tenant_id" {
  description = "Azure AD tenant ID"
  value       = var.tenant_id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.github_actions.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.github_actions.id
}

output "managed_identity_name" {
  description = "Name of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.github_actions.name
}

output "managed_identity_id" {
  description = "ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.github_actions.id
}

output "managed_identity_client_id" {
  description = "Client ID of the managed identity"
  value       = azurerm_user_assigned_identity.github_actions.client_id
}

output "managed_identity_principal_id" {
  description = "Principal ID of the managed identity"
  value       = azurerm_user_assigned_identity.github_actions.principal_id
}

output "application_id" {
  description = "Application (client) ID - use this in GitHub Actions"
  value       = azuread_application.github_actions.client_id
}

output "application_object_id" {
  description = "Object ID of the Azure AD application"
  value       = azuread_application.github_actions.object_id
}

output "service_principal_id" {
  description = "Object ID of the service principal"
  value       = azuread_service_principal.github_actions.object_id
}

output "service_principal_application_id" {
  description = "Application ID of the service principal"
  value       = azuread_service_principal.github_actions.client_id
}

output "federated_credentials" {
  description = "List of created federated identity credentials"
  value = merge(
    {
      main_branch = {
        name    = azuread_application_federated_identity_credential.main_branch.display_name
        subject = azuread_application_federated_identity_credential.main_branch.subject
      }
    },
    var.enable_pull_request_access ? {
      pull_requests = {
        name    = azuread_application_federated_identity_credential.pull_requests[0].display_name
        subject = azuread_application_federated_identity_credential.pull_requests[0].subject
      }
    } : {},
    var.enable_develop_branch ? {
      develop_branch = {
        name    = azuread_application_federated_identity_credential.develop_branch[0].display_name
        subject = azuread_application_federated_identity_credential.develop_branch[0].subject
      }
    } : {},
    {
      for env in var.github_environments :
      env => {
        name    = azuread_application_federated_identity_credential.environments[env].display_name
        subject = azuread_application_federated_identity_credential.environments[env].subject
      }
    }
  )
}

output "workflow_configuration" {
  description = "Configuration snippet for GitHub Actions workflow"
  value = {
    client_id       = azuread_application.github_actions.client_id
    tenant_id       = var.tenant_id
    subscription_id = var.subscription_id
    example_workflow_step = <<-EOT
      - name: Azure Login
        uses: azure/login@v1
        with:
          client-id: '${azuread_application.github_actions.client_id}'
          tenant-id: '${var.tenant_id}'
          subscription-id: '${var.subscription_id}'
    EOT
  }
}
