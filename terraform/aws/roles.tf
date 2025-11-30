# IAM Role for GitHub Actions
# This role is assumed by GitHub Actions workflows using OIDC

resource "aws_iam_role" "github_actions" {
  name               = var.github_actions_role_name
  description        = "Role for GitHub Actions via OIDC for ${var.github_repo}"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  max_session_duration = 3600 # 1 hour

  tags = {
    Name        = var.github_actions_role_name
    Description = "GitHub Actions OIDC role"
  }
}

# Policy document defining what the role can do
# This follows the principle of least privilege
data "aws_iam_policy_document" "github_actions_permissions" {
  # S3 permissions - for example deployments
  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.deployment_bucket_prefix}-*",
      "arn:${data.aws_partition.current.partition}:s3:::${var.deployment_bucket_prefix}-*/*",
    ]
  }

  # CloudFront invalidation - for static site deployments
  statement {
    sid    = "CloudFrontInvalidation"
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation",
    ]
    resources = ["*"]

    # Optional: Add condition to restrict to specific distributions
    # condition {
    #   test     = "StringEquals"
    #   variable = "aws:ResourceTag/Project"
    #   values   = ["KeylessKingdom"]
    # }
  }

  # ECR permissions - for container deployments
  statement {
    sid    = "ECRAccess"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]
    resources = ["*"]
  }

  # IAM read-only - for auditing and verification
  statement {
    sid    = "IAMReadOnly"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
    ]
    resources = [aws_iam_role.github_actions.arn]
  }

  # STS GetCallerIdentity - for verifying assumed identity
  statement {
    sid       = "STSGetCallerIdentity"
    effect    = "Allow"
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }
}

# Attach the permissions policy to the role
resource "aws_iam_role_policy" "github_actions" {
  name   = "github-actions-permissions"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_actions_permissions.json
}

# Optional: Attach AWS managed policies if needed
# Example: Read-only access for validation
resource "aws_iam_role_policy_attachment" "readonly" {
  count      = var.enable_readonly_access ? 1 : 0
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/ReadOnlyAccess"
}

# Optional: Additional role for different environments (staging, prod)
# This demonstrates how to create environment-specific roles with different permissions

resource "aws_iam_role" "github_actions_prod" {
  count              = var.create_prod_role ? 1 : 0
  name               = "${var.github_actions_role_name}-prod"
  description        = "Production role for GitHub Actions via OIDC for ${var.github_repo}"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  max_session_duration = 3600

  tags = {
    Name        = "${var.github_actions_role_name}-prod"
    Description = "GitHub Actions OIDC role for production"
    Environment = "production"
  }
}

# Production role policy - more restrictive
data "aws_iam_policy_document" "github_actions_prod_permissions" {
  count = var.create_prod_role ? 1 : 0

  # S3 - read-only in production (deployments managed separately)
  statement {
    sid    = "S3ReadOnly"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.deployment_bucket_prefix}-prod",
      "arn:${data.aws_partition.current.partition}:s3:::${var.deployment_bucket_prefix}-prod/*",
    ]
  }

  # No write access in production - only read/verify
  statement {
    sid       = "STSGetCallerIdentity"
    effect    = "Allow"
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_actions_prod" {
  count  = var.create_prod_role ? 1 : 0
  name   = "github-actions-prod-permissions"
  role   = aws_iam_role.github_actions_prod[0].id
  policy = data.aws_iam_policy_document.github_actions_prod_permissions[0].json
}
