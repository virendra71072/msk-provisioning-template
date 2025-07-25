data "terraform_remote_state" "msk" {
  for_each = toset(local.msk_regions)
  backend  = "s3"
  config = {
    bucket = "${var.aws_account}-tfstate"
    key    = "msk/services/${var.aws_account_name}/${each.key}/service.tfstate"
    region = "eu-central-1"
    assume_role = {
      role_arn = "arn:aws:iam::${var.aws_account}:role/automation-gha-ci"
    }
  }
}