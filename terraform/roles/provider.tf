terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0, != 5.71.0"
    }
  }
  backend "s3" {}
  required_version = ">=1.7.4"
}

# Configure the AWS Provider
provider "aws" {
  # alias  = "secret"
  region = "eu-central-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account}:role/automation-gha-ci"
  }
}