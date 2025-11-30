# Azure AD Application and Federated Identity Credentials for GitHub Actions
# This enables OIDC authentication from GitHub Actions to Azure

# Azure AD Application
resource "azuread_application" "github_actions" {
  display_name = var.application_name

  tags = [
    "ManagedBy:Terraform",
    "Project:KeylessKingdom",
    "Purpose:GitHubActions"
  ]
}

# Service Principal for the application
resource "azuread_service_principal" "github_actions" {
  client_id                    = azuread_application.github_actions.client_id
  app_role_assignment_required = false

  tags = [
    "ManagedBy:Terraform",
    "Project:KeylessKingdom",
  ]
}

# Federated Identity Credential for main branch
resource "azuread_application_federated_identity_credential" "main_branch" {
  application_id = azuread_application.github_actions.id
  display_name   = "GitHub-${replace(var.github_repo, "/", "-")}-main"
  description    = "Federated credential for ${var.github_repo} main branch"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_repo}:ref:refs/heads/main"
}

# Federated Identity Credential for pull requests
resource "azuread_application_federated_identity_credential" "pull_requests" {
  count          = var.enable_pull_request_access ? 1 : 0
  application_id = azuread_application.github_actions.id
  display_name   = "GitHub-${replace(var.github_repo, "/", "-")}-pr"
  description    = "Federated credential for ${var.github_repo} pull requests"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_repo}:pull_request"
}

# Federated Identity Credential for environment-based deployments
resource "azuread_application_federated_identity_credential" "environments" {
  for_each       = toset(var.github_environments)
  application_id = azuread_application.github_actions.id
  display_name   = "GitHub-${replace(var.github_repo, "/", "-")}-${each.key}"
  description    = "Federated credential for ${var.github_repo} ${each.key} environment"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_repo}:environment:${each.key}"
}

# Federated Identity Credential for develop branch (optional)
resource "azuread_application_federated_identity_credential" "develop_branch" {
  count          = var.enable_develop_branch ? 1 : 0
  application_id = azuread_application.github_actions.id
  display_name   = "GitHub-${replace(var.github_repo, "/", "-")}-develop"
  description    = "Federated credential for ${var.github_repo} develop branch"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_repo}:ref:refs/heads/develop"
}

# Role assignments for the service principal
# These grant the service principal permissions in Azure

# Contributor role on subscription (can be scoped to resource group)
resource "azurerm_role_assignment" "sp_contributor" {
  count                = var.enable_contributor_access ? 1 : 0
  scope                = var.role_assignment_scope != "" ? var.role_assignment_scope : data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_actions.object_id
}

# Storage Blob Data Contributor
resource "azurerm_role_assignment" "sp_storage" {
  count                = var.enable_storage_access ? 1 : 0
  scope                = var.role_assignment_scope != "" ? var.role_assignment_scope : data.azurerm_subscription.current.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.github_actions.object_id
}

# Reader role
resource "azurerm_role_assignment" "sp_reader" {
  count                = var.enable_reader_access ? 1 : 0
  scope                = var.role_assignment_scope != "" ? var.role_assignment_scope : data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.github_actions.object_id
}

# Container Registry Push
resource "azurerm_role_assignment" "sp_acr_push" {
  count                = var.enable_acr_access ? 1 : 0
  scope                = var.role_assignment_scope != "" ? var.role_assignment_scope : data.azurerm_subscription.current.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.github_actions.object_id
}
