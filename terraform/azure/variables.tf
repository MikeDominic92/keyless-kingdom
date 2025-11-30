variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.subscription_id))
    error_message = "Subscription ID must be a valid GUID."
  }
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.tenant_id))
    error_message = "Tenant ID must be a valid GUID."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"

  validation {
    condition     = contains(["eastus", "eastus2", "westus", "westus2", "centralus", "northcentralus", "southcentralus", "westcentralus", "canadacentral", "canadaeast", "brazilsouth", "northeurope", "westeurope", "uksouth", "ukwest", "francecentral", "germanywestcentral", "norwayeast", "switzerlandnorth", "uaenorth", "southafricanorth", "australiaeast", "australiasoutheast", "centralindia", "southindia", "japaneast", "japanwest", "koreacentral", "koreasouth", "southeastasia", "eastasia"], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group for identity resources"
  type        = string
  default     = "rg-github-actions"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_().]+$", var.resource_group_name))
    error_message = "Resource group name can only contain alphanumeric characters, hyphens, underscores, parentheses, and periods."
  }
}

variable "identity_name" {
  description = "Name of the user-assigned managed identity"
  type        = string
  default     = "id-github-actions"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.identity_name))
    error_message = "Identity name can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "application_name" {
  description = "Name of the Azure AD application"
  type        = string
  default     = "GitHub Actions OIDC"
}

variable "github_repo" {
  description = "GitHub repository in the format 'owner/repo'"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+/[a-zA-Z0-9-_]+$", var.github_repo))
    error_message = "Repository must be in the format 'owner/repo'."
  }
}

variable "github_environments" {
  description = "List of GitHub environment names to create federated credentials for"
  type        = list(string)
  default     = ["production", "staging"]

  validation {
    condition     = alltrue([for env in var.github_environments : can(regex("^[a-zA-Z0-9-_]+$", env))])
    error_message = "Environment names can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "enable_pull_request_access" {
  description = "Create federated credential for pull requests"
  type        = bool
  default     = true
}

variable "enable_develop_branch" {
  description = "Create federated credential for develop branch"
  type        = bool
  default     = false
}

variable "enable_contributor_access" {
  description = "Grant Contributor role to the identity/service principal"
  type        = bool
  default     = false
}

variable "enable_storage_access" {
  description = "Grant Storage Blob Data Contributor role to the identity/service principal"
  type        = bool
  default     = true
}

variable "enable_reader_access" {
  description = "Grant Reader role to the identity/service principal"
  type        = bool
  default     = true
}

variable "enable_acr_access" {
  description = "Grant AcrPush role to the identity/service principal"
  type        = bool
  default     = false
}

variable "enable_app_service_access" {
  description = "Grant App Service roles to the managed identity"
  type        = bool
  default     = false
}

variable "role_assignment_scope" {
  description = "Scope for role assignments (defaults to subscription if empty)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project   = "KeylessKingdom"
    ManagedBy = "Terraform"
  }
}
