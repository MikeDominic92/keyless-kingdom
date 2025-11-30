# Azure Setup Guide

This guide walks you through setting up GitHub Actions Federated Identity Credentials for Azure.

## Prerequisites

- Azure subscription with Owner or User Access Administrator role
- Azure CLI configured (`az login`)
- Terraform >= 1.5.0 installed
- GitHub repository

## Step 1: Get Azure Information

```bash
# Login to Azure
az login

# List subscriptions
az account list --output table

# Set active subscription
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Get tenant ID
az account show --query tenantId --output tsv

# Get subscription ID
az account show --query id --output tsv
```

## Step 2: Configure Terraform Variables

```bash
cd terraform/azure
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
subscription_id = "00000000-0000-0000-0000-000000000000"
tenant_id       = "00000000-0000-0000-0000-000000000000"

location            = "eastus"
resource_group_name = "rg-github-actions"
identity_name       = "id-github-actions"
application_name    = "GitHub Actions OIDC"

github_repo = "MikeDominic92/keyless-kingdom"

github_environments = ["production", "staging"]

enable_pull_request_access = true
enable_storage_access      = true
enable_reader_access       = true
```

## Step 3: Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

Expected output:
```
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

application_id = "12345678-1234-1234-1234-123456789012"
tenant_id = "87654321-4321-4321-4321-210987654321"
subscription_id = "abcdefgh-abcd-abcd-abcd-abcdefghijkl"
```

## Step 4: Configure GitHub Secrets

Add these secrets to your GitHub repository:

| Secret Name | Value | Where to Find |
|-------------|-------|---------------|
| `AZURE_CLIENT_ID` | Application (client) ID | `terraform output application_id` |
| `AZURE_TENANT_ID` | Directory (tenant) ID | `terraform output tenant_id` |
| `AZURE_SUBSCRIPTION_ID` | Subscription ID | `terraform output subscription_id` |

**Note**: These values are not sensitive (they're IDs, not secrets), but storing them as secrets keeps workflows clean.

## Step 5: Update GitHub Workflow

```yaml
env:
  AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
  AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
  AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

jobs:
  deploy:
    steps:
      - uses: azure/login@v1
        with:
          client-id: ${{ env.AZURE_CLIENT_ID }}
          tenant-id: ${{ env.AZURE_TENANT_ID }}
          subscription-id: ${{ env.AZURE_SUBSCRIPTION_ID }}
```

## Step 6: Test Authentication

```yaml
name: Test Azure OIDC
on: workflow_dispatch

permissions:
  id-token: write
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Verify identity
        run: |
          az account show
          az group list --output table
```

## Architecture Details

### Resources Created

1. **Azure AD Application**
   - Display Name: `GitHub Actions OIDC`
   - Application ID: Used as client-id in workflows

2. **Service Principal**
   - Associated with the application
   - Assigned permissions in Azure

3. **Federated Identity Credentials**
   - Main branch: `repo:OWNER/REPO:ref:refs/heads/main`
   - Pull requests: `repo:OWNER/REPO:pull_request`
   - Environments: `repo:OWNER/REPO:environment:ENV_NAME`

4. **User-Assigned Managed Identity** (Optional)
   - Resource group-scoped identity
   - Alternative to service principal

### Federated Credential Configuration

```hcl
issuer   = "https://token.actions.githubusercontent.com"
subject  = "repo:OWNER/REPO:ref:refs/heads/main"
audience = ["api://AzureADTokenExchange"]
```

## Customization

### Add Environment-Specific Credentials

Edit `terraform/azure/federated_credentials.tf`:

```hcl
resource "azuread_application_federated_identity_credential" "staging" {
  application_id = azuread_application.github_actions.id
  display_name   = "GitHub-staging"
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:OWNER/REPO:environment:staging"
  audiences      = ["api://AzureADTokenExchange"]
}
```

### Add Custom Role Assignments

```hcl
resource "azurerm_role_assignment" "custom" {
  scope                = azurerm_resource_group.github_actions.id
  role_definition_name = "Website Contributor"
  principal_id         = azuread_service_principal.github_actions.object_id
}
```

## Subject Claim Patterns

| Subject | Use Case | Security Level |
|---------|----------|----------------|
| `repo:OWNER/REPO:ref:refs/heads/main` | Main branch only | High |
| `repo:OWNER/REPO:pull_request` | All pull requests | Medium |
| `repo:OWNER/REPO:environment:production` | Production environment | Very High (with approvals) |
| `repo:OWNER/REPO:ref:refs/tags/v*` | Release tags | High |

## Troubleshooting

### Error: "AADSTS70021: No matching federated identity record found"

**Cause**: Subject claim in token doesn't match any federated credential.

**Solution**: Verify subject claim matches:
```bash
terraform output federated_credentials
```

Ensure workflow runs on the correct branch or environment.

### Error: "AADSTS700016: Application not found in the directory"

**Cause**: Application deleted or incorrect tenant ID.

**Solution**: Verify tenant ID:
```bash
az account show --query tenantId --output tsv
```

Re-run Terraform if application was deleted.

### Error: "AuthorizationFailed: The client does not have authorization to perform action"

**Cause**: Service principal lacks required permissions.

**Solution**: Add role assignment in Terraform or Azure Portal:
```bash
az role assignment create \
  --assignee YOUR_CLIENT_ID \
  --role "Contributor" \
  --scope "/subscriptions/YOUR_SUBSCRIPTION_ID"
```

### Token Expires During Long Workflows

**Solution**: Re-authenticate mid-workflow:
```yaml
- name: Refresh Azure credentials
  uses: azure/login@v1
  with:
    client-id: ${{ env.AZURE_CLIENT_ID }}
    tenant-id: ${{ env.AZURE_TENANT_ID }}
    subscription-id: ${{ env.AZURE_SUBSCRIPTION_ID }}
```

## Using GitHub Environments

For production deployments with approvals:

1. Create GitHub environment:
```
Settings → Environments → New environment → "production"
```

2. Configure protection rules:
   - Required reviewers
   - Wait timer
   - Deployment branches

3. Use in workflow:
```yaml
jobs:
  deploy-prod:
    environment: production
    steps:
      - uses: azure/login@v1
        # Will use environment-specific federated credential
```

## Security Best Practices

1. **Use Environment Protection**: Require approvals for production
2. **Minimal Scope**: Assign roles to specific resource groups, not subscription
3. **Audit Logs**: Monitor Azure AD sign-in logs
4. **Conditional Access**: Add IP restrictions if needed
5. **Separate Credentials**: Different credentials for dev/staging/prod

## Cleanup

```bash
cd terraform/azure
terraform destroy
```

This removes:
- Azure AD application
- Service principal
- Federated credentials
- Managed identity
- Resource group

## Next Steps

- Create Azure Storage account for deployments
- Set up Azure Container Registry
- Configure App Service or Azure Functions
- Add Azure Key Vault integration

## References

- [Azure Workload Identity Federation](https://learn.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation)
- [GitHub Actions Azure Login](https://github.com/Azure/login)
- [Configure Federated Credentials](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure)
