# Security Analysis

## Executive Summary

Keyless Kingdom demonstrates a security-first approach to CI/CD authentication by eliminating long-lived credentials entirely. This document analyzes the security benefits, threat model, and best practices for OIDC-based workload identity federation.

## Security Benefits

### 1. No Stored Credentials

**Traditional Approach:**
- Access keys, service account keys, and client secrets stored in GitHub Secrets
- Credentials valid indefinitely until manually rotated
- Risk of exposure through logs, debugging, or unauthorized access

**Keyless Kingdom:**
- Zero credentials stored anywhere
- Temporary tokens issued on-demand
- Tokens expire automatically (typically within 1 hour)
- No rotation burden

### 2. Fine-Grained Access Control

**Subject Claim Binding:**
```
AWS Example:
"token.actions.githubusercontent.com:sub": "repo:MikeDominic92/keyless-kingdom:ref:refs/heads/main"
```

This ensures:
- Only workflows from the specific repository can authenticate
- Optionally restrict to specific branches or environments
- Tokens cannot be reused by other repositories

### 3. Audit Trail

**Complete Traceability:**
```
AWS CloudTrail:
{
  "eventName": "AssumeRoleWithWebIdentity",
  "userIdentity": {
    "type": "WebIdentityUser",
    "principalId": "arn:aws:sts::ACCOUNT:assumed-role/github-actions-role/GitHubActions-12345",
    "userName": "GitHub Actions",
    "identityProvider": "token.actions.githubusercontent.com"
  },
  "requestParameters": {
    "roleArn": "arn:aws:iam::ACCOUNT:role/github-actions-role",
    "roleSessionName": "GitHubActions-12345"
  }
}
```

You can see:
- Which workflow assumed the role (session name = run ID)
- When it occurred
- What actions were performed
- Source IP address

### 4. Principle of Least Privilege

Each cloud provider configuration demonstrates minimal permissions:

**AWS:**
```hcl
# Only specific S3 buckets
resources = [
  "arn:aws:s3:::${var.deployment_bucket_prefix}-*",
  "arn:aws:s3:::${var.deployment_bucket_prefix}-*/*",
]
```

**GCP:**
```hcl
# Conditional access to storage
condition {
  title      = "GCS access for deployment buckets"
  expression = "resource.name.startsWith('projects/_/buckets/${var.deployment_bucket_prefix}')"
}
```

**Azure:**
```hcl
# Scoped to specific resource group
scope = azurerm_resource_group.github_actions.id
```

## Threat Model

### Threats Mitigated

| Threat | Traditional Risk | Keyless Risk | Mitigation |
|--------|-----------------|--------------|------------|
| Credential theft from GitHub Secrets | High | None | No credentials stored |
| Credential exposure in logs | High | None | Tokens expire in minutes |
| Unauthorized access from stolen creds | High | Very Low | Tokens bound to repository |
| Credential rotation failure | Medium | None | No rotation needed |
| Lateral movement after compromise | High | Low | Narrow subject claim |
| Insider threat | Medium | Low | Audit logs track all access |

### Remaining Threats

#### 1. Compromised GitHub Account

**Scenario**: Attacker gains access to a GitHub account with write access to the repository.

**Risk**: High - Attacker could push malicious code to trigger workflows.

**Mitigations:**
- Enable multi-factor authentication (MFA) for all contributors
- Use branch protection rules requiring reviews
- Implement CODEOWNERS for sensitive files
- Enable GitHub Advanced Security for vulnerability scanning

#### 2. Malicious Pull Request

**Scenario**: External contributor submits PR with malicious workflow changes.

**Risk**: Medium - If PR workflows have write access.

**Mitigations:**
- Restrict PR workflows to read-only access
- Use separate federated credentials for PRs with limited permissions
- Require approval for first-time contributors
- Review workflow changes in PRs

```yaml
# Safe PR workflow configuration
on:
  pull_request:
    types: [opened, synchronize]

permissions:
  id-token: write  # For authentication only
  contents: read   # Read-only access
```

#### 3. Workflow Injection

**Scenario**: Attacker manipulates workflow environment variables or inputs.

**Risk**: Low-Medium - Depends on how variables are used.

**Mitigations:**
- Validate all inputs
- Use static values for critical parameters
- Avoid using user-controlled data in sensitive operations

```yaml
# Unsafe
- run: aws s3 cp file s3://${{ github.event.inputs.bucket }}

# Safe
- run: aws s3 cp file s3://approved-bucket-name
```

#### 4. GitHub OIDC Provider Compromise

**Scenario**: GitHub's OIDC provider is compromised.

**Risk**: Critical - But extremely unlikely.

**Mitigations:**
- GitHub implements industry-standard security controls
- OIDC tokens are signed with rotation keys
- Cloud providers validate signatures
- Monitor for unusual authentication patterns

#### 5. Token Replay Attack

**Scenario**: Attacker intercepts and reuses an OIDC token.

**Risk**: Very Low - Tokens are short-lived and single-use.

**Mitigations:**
- Tokens expire within 10-15 minutes
- Cloud providers track token usage
- TLS encryption prevents interception
- Nonce validation prevents replay

## Security Best Practices

### 1. Subject Claim Configuration

**Least Secure (Development Only):**
```hcl
# Allows any workflow from any repository in the org
"assertion.repository_owner == 'MikeDominic92'"
```

**Medium Security (Testing):**
```hcl
# Allows any branch in specific repo
"repo:MikeDominic92/keyless-kingdom:*"
```

**High Security (Production):**
```hcl
# Main branch only
"repo:MikeDominic92/keyless-kingdom:ref:refs/heads/main"
```

**Highest Security (Production with Gating):**
```hcl
# Production environment (requires approval)
"repo:MikeDominic92/keyless-kingdom:environment:production"
```

### 2. Branch Protection Rules

Configure on GitHub:
```
Settings → Branches → Branch protection rules
```

Recommended settings:
- Require pull request reviews before merging
- Require status checks to pass
- Require signed commits
- Include administrators
- Restrict who can push to matching branches

### 3. Environment Protection Rules

For production environments:
```
Settings → Environments → production → Protection rules
```

Configure:
- Required reviewers (at least 2)
- Wait timer (e.g., 5 minutes for sanity check)
- Deployment branches (main only)

### 4. Minimal Permissions

**Start with nothing, add as needed:**

```hcl
# Bad: Overly broad permissions
role_definition_name = "Owner"

# Good: Specific permissions
actions = [
  "s3:PutObject",
  "s3:GetObject",
]
resources = ["arn:aws:s3:::specific-bucket/*"]
```

### 5. Audit Logging

**AWS CloudTrail:**
```bash
# Create CloudTrail for OIDC events
aws cloudtrail create-trail \
  --name github-actions-audit \
  --s3-bucket-name audit-logs-bucket
```

**GCP Cloud Audit Logs:**
```bash
# Enable audit logs for IAM
gcloud logging sinks create github-actions-audit \
  bigquery.googleapis.com/projects/PROJECT/datasets/audit_logs \
  --log-filter='protoPayload.serviceName="iam.googleapis.com"'
```

**Azure Activity Log:**
```bash
# Stream to Log Analytics
az monitor diagnostic-settings create \
  --name github-actions-audit \
  --resource /subscriptions/SUBSCRIPTION_ID \
  --workspace LOG_ANALYTICS_WORKSPACE_ID \
  --logs '[{"category": "Administrative", "enabled": true}]'
```

### 6. Monitoring and Alerts

**Set up alerts for:**
- Failed authentication attempts
- Authentication from unexpected repositories
- Unusual access patterns (time of day, frequency)
- Permission denied errors (may indicate misconfiguration or attack)
- New federated credentials created

**Example AWS CloudWatch Alert:**
```json
{
  "source": ["aws.sts"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventName": ["AssumeRoleWithWebIdentity"],
    "errorCode": ["*"]
  }
}
```

## Compliance Considerations

### GDPR
- No PII stored in credentials (none exist)
- Audit logs may contain GitHub usernames - retention policies apply

### SOC 2
- Access control: ✓ Fine-grained RBAC
- Audit logging: ✓ Complete trail
- Encryption: ✓ TLS in transit
- Credential management: ✓ Temporary tokens only

### PCI DSS
- Requirement 8: ✓ Unique IDs for access
- Requirement 10: ✓ Audit trails
- Requirement 3: ✓ No stored credentials

## Incident Response

### Suspected Token Compromise

1. **Identify scope**: Which repository/workflow was compromised?
2. **Revoke access**: Update subject claim to block specific branches
3. **Audit logs**: Review CloudTrail/Audit Logs for unauthorized actions
4. **Rotate trust**: Re-deploy Terraform with new conditions
5. **Investigate**: How was the repository compromised?

### Unauthorized Access Detected

```bash
# AWS: List all AssumeRoleWithWebIdentity calls in last 24 hours
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRoleWithWebIdentity \
  --start-time $(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%S) \
  --output table
```

### Break-Glass Procedure

If OIDC is unavailable:

1. Create temporary IAM user/service account
2. Generate temporary credentials
3. Store in GitHub Secrets (TEMPORARILY)
4. Perform emergency deployment
5. Delete temporary credentials
6. Rotate any exposed secrets
7. Remove from GitHub Secrets
8. Document incident

## Security Checklist

- [ ] MFA enabled for all GitHub accounts with repo access
- [ ] Branch protection rules configured
- [ ] Environment protection rules for production
- [ ] Subject claims restricted to specific repos/branches
- [ ] Minimal IAM permissions granted
- [ ] Audit logging enabled on all cloud providers
- [ ] Alerts configured for failed authentications
- [ ] Regular review of federated credentials
- [ ] Incident response plan documented
- [ ] Security training for team members

## Comparison: Traditional vs Keyless

| Security Aspect | Traditional (Long-Lived Creds) | Keyless Kingdom (OIDC) |
|----------------|-------------------------------|----------------------|
| Credential Storage | GitHub Secrets | None |
| Credential Lifetime | Indefinite | 10-15 minutes |
| Rotation Required | Yes (manual) | No (automatic) |
| Theft Impact | High - credentials valid until rotated | Low - tokens expire quickly |
| Blast Radius | All workflows share same credentials | Each workflow gets unique token |
| Audit Granularity | User/service account level | Workflow run level |
| Revocation | Manual deletion | Automatic expiration |

## Conclusion

Keyless Kingdom eliminates the most common security vulnerabilities in CI/CD pipelines:

1. **No credentials to steal** - The credentials don't exist
2. **No credentials to leak** - Tokens are ephemeral
3. **No credentials to rotate** - Automation handles it
4. **Complete audit trail** - Every action is traceable
5. **Least privilege by default** - Permissions are narrow and specific

This architecture represents the current best practice for secure CI/CD authentication and should be adopted for all new projects and migrated to from legacy credential-based approaches.
