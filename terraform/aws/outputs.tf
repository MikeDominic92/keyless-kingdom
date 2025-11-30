output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github_actions.arn
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions - use this in your workflows"
  value       = aws_iam_role.github_actions.arn
}

output "github_actions_role_name" {
  description = "Name of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions.name
}

output "github_actions_prod_role_arn" {
  description = "ARN of the production IAM role for GitHub Actions (if created)"
  value       = var.create_prod_role ? aws_iam_role.github_actions_prod[0].arn : null
}

output "aws_account_id" {
  description = "AWS Account ID where resources are deployed"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "workflow_configuration" {
  description = "Configuration snippet for GitHub Actions workflow"
  value = {
    role_to_assume = aws_iam_role.github_actions.arn
    aws_region     = var.aws_region
    example_workflow_step = <<-EOT
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${aws_iam_role.github_actions.arn}
          aws-region: ${var.aws_region}
          role-session-name: GitHubActions-${{ github.run_id }}
    EOT
  }
}

output "trust_policy_subjects" {
  description = "Subject claims that can assume this role"
  value       = "repo:${var.github_repo}:*"
}
