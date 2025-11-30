# GCP Setup Guide

This guide walks you through setting up GitHub Actions Workload Identity Federation for Google Cloud Platform.

## Prerequisites

- GCP project with Owner or Security Admin role
- gcloud CLI configured
- Terraform >= 1.5.0 installed
- GitHub repository

## Step 1: Enable Required APIs

```bash
# Set your project ID
export PROJECT_ID="your-project-id"
gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable iam.googleapis.com
gcloud services enable iamcredentials.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable sts.googleapis.com
```

## Step 2: Configure Terraform Variables

```bash
cd terraform/gcp
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
project_id = "your-gcp-project-id"
region     = "us-central1"

workload_identity_pool_id     = "github-pool"
workload_identity_provider_id = "github-provider"
service_account_id            = "github-actions"

github_org  = "MikeDominic92"
github_repo = "MikeDominic92/keyless-kingdom"

deployment_bucket_prefix = "keyless-kingdom-deploy"

enable_storage_access = true
enable_viewer_access  = true
```

## Step 3: Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

Expected output:
```
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

workload_identity_provider_name = "projects/123456789/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
service_account_email = "github-actions@your-project-id.iam.gserviceaccount.com"
project_number = "123456789"
```

## Step 4: Configure GitHub Secrets

Add these secrets to your GitHub repository:

| Secret Name | Value | Where to Find |
|-------------|-------|---------------|
| `GCP_PROJECT_ID` | your-project-id | GCP Console → Project Info |
| `GCP_PROJECT_NUMBER` | 123456789 | `terraform output project_number` |
| `WORKLOAD_IDENTITY_PROVIDER` | Full provider name | `terraform output workload_identity_provider_name` |
| `GCP_SERVICE_ACCOUNT` | Service account email | `terraform output service_account_email` |

## Step 5: Update GitHub Workflow

```yaml
env:
  WORKLOAD_IDENTITY_PROVIDER: ${{ secrets.WORKLOAD_IDENTITY_PROVIDER }}
  SERVICE_ACCOUNT: ${{ secrets.GCP_SERVICE_ACCOUNT }}

jobs:
  deploy:
    steps:
      - uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: ${{ env.WORKLOAD_IDENTITY_PROVIDER }}
          service_account: ${{ env.SERVICE_ACCOUNT }}
```

## Step 6: Test Authentication

```yaml
name: Test GCP Workload Identity
on: workflow_dispatch

permissions:
  id-token: write
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: ${{ secrets.WORKLOAD_IDENTITY_PROVIDER }}
          service_account: ${{ secrets.GCP_SERVICE_ACCOUNT }}

      - uses: google-github-actions/setup-gcloud@v2

      - name: Verify identity
        run: |
          gcloud auth list
          gcloud config list
```

## Architecture Details

### Resources Created

1. **Workload Identity Pool**
   - Pool ID: `github-pool`
   - Location: Global
   - State: Active

2. **Workload Identity Provider**
   - Provider ID: `github-provider`
   - Issuer: `https://token.actions.githubusercontent.com`
   - Attribute Mapping: Maps GitHub claims to GCP attributes

3. **Service Account**
   - Email: `github-actions@PROJECT_ID.iam.gserviceaccount.com`
   - IAM Binding: Allows impersonation by Workload Identity Pool

### Attribute Mapping

```hcl
attribute_mapping = {
  "google.subject"       = "assertion.sub"
  "attribute.actor"      = "assertion.actor"
  "attribute.repository" = "assertion.repository"
  "attribute.ref"        = "assertion.ref"
}
```

This maps GitHub OIDC token claims to GCP-accessible attributes.

### Attribute Condition

```hcl
attribute_condition = "assertion.repository_owner == 'MikeDominic92'"
```

Restricts access to repositories from a specific owner.

## Customization

### Add Custom Permissions

Edit `terraform/gcp/service_accounts.tf`:

```hcl
resource "google_project_iam_member" "cloud_run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}
```

### Restrict to Specific Repository

Change attribute condition in `workload_identity.tf`:

```hcl
attribute_condition = "assertion.repository == '${var.github_repo}' && assertion.ref == 'refs/heads/main'"
```

## Troubleshooting

### Error: "Permission 'iam.serviceAccounts.getAccessToken' denied"

**Cause**: Workload Identity User binding missing or incorrect.

**Solution**:
```bash
gcloud iam service-accounts add-iam-policy-binding \
  github-actions@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/OWNER/REPO"
```

### Error: "The size of mapped attribute exceeds the limit"

**Cause**: Attribute mapping produces values too large.

**Solution**: Use more specific attribute conditions to reduce mapped data.

### Error: "Workload Identity Pool does not exist"

**Cause**: Pool not created or in wrong project.

**Solution**: Verify project ID and re-run `terraform apply`.

## Security Best Practices

1. **Restrict Attribute Condition**: Use specific repository patterns
2. **Minimal Service Account Permissions**: Grant only necessary roles
3. **Enable Audit Logging**: Monitor service account impersonation
4. **Use Conditions in IAM Bindings**: Restrict access to specific resources
5. **Separate Environments**: Use different pools for dev/staging/prod

## Cleanup

```bash
cd terraform/gcp
terraform destroy
```

## Next Steps

- Create GCS bucket for deployments
- Set up Cloud Run service
- Configure Artifact Registry
- Add Cloud Build integration

## References

- [GCP Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [GitHub Actions Auth Action](https://github.com/google-github-actions/auth)
- [Configuring Workload Identity Federation](https://cloud.google.com/iam/docs/configuring-workload-identity-federation)
