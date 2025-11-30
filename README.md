# Keyless Kingdom

[![CI Status](https://github.com/MikeDominic92/keyless-kingdom/actions/workflows/ci.yml/badge.svg)](https://github.com/MikeDominic92/keyless-kingdom/actions/workflows/ci.yml)
[![Terraform Version](https://img.shields.io/badge/terraform-%3E%3D1.5.0-623CE4)](https://www.terraform.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Multi-Cloud](https://img.shields.io/badge/multi--cloud-AWS%20%7C%20GCP%20%7C%20Azure-blue)](https://github.com/MikeDominic92/keyless-kingdom)

> **Passwordless Cloud Authentication**: Demonstrating production-ready workload identity federation across AWS, GCP, and Azure using OpenID Connect (OIDC).

## Why Keyless Matters

Traditional CI/CD pipelines rely on **long-lived credentials** (access keys, service account keys, client secrets) that:
- Create security risks if exposed or leaked
- Require rotation and secret management overhead
- Violate the principle of least privilege
- Leave audit trails that are hard to correlate with specific workflows

**Workload Identity Federation** eliminates these risks by using short-lived tokens issued by trusted identity providers (like GitHub Actions) to authenticate directly to cloud providers - **no secrets required**.

## Security Benefits

| Traditional Approach | Keyless Kingdom |
|---------------------|----------------|
| Long-lived credentials stored in GitHub Secrets | No stored credentials - tokens issued on-demand |
| Credentials valid indefinitely until rotated | Tokens valid for minutes, not months |
| Broad permissions to accommodate multiple use cases | Fine-grained permissions per workflow |
| Manual rotation required | Automatic token refresh |
| Credentials can be exfiltrated from CI/CD | Tokens bound to specific GitHub repo/branch/environment |

## Architecture

```
┌─────────────────────┐
│   GitHub Actions    │
│                     │
│  Workflow requests  │
│  OIDC token from    │
│  GitHub's IdP       │
└──────────┬──────────┘
           │
           │ JWT Token (includes repo, branch, actor)
           │
           ▼
┌──────────────────────────────────────────────────┐
│           Cloud Provider Trust             │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │   AWS    │  │   GCP    │  │  Azure   │      │
│  │  OIDC    │  │ Workload │  │ Federated│      │
│  │ Provider │  │ Identity │  │   Creds  │      │
│  └─────┬────┘  └─────┬────┘  └─────┬────┘      │
│        │             │              │           │
│        │ Validates token claims     │           │
│        │ (audience, subject, etc.)  │           │
│        │             │              │           │
│        ▼             ▼              ▼           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │ IAM Role │  │ Service  │  │ Managed  │      │
│  │          │  │ Account  │  │ Identity │      │
│  └──────────┘  └──────────┘  └──────────┘      │
└──────────────────────────────────────────────────┘
           │
           │ Temporary credentials issued
           │
           ▼
┌─────────────────────┐
│   Cloud Resources   │
│   (S3, GCS, Blob)   │
└─────────────────────┘
```

## Quick Start

### Prerequisites

- Terraform >= 1.5.0
- AWS CLI (for AWS setup)
- gcloud CLI (for GCP setup)
- Azure CLI (for Azure setup)
- GitHub repository with Actions enabled

### AWS Setup

```bash
# Configure AWS provider
cd terraform/aws
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your GitHub org/repo

# Deploy OIDC provider and IAM role
terraform init
terraform plan
terraform apply

# Get role ARN for GitHub Actions
terraform output github_actions_role_arn
```

Add the role ARN to your workflow:
```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::ACCOUNT_ID:role/github-actions-role
    aws-region: us-east-1
```

See [AWS Setup Guide](docs/AWS_SETUP.md) for detailed instructions.

### GCP Setup

```bash
# Configure GCP provider
cd terraform/gcp
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your project and GitHub repo

# Deploy Workload Identity Pool and Provider
terraform init
terraform plan
terraform apply

# Get workload identity provider for GitHub Actions
terraform output workload_identity_provider
```

Add to your workflow:
```yaml
- name: Authenticate to Google Cloud
  uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: 'projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider'
    service_account: 'github-actions@PROJECT_ID.iam.gserviceaccount.com'
```

See [GCP Setup Guide](docs/GCP_SETUP.md) for detailed instructions.

### Azure Setup

```bash
# Configure Azure provider
cd terraform/azure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your subscription and GitHub repo

# Deploy Federated Identity Credential
terraform init
terraform plan
terraform apply

# Get client ID and tenant ID for GitHub Actions
terraform output client_id
terraform output tenant_id
```

Add to your workflow:
```yaml
- name: Azure Login
  uses: azure/login@v1
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

See [Azure Setup Guide](docs/AZURE_SETUP.md) for detailed instructions.

## Multi-Cloud Deployment

See the [multi-cloud workflow](.github/workflows/multi-cloud.yml) for a complete example of deploying to all three cloud providers in a single pipeline without storing any credentials.

## Project Structure

```
keyless-kingdom/
├── terraform/           # Infrastructure as Code
│   ├── aws/            # AWS OIDC provider and IAM roles
│   ├── gcp/            # GCP Workload Identity configuration
│   ├── azure/          # Azure Federated Identity credentials
│   └── modules/        # Reusable Terraform modules
├── .github/workflows/  # GitHub Actions CI/CD pipelines
├── docs/               # Comprehensive documentation
│   ├── decisions/      # Architecture Decision Records
│   └── *.md           # Setup guides and architecture docs
├── examples/           # Example deployments using federation
└── tests/             # Validation scripts
```

## Key Features

- **Zero Secrets**: No long-lived credentials stored anywhere
- **Fine-Grained Access**: Each workflow can have different permissions
- **Audit Trail**: Cloud provider logs show exactly which GitHub workflow accessed what
- **Multi-Cloud**: Works across AWS, GCP, and Azure
- **Production Ready**: Complete Terraform configurations with proper error handling
- **Well Documented**: Architecture decisions, setup guides, and security analysis

## Common Troubleshooting

### AWS: "Not authorized to perform sts:AssumeRoleWithWebIdentity"

**Cause**: Trust policy on IAM role doesn't match the OIDC token claims.

**Solution**: Verify the `sub` claim in your trust policy matches your repository:
```json
"StringEquals": {
  "token.actions.githubusercontent.com:sub": "repo:MikeDominic92/keyless-kingdom:ref:refs/heads/main"
}
```

### GCP: "Permission 'iam.serviceAccounts.getAccessToken' denied"

**Cause**: Workload Identity Pool not properly bound to service account.

**Solution**: Ensure the service account IAM binding exists:
```bash
gcloud iam service-accounts add-iam-policy-binding \
  github-actions@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/MikeDominic92/keyless-kingdom"
```

### Azure: "AADSTS70021: No matching federated identity record found"

**Cause**: Federated credential subject doesn't match workflow.

**Solution**: Check the subject matches your branch or environment:
```
repo:MikeDominic92/keyless-kingdom:ref:refs/heads/main
```

### Token Expiration During Long Workflows

**Cause**: OIDC tokens expire after 1 hour by default.

**Solution**: Re-authenticate within the workflow or break into smaller jobs:
```yaml
- name: Refresh credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ env.AWS_ROLE }}
```

## Deployment Verification

This project is fully functional and production-ready with working OIDC federation across all three major cloud providers. Comprehensive deployment evidence is available in [docs/DEPLOYMENT_EVIDENCE.md](docs/DEPLOYMENT_EVIDENCE.md).

### Quick Verification Commands

**AWS:**
```bash
# Verify OIDC provider exists
aws iam list-open-id-connect-providers | grep github

# Get IAM role details
aws iam get-role --role-name github-actions-role
```

**GCP:**
```bash
# Verify workload identity pool
gcloud iam workload-identity-pools list --location=global

# Check service account binding
gcloud iam service-accounts get-iam-policy github-actions@PROJECT_ID.iam.gserviceaccount.com
```

**Azure:**
```bash
# Verify federated credential
az ad app federated-credential list --id CLIENT_ID
```

### Sample Evidence Included

The deployment evidence documentation provides:
- Complete Terraform deployment outputs for all three clouds
- GitHub Actions OIDC token JWT claims (decoded)
- Successful authentication logs from CloudTrail, GCP Logs, and Azure Monitor
- End-to-end multi-cloud workflow execution logs
- No long-lived credentials stored anywhere - pure OIDC federation

See [Deployment Evidence](docs/DEPLOYMENT_EVIDENCE.md) for complete verification steps and outputs.

## Documentation

- [Deployment Evidence](docs/DEPLOYMENT_EVIDENCE.md) - Proof of functionality
- [Architecture Overview](docs/ARCHITECTURE.md)
- [AWS Setup Guide](docs/AWS_SETUP.md)
- [GCP Setup Guide](docs/GCP_SETUP.md)
- [Azure Setup Guide](docs/AZURE_SETUP.md)
- [Security Analysis](docs/SECURITY.md)
- [Cost Analysis](docs/COST_ANALYSIS.md)
- [ADR-001: Why OIDC Federation](docs/decisions/ADR-001-oidc-federation.md)

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Resources

- [GitHub Actions OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [AWS IAM OIDC Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [GCP Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [Azure Workload Identity Federation](https://learn.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation)

## Author

**Mike Dominic**
- GitHub: [@MikeDominic92](https://github.com/MikeDominic92)
- Portfolio: [IAM Portfolio Projects](https://github.com/MikeDominic92?tab=repositories)

---

Built with security in mind. No keys, no secrets, no compromises.
