terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0, != 5.71.0"
    }
    kafka = {
      source  = "Mongey/kafka"
      version = "~> 0.7"
    }
  }
  required_version = "1.7.4"
}

# Configure the AWS Provider

provider "aws" {
  # alias  = "eu-central-1"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account}:role/automation-gha-ci"
  }
}

provider "kafka" {
  bootstrap_servers = local.brokers
  tls_enabled       = true
  sasl_mechanism    = "aws-iam"
  sasl_aws_role_arn = "arn:aws:iam::${var.aws_account}:role/automation-gha-ci"
  sasl_aws_region   = var.aws_region
  skip_tls_verify   = true
}