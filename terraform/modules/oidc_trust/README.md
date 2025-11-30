# OIDC Trust Module

This reusable Terraform module generates standardized OIDC trust configurations for GitHub Actions across different cloud providers.

## Features

- Supports AWS, GCP, and Azure
- Multiple credential types (branch, pull request, environment, tag)
- Standardized subject claim generation
- Cloud-provider-specific trust policy outputs

## Usage

### Basic Usage (Branch-based)

```hcl
module "oidc_trust_main" {
  source = "./modules/oidc_trust"

  github_repository = "MikeDominic92/keyless-kingdom"
  credential_type   = "branch"
  branch_name       = "main"
  cloud_provider    = "aws"
}
```

### Environment-based Deployment

```hcl
module "oidc_trust_production" {
  source = "./modules/oidc_trust"

  github_repository = "MikeDominic92/keyless-kingdom"
  credential_type   = "environment"
  environment_name  = "production"
  cloud_provider    = "azure"
}
```

### Pull Request Deployments

```hcl
module "oidc_trust_pr" {
  source = "./modules/oidc_trust"

  github_repository = "MikeDominic92/keyless-kingdom"
  credential_type   = "pull_request"
  cloud_provider    = "gcp"
}
```

### Tag-based Releases

```hcl
module "oidc_trust_releases" {
  source = "./modules/oidc_trust"

  github_repository = "MikeDominic92/keyless-kingdom"
  credential_type   = "tag"
  tag_pattern       = "v*"
  cloud_provider    = "aws"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| github_repository | GitHub repository in format 'owner/repo' | string | - | yes |
| credential_type | Type of credential (branch, pull_request, environment, tag, custom) | string | "branch" | no |
| branch_name | Branch name for branch-type credentials | string | "main" | no |
| environment_name | GitHub environment name | string | "production" | no |
| tag_pattern | Tag pattern for tag-type credentials | string | "*" | no |
| cloud_provider | Cloud provider (aws, gcp, azure) | string | "aws" | no |

## Outputs

| Name | Description |
|------|-------------|
| subject_claim | OIDC subject claim for authentication |
| trust_policy_condition | Cloud provider-specific trust policy conditions |
| example_workflow_snippet | Example GitHub Actions workflow configuration |

## Credential Types

### Branch
Restricts access to specific branch(es)
- Subject: `repo:owner/repo:ref:refs/heads/branch-name`
- Use case: Production deployments from main branch

### Pull Request
Allows access from any pull request
- Subject: `repo:owner/repo:pull_request`
- Use case: Preview deployments for PRs

### Environment
Restricts access to specific GitHub environment
- Subject: `repo:owner/repo:environment:env-name`
- Use case: Environment-gated deployments with approval workflows

### Tag
Allows access from tags matching pattern
- Subject: `repo:owner/repo:ref:refs/tags/pattern`
- Use case: Release deployments triggered by version tags

## Security Considerations

- Always use the most restrictive credential type for your use case
- Prefer environment-based credentials for production deployments (includes approval workflows)
- Use branch-based credentials for simple CI/CD pipelines
- Avoid using `any` type in production

## Examples

See the `examples/` directory in the root of this repository for complete working examples.
