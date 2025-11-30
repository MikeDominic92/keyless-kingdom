# Example: Deploy static website to Azure Blob Storage using GitHub Actions with Federated Identity
# This demonstrates a complete Azure Blob deployment using keyless authentication

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Data source to get current subscription
data "azurerm_subscription" "current" {}

# Resource group for website resources
resource "azurerm_resource_group" "website" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "KeylessKingdom"
  }
}

# Storage account for static website
resource "azurerm_storage_account" "website" {
  name                     = replace("${var.storage_prefix}${var.environment}", "-", "")
  resource_group_name      = azurerm_resource_group.website.name
  location                 = azurerm_resource_group.website.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  static_website {
    index_document     = "index.html"
    error_404_document = "404.html"
  }

  blob_properties {
    versioning_enabled = true

    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD"]
      allowed_origins    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Grant GitHub Actions service principal access to storage
resource "azurerm_role_assignment" "github_actions_blob_contributor" {
  scope                = azurerm_storage_account.website.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.github_actions_principal_id
}

# CDN profile for global distribution
resource "azurerm_cdn_profile" "website" {
  name                = "${var.storage_prefix}-cdn-profile"
  resource_group_name = azurerm_resource_group.website.name
  location            = azurerm_resource_group.website.location
  sku                 = "Standard_Microsoft"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# CDN endpoint
resource "azurerm_cdn_endpoint" "website" {
  name                = "${var.storage_prefix}-cdn-endpoint"
  profile_name        = azurerm_cdn_profile.website.name
  resource_group_name = azurerm_resource_group.website.name
  location            = azurerm_resource_group.website.location

  origin_host_header = azurerm_storage_account.website.primary_web_host

  origin {
    name      = "websiteOrigin"
    host_name = azurerm_storage_account.website.primary_web_host
  }

  delivery_rule {
    name  = "EnforceHTTPS"
    order = 1

    request_scheme_condition {
      match_values = ["HTTP"]
    }

    url_redirect_action {
      redirect_type = "Found"
      protocol      = "Https"
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Optional: Custom domain and HTTPS (requires domain ownership)
# Uncomment if you have a domain

# resource "azurerm_cdn_endpoint_custom_domain" "website" {
#   name            = "website-domain"
#   cdn_endpoint_id = azurerm_cdn_endpoint.website.id
#   host_name       = var.custom_domain
#
#   cdn_managed_https {
#     certificate_type = "Dedicated"
#     protocol_type    = "ServerNameIndication"
#     tls_version      = "TLS12"
#   }
# }

# Outputs for GitHub Actions workflow
output "storage_account_name" {
  description = "Storage account name for deployment"
  value       = azurerm_storage_account.website.name
}

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.website.name
}

output "primary_web_endpoint" {
  description = "Primary web endpoint URL"
  value       = azurerm_storage_account.website.primary_web_endpoint
}

output "cdn_endpoint_url" {
  description = "CDN endpoint URL"
  value       = "https://${azurerm_cdn_endpoint.website.host_name}"
}

output "cdn_endpoint_id" {
  description = "CDN endpoint ID for cache purging"
  value       = azurerm_cdn_endpoint.website.id
}

output "deployment_command" {
  description = "Example deployment command for GitHub Actions"
  value = <<-EOT
    # Upload files to Blob Storage
    az storage blob upload-batch \
      --account-name ${azurerm_storage_account.website.name} \
      --destination '$web' \
      --source ./dist \
      --overwrite

    # Purge CDN cache
    az cdn endpoint purge \
      --resource-group ${azurerm_resource_group.website.name} \
      --profile-name ${azurerm_cdn_profile.website.name} \
      --name ${azurerm_cdn_endpoint.website.name} \
      --content-paths "/*"
  EOT
}
