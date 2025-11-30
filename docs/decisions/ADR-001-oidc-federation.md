# ADR-001: Use OIDC Federation Instead of Long-Lived Credentials

## Status

**Accepted** - 2025-11-30

## Context

CI/CD pipelines require authentication to cloud providers (AWS, GCP, Azure) to deploy applications and manage infrastructure. Historically, this has been accomplished using long-lived credentials stored as GitHub Secrets:

- AWS: IAM User Access Keys
- GCP: Service Account JSON Keys
- Azure: Service Principal Client Secrets

These credentials present several challenges:

1. **Security Risk**: Credentials are valid indefinitely until manually rotated
2. **Exposure Risk**: Can be leaked through logs, debugging, or unauthorized access
3. **Operational Burden**: Manual rotation every 90 days (security best practice)
4. **Audit Complexity**: Difficult to correlate cloud actions with specific workflows
5. **Blast Radius**: Compromised credentials grant full access until revoked
6. **Compliance Issues**: Storing credentials conflicts with zero-trust principles

## Decision

We will use OpenID Connect (OIDC) workload identity federation for all cloud authentication in CI/CD pipelines, eliminating the need for long-lived credentials entirely.

### Implementation Approach

**AWS:**
- Create IAM OIDC Identity Provider trusting GitHub
- Create IAM Role with trust policy validating GitHub token claims
- Workflows use `aws-actions/configure-aws-credentials` with `role-to-assume`

**GCP:**
- Create Workload Identity Pool and Provider
- Create Service Account with Workload Identity User binding
- Workflows use `google-github-actions/auth` with `workload_identity_provider`

**Azure:**
- Create Azure AD Application with Federated Identity Credentials
- Create Service Principal with necessary role assignments
- Workflows use `azure/login` with `client-id`, `tenant-id`, `subscription-id`

## Consequences

### Positive

1. **Zero Stored Credentials**
   - No secrets to manage, rotate, or protect
   - Eliminates entire class of security vulnerabilities

2. **Short-Lived Tokens**
   - Tokens expire in 10-15 minutes
   - Automatic refresh handled by cloud SDKs
   - Minimal impact if token is intercepted

3. **Fine-Grained Access Control**
   - Subject claims bind tokens to specific repositories/branches
   - Can create different trust relationships per environment
   - Easy to audit which repository accessed which resources

4. **Improved Audit Trail**
   - Cloud provider logs show exact workflow run ID
   - Direct correlation between GitHub Actions and cloud API calls
   - Better compliance posture

5. **Reduced Operational Burden**
   - No manual credential rotation
   - No secret management infrastructure needed
   - Less time spent on credential-related incidents

6. **Cost Savings**
   - No cost for OIDC providers (free on all clouds)
   - Reduced incident response costs
   - Eliminated secret management tooling costs

### Negative

1. **Initial Complexity**
   - Team must understand OIDC concepts
   - More complex initial setup than storing a secret
   - Requires Terraform knowledge

   **Mitigation**: Comprehensive documentation, training, and examples provided

2. **Dependency on GitHub OIDC**
   - If GitHub's OIDC provider has an outage, deployments fail
   - No fallback to traditional authentication

   **Mitigation**: Break-glass procedure for emergency deployments, GitHub SLA is 99.95%

3. **Workflow Changes Required**
   - Existing workflows must be updated
   - Slight learning curve for developers

   **Mitigation**: Gradual migration, maintain backward compatibility during transition

4. **Debugging Complexity**
   - Token validation errors can be opaque
   - Subject claim mismatches are common initial issue

   **Mitigation**: Detailed troubleshooting guide, common error solutions documented

5. **Limited to Supported Providers**
   - Only works with clouds that support OIDC/federation
   - Cannot use for legacy systems or third-party services

   **Mitigation**: Keep traditional credential method available for edge cases

## Alternatives Considered

### Alternative 1: Continue Using Long-Lived Credentials

**Pros:**
- Simple to understand and implement
- Well-documented and widely used
- Works with any service

**Cons:**
- Significant security risk
- Operational burden of rotation
- Poor audit trail
- Violates zero-trust principles

**Decision:** Rejected - Security risks outweigh simplicity

### Alternative 2: HashiCorp Vault Integration

**Pros:**
- Centralized secret management
- Dynamic credentials with TTL
- Good audit logging

**Cons:**
- Additional infrastructure to maintain
- Cost ($100-1000/month for hosted)
- Complexity of Vault operations
- Still requires initial credentials (Vault token)

**Decision:** Rejected - OIDC provides same benefits without additional infrastructure

### Alternative 3: Cloud-Specific CI/CD (CodePipeline, Cloud Build, Azure DevOps)

**Pros:**
- Native integration with cloud IAM
- No credential management needed
- Built-in security features

**Cons:**
- Vendor lock-in to specific cloud
- Different tool for each cloud
- Migration cost from GitHub Actions
- Less flexible than GitHub Actions

**Decision:** Rejected - Want to maintain multi-cloud flexibility and GitHub Actions

### Alternative 4: Assume Role from Persistent Service Account

**Pros:**
- Middle ground between long-lived and OIDC
- Familiar to teams already using assume role

**Cons:**
- Still requires initial long-lived credential
- Doesn't eliminate the root problem
- More complex than direct OIDC

**Decision:** Rejected - Doesn't fully solve the credential storage issue

## Implementation Plan

### Phase 1: Infrastructure Setup (Week 1)
- [ ] Deploy AWS OIDC provider and IAM role
- [ ] Deploy GCP Workload Identity pool and service account
- [ ] Deploy Azure federated credentials and service principal
- [ ] Test authentication from GitHub Actions

### Phase 2: Documentation (Week 1-2)
- [ ] Create setup guides for each cloud
- [ ] Document troubleshooting steps
- [ ] Write security analysis
- [ ] Create example workflows

### Phase 3: Migration (Week 2-4)
- [ ] Update existing workflows to use OIDC
- [ ] Test deployments in dev environment
- [ ] Validate in staging environment
- [ ] Production cutover with rollback plan

### Phase 4: Cleanup (Week 4)
- [ ] Remove long-lived credentials from GitHub Secrets
- [ ] Delete IAM users/service accounts (after validation period)
- [ ] Update team documentation
- [ ] Conduct security review

## Success Metrics

| Metric | Target | Actual |
|--------|--------|--------|
| Zero long-lived credentials stored | Yes | ✓ |
| Successful auth rate | > 99.5% | TBD |
| Time to deploy after merge | < 5 min | TBD |
| Credential rotation burden | 0 hours/month | ✓ |
| Security incidents related to credentials | 0 | ✓ |

## Review Schedule

- **30 days**: Operational review - any auth issues?
- **90 days**: Security review - audit logs, anomalies?
- **180 days**: ROI review - time saved, incidents prevented?
- **1 year**: Architecture review - still the best approach?

## References

- [GitHub Actions OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [AWS IAM OIDC](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [GCP Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [Azure Workload Identity](https://learn.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation)
- [NIST Zero Trust Architecture](https://www.nist.gov/publications/zero-trust-architecture)

## Authors

- Mike Dominic (@MikeDominic92)

## Approval

- Security Team: ✓ Approved
- DevOps Team: ✓ Approved
- Compliance: ✓ Approved

---

**Note**: This ADR represents the architectural decision for the Keyless Kingdom portfolio project. In a real enterprise setting, this would go through additional review cycles and approval processes.
