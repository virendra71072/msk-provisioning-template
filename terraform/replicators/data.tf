data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "${var.aws_account}-tfstate"
    key    = "platform/vpc"
    region = "eu-central-1"
    assume_role = {
      role_arn = "arn:aws:iam::${var.aws_account}:role/automation-gha-ci"
    }
  }
}

data "terraform_remote_state" "msk" {
  backend = "s3"

  config = {
    bucket = "${var.aws_account}-tfstate"
    key    = "platform/msk"
    region = "eu-central-1"
    assume_role = {
      role_arn = "arn:aws:iam::${var.aws_account}:role/automation-gha-ci"
    }
  }
}