locals {
  kafka_version = "3.7.x"
  # vpc_cidr                 = data.terraform_remote_state.vpc.outputs.vpc_cidr_block[var.aws_region]
  # vpc_id                   = data.terraform_remote_state.vpc.outputs.vpc_id[var.aws_region]
  # availability_zones_count = length(data.terraform_remote_state.vpc.outputs.private_subnets[var.aws_region])
  # number_of_broker_nodes   = local.availability_zones_count * var.number_of_broker_nodes
  # private_subnets          = data.terraform_remote_state.vpc.outputs.private_subnets[var.aws_region]

  # cluster_name = "${var.cluster_name}-${var.environment}-${var.aws_region}"

  # ip_ranges = data.aws_ip_ranges.ip_ranges_ec2.cidr_blocks
  selected_regions = [var.primary_region, var.secondary_region]
  clusters = {
    for selected_region in local.selected_regions : selected_region => {
      vpc_cidr                 = data.terraform_remote_state.vpc.outputs.vpc_cidr_block[selected_region]
      vpc_id                   = data.terraform_remote_state.vpc.outputs.vpc_id[selected_region]
      availability_zones_count = length(data.terraform_remote_state.vpc.outputs.private_subnets[selected_region])
      number_of_broker_nodes   = length(data.terraform_remote_state.vpc.outputs.private_subnets[selected_region]) * var.number_of_broker_nodes
      private_subnets          = data.terraform_remote_state.vpc.outputs.private_subnets[selected_region]
      cluster_name             = "${var.cluster_name}-${var.environment}-${selected_region}"
    }
  }
  primary_security_group_ids   = data.terraform_remote_state.msk.outputs.security_group_ids[var.primary_region]
  secondary_security_group_ids = data.terraform_remote_state.msk.outputs.security_group_ids[var.secondary_region]
}
