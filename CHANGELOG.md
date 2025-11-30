# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure
- AWS OIDC provider and IAM role configuration
- GCP Workload Identity Pool and Provider setup
- Azure Federated Identity Credential configuration
- Reusable OIDC trust Terraform module
- GitHub Actions workflows for AWS, GCP, Azure, and multi-cloud deployments
- Comprehensive documentation including setup guides for each cloud provider
- Architecture Decision Record for OIDC federation choice
- Security analysis and threat model documentation
- Cost analysis (spoiler: it's free!)
- Example Terraform configurations for S3, GCS, and Azure Blob deployments
- Validation script for testing identity federation
- MIT License
- Contributing guidelines

### Security
- Zero long-lived credentials stored in repository
- Fine-grained IAM policies following principle of least privilege
- OIDC token validation with repository-specific conditions
- Audit trail integration with cloud provider logging

## [1.0.0] - 2025-11-30

### Added
- Initial release of Keyless Kingdom
- Full multi-cloud workload identity federation support
- Production-ready Terraform configurations
- Complete CI/CD pipeline examples
- Comprehensive documentation and setup guides

[Unreleased]: https://github.com/MikeDominic92/keyless-kingdom/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/MikeDominic92/keyless-kingdom/releases/tag/v1.0.0
