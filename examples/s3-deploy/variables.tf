variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "bucket_prefix" {
  description = "Prefix for S3 bucket name"
  type        = string
  default     = "keyless-kingdom-deploy"
}

variable "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role (from terraform/aws output)"
  type        = string
  # Example: "arn:aws:iam::123456789012:role/github-actions-role"
}
