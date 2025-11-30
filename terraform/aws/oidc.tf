# GitHub OIDC Provider for AWS
# This allows GitHub Actions to authenticate to AWS without storing long-lived credentials

# Get GitHub's OIDC provider thumbprint
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# Create the OIDC identity provider
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]

  tags = {
    Name        = "github-actions-oidc"
    Description = "OIDC provider for GitHub Actions"
  }
}

# Trust policy document for the IAM role
# This defines which GitHub repositories can assume the role
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Restrict to specific repository
    # This is the key security control - only workflows from this repo can assume the role
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_repo}:*"
      ]
    }
  }
}

# Optional: More restrictive trust policy for production
# Uncomment and use this for production deployments that should only run from main branch
# data "aws_iam_policy_document" "github_actions_assume_role_strict" {
#   statement {
#     effect = "Allow"
#
#     principals {
#       type        = "Federated"
#       identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
#     }
#
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#
#     condition {
#       test     = "StringEquals"
#       variable = "token.actions.githubusercontent.com:aud"
#       values   = ["sts.amazonaws.com"]
#     }
#
#     # Only allow from main branch
#     condition {
#       test     = "StringEquals"
#       variable = "token.actions.githubusercontent.com:sub"
#       values   = ["repo:${var.github_repo}:ref:refs/heads/main"]
#     }
#   }
# }
