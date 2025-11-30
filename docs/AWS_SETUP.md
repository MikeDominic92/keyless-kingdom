# AWS Setup Guide

This guide walks you through setting up GitHub Actions OIDC authentication for AWS.

## Prerequisites

- AWS account with admin access
- AWS CLI configured
- Terraform >= 1.5.0 installed
- GitHub repository

## Step 1: Configure Terraform Variables

```bash
cd terraform/aws
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
aws_region = "us-east-1"
environment = "dev"

# Your GitHub repository
github_repo = "MikeDominic92/keyless-kingdom"

# IAM role name
github_actions_role_name = "github-actions-role"

# S3 bucket prefix for deployments
deployment_bucket_prefix = "keyless-kingdom-deploy"

# Enable read-only access for testing
enable_readonly_access = true
```

## Step 2: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Apply configuration
terraform apply
```

Expected output:
```
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

github_actions_role_arn = "arn:aws:iam::123456789012:role/github-actions-role"
oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
workflow_configuration = {
  "example_workflow_step" = <<-EOT
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        role-to-assume: arn:aws:iam::123456789012:role/github-actions-role
        aws-region: us-east-1
        role-session-name: GitHubActions-${{ github.run_id }}
  EOT
  "role_to_assume" = "arn:aws:iam::123456789012:role/github-actions-role"
  "aws_region" = "us-east-1"
}
```

## Step 3: Configure GitHub Secrets

Add the following to your GitHub repository secrets:

```
Settings → Secrets and variables → Actions → New repository secret
```

**Secret Name**: `AWS_ACCOUNT_ID`
**Secret Value**: Your 12-digit AWS account ID (e.g., `123456789012`)

**Note**: The account ID is not sensitive, but storing it as a secret makes workflows cleaner.

## Step 4: Update GitHub Workflow

Update `.github/workflows/deploy-aws.yml`:

```yaml
env:
  AWS_REGION: us-east-1
  AWS_ROLE_ARN: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/github-actions-role
```

Or use the role ARN directly:

```yaml
env:
  AWS_REGION: us-east-1
  AWS_ROLE_ARN: arn:aws:iam::123456789012:role/github-actions-role
```

## Step 5: Test Authentication

Create a test workflow or trigger the existing one:

```yaml
name: Test AWS OIDC
on: workflow_dispatch

permissions:
  id-token: write
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/github-actions-role
          aws-region: us-east-1

      - name: Verify identity
        run: aws sts get-caller-identity
```

Expected output:
```json
{
    "UserId": "AROA...:GitHubActions-12345",
    "Account": "123456789012",
    "Arn": "arn:aws:sts::123456789012:assumed-role/github-actions-role/GitHubActions-12345"
}
```

## Step 6: Verify Permissions

```bash
# List S3 buckets
aws s3 ls

# Get caller identity
aws sts get-caller-identity

# Describe IAM role
aws iam get-role --role-name github-actions-role
```

## Architecture Details

### Resources Created

1. **OIDC Provider**
   - URL: `https://token.actions.githubusercontent.com`
   - Audience: `sts.amazonaws.com`
   - Thumbprint: Auto-fetched from GitHub

2. **IAM Role**
   - Name: `github-actions-role` (configurable)
   - Trust Policy: Allows GitHub Actions from your repository
   - Session Duration: 1 hour

3. **IAM Policy**
   - S3 access to deployment buckets
   - CloudFront invalidation
   - ECR access
   - Read-only access (if enabled)

### Trust Policy Explained

```json
{
  "Effect": "Allow",
  "Principal": {
    "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
  },
  "Action": "sts:AssumeRoleWithWebIdentity",
  "Condition": {
    "StringEquals": {
      "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
    },
    "StringLike": {
      "token.actions.githubusercontent.com:sub": "repo:MikeDominic92/keyless-kingdom:*"
    }
  }
}
```

**Condition Breakdown:**
- `aud`: Ensures token is intended for AWS STS
- `sub`: Restricts to your specific repository (wildcard allows all branches)

### Subject Claim Options

Choose based on your security requirements:

| Subject Pattern | Access Level | Use Case |
|----------------|--------------|----------|
| `repo:owner/repo:*` | Any workflow | Development/testing |
| `repo:owner/repo:ref:refs/heads/main` | Main branch only | Production |
| `repo:owner/repo:environment:prod` | Production environment | Gated deployments |
| `repo:owner/repo:pull_request` | PRs only | Preview deployments |

## Customization

### Add Custom Permissions

Edit `terraform/aws/roles.tf` to add more permissions:

```hcl
statement {
  sid    = "LambdaDeployment"
  effect = "Allow"
  actions = [
    "lambda:UpdateFunctionCode",
    "lambda:PublishVersion",
  ]
  resources = ["arn:aws:lambda:*:*:function:my-function"]
}
```

### Create Environment-Specific Roles

```hcl
module "prod_role" {
  source = "./terraform/aws"

  github_actions_role_name = "github-actions-prod"
  environment = "prod"
  # More restrictive subject claim
}
```

## Troubleshooting

### Error: "Not authorized to perform sts:AssumeRoleWithWebIdentity"

**Cause**: Trust policy doesn't match token claims.

**Solution**: Verify subject claim in trust policy matches your repository:
```bash
# Get current configuration
terraform output trust_policy_subjects

# Should match: repo:YOUR_ORG/YOUR_REPO:*
```

### Error: "No OpenIDConnect provider found"

**Cause**: OIDC provider not created or deleted.

**Solution**: Re-run Terraform apply:
```bash
terraform apply
```

### Error: "User: arn:aws:sts::ACCOUNT:assumed-role/github-actions-role/GitHubActions is not authorized to perform: ACTION"

**Cause**: IAM role lacks required permissions.

**Solution**: Add permissions to the role policy in `roles.tf`.

### Token Expires During Long Workflows

**Cause**: Default session duration is 1 hour.

**Solution**: Re-authenticate mid-workflow:
```yaml
- name: Refresh AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ env.AWS_ROLE_ARN }}
    aws-region: ${{ env.AWS_REGION }}
```

## Security Best Practices

1. **Use Restrictive Subject Claims**: Limit to specific branches or environments
2. **Minimal Permissions**: Grant only necessary permissions
3. **Enable CloudTrail**: Monitor all AssumeRoleWithWebIdentity calls
4. **Session Tags**: Use role session names for traceability
5. **Conditional Access**: Add IP or VPC conditions if needed

## Cleanup

To remove all resources:

```bash
cd terraform/aws
terraform destroy
```

**Warning**: This will delete the OIDC provider and IAM role. Workflows will fail until recreated.

## Next Steps

- Set up S3 bucket for deployments
- Configure CloudFront distribution
- Add ECR repository for container images
- Set up production environment with stricter controls

## References

- [AWS IAM OIDC Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [GitHub Actions OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials)
