# Contributing to Keyless Kingdom

Thank you for considering contributing to Keyless Kingdom! This document provides guidelines and instructions for contributing.

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code:
- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on what is best for the community
- Show empathy towards other community members

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:
- A clear, descriptive title
- Steps to reproduce the issue
- Expected behavior vs actual behavior
- Your environment (Terraform version, cloud provider, OS)
- Relevant logs or error messages

### Suggesting Enhancements

Enhancement suggestions are welcome! Please create an issue with:
- A clear description of the enhancement
- Why this enhancement would be useful
- Examples of how it would work
- Any potential drawbacks or considerations

### Pull Requests

1. **Fork the repository** and create your branch from `main`:
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. **Make your changes**:
   - Follow the existing code style
   - Add comments for complex logic
   - Update documentation as needed

3. **Test your changes**:
   ```bash
   # Format Terraform code
   terraform fmt -recursive

   # Validate Terraform configurations
   cd terraform/aws && terraform validate
   cd terraform/gcp && terraform validate
   cd terraform/azure && terraform validate

   # Run validation script
   bash tests/validate_identity.sh
   ```

4. **Commit your changes**:
   - Use clear, descriptive commit messages
   - Follow conventional commits format:
     ```
     feat: add support for environment-specific OIDC
     fix: correct AWS trust policy condition
     docs: update GCP setup guide
     ```

5. **Push to your fork** and submit a pull request

6. **Wait for review**:
   - Address any feedback
   - Keep your branch up to date with main

## Development Guidelines

### Terraform Code Style

- Use consistent formatting: `terraform fmt`
- Use descriptive variable names
- Add descriptions to all variables and outputs
- Use tags on all resources that support them
- Follow the principle of least privilege for IAM permissions

Example:
```hcl
variable "github_repo" {
  description = "GitHub repository in the format 'owner/repo'"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+/[a-zA-Z0-9-_]+$", var.github_repo))
    error_message = "Repository must be in the format 'owner/repo'"
  }
}
```

### Documentation

- Update README.md if you change functionality
- Add comments to complex Terraform logic
- Update relevant setup guides in docs/
- Include examples for new features

### GitHub Actions Workflows

- Test workflows in your fork before submitting PR
- Use specific versions for actions (not @main)
- Add comments explaining non-obvious steps
- Follow security best practices (no secrets in logs)

### Security Considerations

When contributing, always consider:
- Are we following the principle of least privilege?
- Could this expose credentials or sensitive data?
- Are we properly validating OIDC token claims?
- Does this maintain the "keyless" nature of the project?

## Project Structure

```
keyless-kingdom/
├── terraform/              # Infrastructure as Code
│   ├── aws/               # AWS-specific Terraform
│   ├── gcp/               # GCP-specific Terraform
│   ├── azure/             # Azure-specific Terraform
│   └── modules/           # Reusable modules
├── .github/workflows/     # CI/CD pipelines
├── docs/                  # Documentation
│   ├── decisions/         # Architecture Decision Records
│   └── *.md              # Setup and reference guides
├── examples/              # Example usage
└── tests/                # Validation scripts
```

## Testing

### Local Testing

Before submitting a PR, test your changes:

1. **Terraform validation**:
   ```bash
   terraform fmt -check -recursive
   terraform validate
   ```

2. **Plan without applying**:
   ```bash
   terraform plan
   ```

3. **Test in a separate cloud account**:
   - Use a sandbox/dev account
   - Don't test in production
   - Clean up resources after testing

### CI/CD Testing

- All PRs must pass CI checks
- CI runs terraform fmt, validate, and plan
- Workflows are tested but not applied

## Adding New Cloud Providers

To add support for a new cloud provider:

1. Create a new directory under `terraform/`
2. Implement OIDC/workload identity federation
3. Add a GitHub Actions workflow
4. Create a setup guide in `docs/`
5. Add examples under `examples/`
6. Update the main README.md

## Documentation Standards

- Use clear, concise language
- Include code examples
- Add diagrams for complex concepts
- Keep setup guides up to date
- Follow markdown best practices

## Architecture Decision Records (ADRs)

For significant architectural changes:

1. Create a new ADR in `docs/decisions/`
2. Use the format: `ADR-XXX-title.md`
3. Include:
   - Status (proposed, accepted, deprecated)
   - Context
   - Decision
   - Consequences

See [ADR-001](docs/decisions/ADR-001-oidc-federation.md) as an example.

## Release Process

Maintainers handle releases:

1. Update CHANGELOG.md
2. Tag the release: `git tag -a v1.x.x -m "Release v1.x.x"`
3. Push tags: `git push --tags`
4. Create GitHub release with notes

## Getting Help

- Check existing issues and documentation
- Ask questions in GitHub Discussions
- Reach out to maintainers

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- GitHub contributors page

Thank you for contributing to making cloud authentication more secure!
