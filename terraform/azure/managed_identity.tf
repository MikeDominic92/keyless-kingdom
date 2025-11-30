# Azure Managed Identity for GitHub Actions
# This identity will be used by GitHub Actions via federated credentials

# Resource group for identity resources
resource "azurerm_resource_group" "github_actions" {
  name     = var.resource_group_name
  location = var.location

  tags = merge(
    var.tags,
    {
      Purpose    = "GitHub Actions Workload Identity"
      ManagedBy  = "Terraform"
    }
  )
}

# User-assigned managed identity
resource "azurerm_user_assigned_identity" "github_actions" {
  name                = var.identity_name
  resource_group_name = azurerm_resource_group.github_actions.name
  location            = azurerm_resource_group.github_actions.location

  tags = merge(
    var.tags,
    {
      Description = "Managed identity for GitHub Actions workflows"
    }
  )
}

# Role assignments for the managed identity
# Following the principle of least privilege

# Contributor role on the resource group (for deployments)
resource "azurerm_role_assignment" "contributor" {
  count                = var.enable_contributor_access ? 1 : 0
  scope                = azurerm_resource_group.github_actions.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.github_actions.principal_id
}

# Storage Blob Data Contributor (for blob storage access)
resource "azurerm_role_assignment" "storage_blob_contributor" {
  count                = var.enable_storage_access ? 1 : 0
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.github_actions.principal_id
}

# Reader role (for read-only access to verify deployments)
resource "azurerm_role_assignment" "reader" {
  count                = var.enable_reader_access ? 1 : 0
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.github_actions.principal_id
}

# AcrPush role (for pushing container images to Azure Container Registry)
resource "azurerm_role_assignment" "acr_push" {
  count                = var.enable_acr_access ? 1 : 0
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.github_actions.principal_id
}

# Web Plan Contributor (for App Service deployments)
resource "azurerm_role_assignment" "web_plan_contributor" {
  count                = var.enable_app_service_access ? 1 : 0
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Web Plan Contributor"
  principal_id         = azurerm_user_assigned_identity.github_actions.principal_id
}

# Website Contributor (for App Service deployments)
resource "azurerm_role_assignment" "website_contributor" {
  count                = var.enable_app_service_access ? 1 : 0
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Website Contributor"
  principal_id         = azurerm_user_assigned_identity.github_actions.principal_id
}
