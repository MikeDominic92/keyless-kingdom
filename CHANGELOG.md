# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2025-12-05

### Added - Chainguard Supply Chain Security Integration

#### Chainguard Images Integration (`chainguard/`)
- **Keyless Container Image Signing** - Sign container images using Cosign with OIDC tokens
- **Chainguard Images Pull Authentication** - OIDC-based registry authentication without stored credentials
- **SLSA Provenance Generation** - Generate Build Level 3 attestations with keyless signing
- **Multi-Cloud Container Deployment** - Deploy to AWS ECR, GCP GCR, Azure ACR with OIDC

#### GitHub Actions Keyless Workflow (`chainguard/cosign-keyless-example/`)
- Complete workflow for building, signing, and verifying container images
- SBOM generation and attestation with Sigstore
- Independent signature verification job
- No stored signing keys required

#### Documentation
- Comprehensive Chainguard integration patterns in `chainguard/README.md`
- Supply chain security best practices
- Integration with Chainguard's zero-CVE base images

### Why This Matters

This release addresses critical supply chain security requirements:

| Problem | Solution | Impact |
|---------|----------|--------|
| Stored signing keys can be leaked | Keyless signing with OIDC tokens | No credentials to manage or rotate |
| Container images have CVEs | Chainguard hardened base images | Zero or minimal CVE exposure |
| Supply chain attacks are increasing | SLSA provenance attestation | Cryptographic proof of build integrity |
| Manual credential rotation | Automatic short-lived tokens | Reduced operational burden |

### Interview Questions This Answers

| Question | How This Feature Answers It |
|----------|----------------------------|
| "How do you secure CI/CD pipelines?" | OIDC workload identity - no stored credentials anywhere |
| "What's your approach to supply chain security?" | Sigstore/Cosign keyless signing with SLSA provenance |
| "How familiar are you with Chainguard?" | Integrated Chainguard Images with keyless pull authentication |
| "How do you handle credential rotation?" | Short-lived tokens issued on-demand, no rotation needed |

### Compliance Alignment
- **SOC 2 CC6.1**: Access security through identity federation
- **SOC 2 CC6.6**: Logical access restrictions via OIDC claims
- **NIST 800-53 IA-5**: Authenticator management without stored credentials
- **SLSA Level 3**: Build integrity through provenance attestation

---

## [1.0.0] - 2025-11-30

### Added
- Initial release of Keyless Kingdom
- Full multi-cloud workload identity federation support
- Production-ready Terraform configurations
- Complete CI/CD pipeline examples
- Comprehensive documentation and setup guides

[Unreleased]: https://github.com/MikeDominic92/keyless-kingdom/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/MikeDominic92/keyless-kingdom/releases/tag/v1.0.0
