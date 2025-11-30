variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "resource_group_name" {
  description = "Resource group name for website resources"
  type        = string
  default     = "rg-keyless-kingdom-website"
}

variable "storage_prefix" {
  description = "Prefix for storage account name (must be globally unique, lowercase, no hyphens)"
  type        = string
  default     = "keylesswebsite"

  validation {
    condition     = can(regex("^[a-z0-9]{3,20}$", var.storage_prefix))
    error_message = "Storage prefix must be 3-20 lowercase alphanumeric characters."
  }
}

variable "github_actions_principal_id" {
  description = "Principal ID of the GitHub Actions service principal (from terraform/azure output)"
  type        = string
  # Example: "12345678-1234-1234-1234-123456789012"
}
