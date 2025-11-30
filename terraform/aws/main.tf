terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "KeylessKingdom"
      ManagedBy   = "Terraform"
      Environment = var.environment
      Repository  = var.github_repo
    }
  }
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# Data source to get AWS partition (aws, aws-cn, aws-us-gov)
data "aws_partition" "current" {}
