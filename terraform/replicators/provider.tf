terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.14.0"
    }
  }
  required_version = "1.7.4"
}

# Configure the AWS Provider
provider "aws" {
  alias  = "primary"
  region = var.primary_region
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account}:role/automation-gha-ci"
  }
}
provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account}:role/automation-gha-ci"
  }
}

provider "awscc" {
  alias  = "primary"
  region = var.primary_region
  assume_role = {
    role_arn = "arn:aws:iam::${var.aws_account}:role/automation-gha-ci"
  }
}
provider "awscc" {
  alias  = "secondary"
  region = var.secondary_region
  assume_role = {
    role_arn = "arn:aws:iam::${var.aws_account}:role/automation-gha-ci"
  }
}




