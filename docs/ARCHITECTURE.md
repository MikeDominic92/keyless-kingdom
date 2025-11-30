# Architecture Overview

## Introduction

Keyless Kingdom demonstrates production-ready workload identity federation using OpenID Connect (OIDC) to eliminate long-lived credentials across AWS, GCP, and Azure. This document provides a comprehensive overview of the architecture, design decisions, and security model.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Actions                            │
│                                                              │
│  ┌────────────┐                                             │
│  │ Workflow   │  1. Workflow starts                         │
│  │ Execution  │─────┐                                       │
│  └────────────┘     │                                       │
│                     ▼                                        │
│              ┌──────────────┐                               │
│              │ GitHub OIDC  │  2. Request JWT token         │
│              │   Provider   │                               │
│              └──────┬───────┘                               │
└─────────────────────┼──────────────────────────────────────┘
                      │
         3. JWT Token │ (includes claims: repo, ref, actor)
                      │
      ┌───────────────┼───────────────┐
      │               │               │
      ▼               ▼               ▼
┌──────────┐    ┌──────────┐    ┌──────────┐
│   AWS    │    │   GCP    │    │  Azure   │
│  OIDC    │    │ Workload │    │ Federated│
│ Provider │    │ Identity │    │   Creds  │
└────┬─────┘    └────┬─────┘    └────┬─────┘
     │               │               │
     │ 4. Validate token claims      │
     │    (issuer, audience, subject)│
     │               │               │
     ▼               ▼               ▼
┌──────────┐    ┌──────────┐    ┌──────────┐
│ IAM Role │    │ Service  │    │ Service  │
│          │    │ Account  │    │ Principal│
└────┬─────┘    └────┬─────┘    └────┬─────┘
     │               │               │
     │ 5. Issue temporary credentials │
     │               │               │
     └───────────────┼───────────────┘
                     │
                     ▼
          ┌──────────────────┐
          │ Cloud Resources  │
          │ (S3, GCS, Blob)  │
          └──────────────────┘
```

## Component Architecture

### 1. Identity Provider (GitHub Actions)

GitHub Actions serves as the trusted OIDC identity provider:

- **Token Issuer**: `https://token.actions.githubusercontent.com`
- **Token Lifetime**: Short-lived (typically 10-15 minutes)
- **Claims**: Repository, branch, actor, workflow, etc.

**Key Claims:**
```json
{
  "iss": "https://token.actions.githubusercontent.com",
  "aud": "sts.amazonaws.com",
  "sub": "repo:MikeDominic92/keyless-kingdom:ref:refs/heads/main",
  "repository": "MikeDominic92/keyless-kingdom",
  "ref": "refs/heads/main",
  "actor": "MikeDominic92"
}
```

### 2. AWS OIDC Federation

**Components:**
- `aws_iam_openid_connect_provider`: Establishes trust with GitHub's OIDC provider
- `aws_iam_role`: Role that can be assumed by GitHub Actions
- Trust Policy: Validates token claims before allowing assumption

**Trust Policy Structure:**
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
        "token.actions.githubusercontent.com:sub": "repo:OWNER/REPO:*"
      }
    }
  }]
}
```

**Authentication Flow:**
1. Workflow requests OIDC token from GitHub
2. Workflow calls `sts:AssumeRoleWithWebIdentity` with token
3. AWS validates token signature and claims
4. AWS issues temporary credentials (valid for 1 hour)
5. Workflow uses temporary credentials to access AWS resources

### 3. GCP Workload Identity Federation

**Components:**
- `google_iam_workload_identity_pool`: Pool of external identities
- `google_iam_workload_identity_pool_provider`: GitHub OIDC provider configuration
- `google_service_account`: GCP identity that external identities can impersonate

**Attribute Mapping:**
```hcl
attribute_mapping = {
  "google.subject"       = "assertion.sub"
  "attribute.actor"      = "assertion.actor"
  "attribute.repository" = "assertion.repository"
}
```

**Authentication Flow:**
1. Workflow requests OIDC token from GitHub
2. Workflow exchanges token for GCP access token via Workload Identity Pool
3. GCP validates token and maps attributes
4. GCP issues short-lived access token
5. Workflow uses access token to impersonate service account

### 4. Azure Federated Identity

**Components:**
- `azuread_application`: Azure AD application
- `azuread_application_federated_identity_credential`: Trust relationship configuration
- `azuread_service_principal`: Service principal for the application

**Federated Credential Configuration:**
```hcl
issuer   = "https://token.actions.githubusercontent.com"
subject  = "repo:OWNER/REPO:ref:refs/heads/main"
audience = ["api://AzureADTokenExchange"]
```

**Authentication Flow:**
1. Workflow requests OIDC token from GitHub
2. Workflow calls Azure AD token endpoint with GitHub token
3. Azure validates token claims against federated credential
4. Azure issues Azure AD access token
5. Workflow uses Azure AD token to access Azure resources

## Security Model

### Defense in Depth

Multiple layers of security controls:

1. **Identity Provider Trust**: Only GitHub's OIDC provider is trusted
2. **Subject Claim Validation**: Tokens must come from specific repository
3. **Audience Validation**: Tokens must be intended for the specific cloud
4. **Time-based Expiration**: Tokens are short-lived (minutes, not months)
5. **Least Privilege Permissions**: Roles/service accounts have minimal permissions
6. **Audit Logging**: All actions logged to cloud provider audit logs

### Subject Claim Patterns

Different levels of restriction:

| Pattern | Restriction Level | Use Case |
|---------|------------------|----------|
| `repo:owner/repo:*` | Low | Any workflow in repo |
| `repo:owner/repo:ref:refs/heads/main` | Medium | Only main branch |
| `repo:owner/repo:environment:production` | High | Production environment with approvals |
| `repo:owner/repo:pull_request` | Medium | Pull request previews |

### Threat Model

**Threats Mitigated:**
- Credential theft from GitHub Secrets
- Credential exposure in logs or code
- Unauthorized access from compromised developer machines
- Credential rotation burden

**Remaining Threats:**
- Compromised GitHub account with repo access
- Malicious code merged to protected branches
- GitHub OIDC provider compromise (extremely unlikely)

**Mitigations:**
- Use branch protection rules
- Require code reviews and approvals
- Use GitHub environment protection rules for production
- Monitor cloud provider audit logs

## Data Flow

### Typical Deployment Flow

```
┌──────────────────────────────────────────────────────────┐
│ 1. Developer pushes code to main branch                  │
└──────────────────────┬───────────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────────┐
│ 2. GitHub Actions workflow triggered                      │
└──────────────────────┬───────────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────────┐
│ 3. Workflow job requests OIDC token                       │
│    - GitHub validates workflow identity                   │
│    - Generates JWT with claims                            │
└──────────────────────┬───────────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────────┐
│ 4. Workflow authenticates to cloud provider               │
│    - Presents JWT token                                   │
│    - Cloud provider validates token                       │
│    - Cloud provider checks subject claim                  │
└──────────────────────┬───────────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────────┐
│ 5. Cloud provider issues temporary credentials            │
│    - AWS: STS credentials (1 hour)                        │
│    - GCP: Access token (1 hour)                           │
│    - Azure: Azure AD token (1 hour)                       │
└──────────────────────┬───────────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────────┐
│ 6. Workflow performs deployment                           │
│    - Upload to S3/GCS/Blob                                │
│    - Deploy to Cloud Run/Lambda/App Service               │
│    - Update infrastructure                                │
└──────────────────────┬───────────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────────┐
│ 7. Workflow completes, credentials expire                 │
│    - No cleanup needed                                    │
│    - No credentials to rotate                             │
└──────────────────────────────────────────────────────────┘
```

## Scalability and Performance

### Performance Characteristics

- **Authentication Overhead**: ~2-5 seconds per cloud provider
- **Token Validity**: 1 hour (sufficient for most workflows)
- **Concurrent Workflows**: No limit (each gets independent token)
- **Rate Limits**: Subject to cloud provider API rate limits

### Scaling Considerations

**Multiple Repositories:**
- Each repo can have its own OIDC trust configuration
- Or use org-level attribute condition for shared access

**Multiple Environments:**
- Create separate federated credentials per environment
- Use GitHub environment protection rules

**Multiple Workflows:**
- All workflows in a repo can use the same OIDC configuration
- Or create specific roles per workflow type

## Monitoring and Observability

### Key Metrics to Monitor

1. **Authentication Success Rate**: Should be >99%
2. **Token Expiration Events**: Should not occur during workflows
3. **Permission Denied Errors**: Indicates misconfigured permissions
4. **Unusual Access Patterns**: Potential security incident

### Audit Logging

**AWS CloudTrail:**
```
Event: AssumeRoleWithWebIdentity
User Identity: arn:aws:sts::ACCOUNT:assumed-role/github-actions-role/GitHubActions-12345
Source: token.actions.githubusercontent.com
```

**GCP Cloud Audit Logs:**
```
Service: iam.googleapis.com
Method: GenerateAccessToken
Principal: github-actions@project.iam.gserviceaccount.com
```

**Azure Activity Log:**
```
Operation: Microsoft.Resources/deployments/write
Identity: GitHub Actions OIDC
Claims: {"sub": "repo:owner/repo:ref:refs/heads/main"}
```

## Disaster Recovery

### Recovery Scenarios

**GitHub OIDC Provider Outage:**
- Impact: Cannot deploy until GitHub recovers
- Mitigation: Manual deployment with emergency credentials (break-glass)

**Cloud Provider IAM Outage:**
- Impact: Cannot assume roles/impersonate service accounts
- Mitigation: Wait for cloud provider recovery

**Accidental Trust Deletion:**
- Impact: Workflows fail to authenticate
- Recovery: Re-apply Terraform configuration
- Time to Recovery: ~5 minutes

### Break-Glass Procedures

For emergency deployments when OIDC is unavailable:

1. Create temporary IAM user/service account
2. Generate temporary credentials
3. Perform manual deployment
4. Delete temporary credentials
5. Rotate any exposed secrets

## Future Enhancements

Potential improvements to the architecture:

1. **Custom OIDC Claims**: Add workflow-specific claims for finer-grained control
2. **Just-In-Time Access**: Request elevated permissions only when needed
3. **Cross-Cloud Deployments**: Single workflow deploys to multiple clouds atomically
4. **Automated Permission Discovery**: Detect minimum required permissions
5. **Integration with Policy-as-Code**: Use OPA/Cedar for dynamic permission policies

## Conclusion

This architecture provides:
- **Zero stored credentials**: All authentication uses short-lived tokens
- **Fine-grained access control**: Permissions scoped to specific repositories/branches
- **Cloud-agnostic approach**: Works consistently across AWS, GCP, and Azure
- **Production-ready**: Includes monitoring, audit logging, and disaster recovery
- **Scalable**: Supports multiple repos, environments, and workflows

The architecture follows cloud security best practices and demonstrates modern IAM patterns suitable for enterprise adoption.
