# Chainguard Integration Patterns

> **Chainguard Relevance:** This module demonstrates Zero Trust authentication patterns aligned with Chainguard's core mission of software supply chain security - directly relevant to IT Engineer (Identity/IAM) role.

## Overview

This module extends Keyless Kingdom's OIDC workload identity federation to support Chainguard-specific security patterns, including:

- **Chainguard Images** integration with keyless authentication
- **Cosign** image signing using OIDC tokens
- **SLSA** provenance verification
- **Supply chain security** attestations

## Why Chainguard + Keyless?

Chainguard's mission is to make the software supply chain secure by default. Keyless Kingdom's approach of eliminating stored credentials aligns perfectly with this mission:

| Traditional Approach | Keyless Kingdom + Chainguard |
|---------------------|------------------------------|
| Long-lived registry credentials | OIDC token exchange |
| Manual secret rotation | Automatic token refresh |
| Broad registry permissions | Scoped per-workflow |
| No audit correlation | Full traceability |

## Patterns Implemented

### 1. Keyless Container Image Signing

Sign container images using OIDC tokens without storing signing keys:

```yaml
# .github/workflows/sign-image.yml
name: Build and Sign Image

on:
  push:
    branches: [main]

permissions:
  id-token: write
  packages: write
  contents: read

jobs:
  build-and-sign:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Cosign
        uses: sigstore/cosign-installer@v3

      - name: Login to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build Image
        run: |
          docker build -t ghcr.io/${{ github.repository }}:${{ github.sha }} .
          docker push ghcr.io/${{ github.repository }}:${{ github.sha }}

      - name: Sign Image with Keyless
        run: |
          # Uses GitHub's OIDC token - no stored keys!
          cosign sign --yes ghcr.io/${{ github.repository }}:${{ github.sha }}

      - name: Verify Signature
        run: |
          cosign verify \
            --certificate-identity-regexp="https://github.com/${{ github.repository }}.*" \
            --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
            ghcr.io/${{ github.repository }}:${{ github.sha }}
```

### 2. Chainguard Images with OIDC Pull

Pull Chainguard Images using OIDC authentication instead of stored credentials:

```yaml
# .github/workflows/use-chainguard-images.yml
name: Use Chainguard Images

on:
  push:
    branches: [main]

permissions:
  id-token: write
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Authenticate to Chainguard Registry
        uses: chainguard-dev/actions/setup-chainctl@main
        with:
          identity: ${{ secrets.CHAINGUARD_IDENTITY }}

      # Now use Chainguard images without stored credentials
      - name: Build with Chainguard Base
        run: |
          docker build \
            --build-arg BASE_IMAGE=cgr.dev/chainguard/python:latest \
            -t myapp:${{ github.sha }} .
```

### 3. SLSA Provenance with Keyless

Generate SLSA provenance using OIDC-based attestations:

```yaml
# .github/workflows/slsa-provenance.yml
name: SLSA Provenance

on:
  push:
    branches: [main]

permissions:
  id-token: write
  packages: write
  contents: read
  attestations: write

jobs:
  build-with-provenance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build Image
        id: build
        run: |
          docker build -t ghcr.io/${{ github.repository }}:${{ github.sha }} .
          docker push ghcr.io/${{ github.repository }}:${{ github.sha }}
          echo "digest=$(docker inspect --format='{{index .RepoDigests 0}}' ghcr.io/${{ github.repository }}:${{ github.sha }})" >> $GITHUB_OUTPUT

      - name: Generate SLSA Provenance
        uses: slsa-framework/slsa-github-generator/.github/workflows/generator_container_slsa3.yml@v1.9.0
        with:
          image: ghcr.io/${{ github.repository }}
          digest: ${{ steps.build.outputs.digest }}

      - name: Attest Build Provenance
        uses: actions/attest-build-provenance@v1
        with:
          subject-name: ghcr.io/${{ github.repository }}
          subject-digest: ${{ steps.build.outputs.digest }}
```

### 4. Multi-Cloud Container Deployment with Keyless

Deploy to AWS ECR, GCP GCR, and Azure ACR using OIDC:

```yaml
# .github/workflows/multi-cloud-deploy.yml
name: Multi-Cloud Container Deploy

on:
  push:
    branches: [main]

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        cloud: [aws, gcp, azure]
    steps:
      - uses: actions/checkout@v4

      # AWS ECR
      - name: Configure AWS Credentials (Keyless)
        if: matrix.cloud == 'aws'
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/github-actions
          aws-region: us-west-2

      - name: Push to ECR
        if: matrix.cloud == 'aws'
        run: |
          aws ecr get-login-password | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-west-2.amazonaws.com
          docker push 123456789012.dkr.ecr.us-west-2.amazonaws.com/myapp:${{ github.sha }}

      # GCP GCR
      - name: Configure GCP Credentials (Keyless)
        if: matrix.cloud == 'gcp'
        uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: projects/123456/locations/global/workloadIdentityPools/github/providers/github
          service_account: github-actions@project.iam.gserviceaccount.com

      - name: Push to GCR
        if: matrix.cloud == 'gcp'
        run: |
          gcloud auth configure-docker gcr.io
          docker push gcr.io/project/myapp:${{ github.sha }}

      # Azure ACR
      - name: Configure Azure Credentials (Keyless)
        if: matrix.cloud == 'azure'
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Push to ACR
        if: matrix.cloud == 'azure'
        run: |
          az acr login --name myregistry
          docker push myregistry.azurecr.io/myapp:${{ github.sha }}
```

## Security Comparison

### Before: Stored Credentials

```yaml
# INSECURE - Stored registry credentials
env:
  REGISTRY_USERNAME: ${{ secrets.REGISTRY_USER }}
  REGISTRY_PASSWORD: ${{ secrets.REGISTRY_TOKEN }}

steps:
  - run: |
      echo "$REGISTRY_PASSWORD" | docker login -u "$REGISTRY_USERNAME" --password-stdin
```

**Risks:**
- Credentials can be leaked
- No automatic rotation
- Broad permissions
- No audit trail linking to specific workflow runs

### After: Keyless OIDC

```yaml
# SECURE - OIDC token exchange
permissions:
  id-token: write

steps:
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::123456789012:role/github-actions
```

**Benefits:**
- No stored credentials
- Automatic token refresh
- Scoped to specific repos/branches
- Full audit trail

## Cosign Keyless Verification

Verify that an image was signed by a specific GitHub repository:

```bash
# Verify image was signed by this repository
cosign verify \
  --certificate-identity="https://github.com/MikeDominic92/keyless-kingdom/.github/workflows/sign-image.yml@refs/heads/main" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/mikedominic92/keyless-kingdom:latest

# Verify SLSA provenance
cosign verify-attestation \
  --type slsaprovenance \
  --certificate-identity-regexp="https://github.com/slsa-framework/slsa-github-generator.*" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/mikedominic92/keyless-kingdom:latest
```

## Chainguard-Specific Benefits

1. **Zero CVE Base Images** - Chainguard Images have minimal attack surface
2. **Signed by Default** - All Chainguard Images are signed with Sigstore
3. **SLSA Build Level 3** - Provenance for every image
4. **OIDC-First** - Designed for keyless authentication

## Integration with Keyless Kingdom

This module extends the core Keyless Kingdom patterns:

| Keyless Kingdom | + Chainguard Patterns |
|-----------------|----------------------|
| AWS OIDC Provider | + ECR with Cosign signing |
| GCP Workload Identity | + GCR with SLSA attestations |
| Azure Federated Credentials | + ACR with provenance |
| GitHub Actions OIDC | + Sigstore keyless signing |

## Files

| File | Description |
|------|-------------|
| `README.md` | This documentation |
| `cosign-keyless-example/` | Cosign signing workflow |
| `chainguard-images-example/` | Chainguard image integration |
| `slsa-provenance-example/` | SLSA attestation workflow |

## Author

**Mike Dominic** - December 2025

This module demonstrates supply chain security patterns aligned with Chainguard's mission and IT Engineer (Identity/IAM) role requirements for Zero Trust architecture.
