# data "aws_ip_ranges" "ip_ranges_ec2" {
#   regions  = [var.aws_region]
#   services = ["ec2_instance_connect"]
# }
# https://ip-ranges.amazonaws.com/ip-ranges.json
locals {
  kafka_version            = "3.7.x"
  vpc_cidr                 = data.terraform_remote_state.vpc.outputs.vpc_cidr_block[var.aws_region]
  vpc_id                   = data.terraform_remote_state.vpc.outputs.vpc_id[var.aws_region]
  availability_zones_count = length(data.terraform_remote_state.vpc.outputs.private_subnets[var.aws_region])
  number_of_broker_nodes   = local.availability_zones_count * var.number_of_broker_nodes
  private_subnets          = data.terraform_remote_state.vpc.outputs.private_subnets[var.aws_region]

  cluster_name             = "${var.cluster_name}-${var.environment}-${var.aws_region}"
  brokers                  = split(",", aws_msk_cluster.main.bootstrap_brokers_sasl_iam)
  brokers_vpc_connectivity = split(",", aws_msk_cluster.main.bootstrap_brokers_vpc_connectivity_sasl_iam)

  # ip_ranges = data.aws_ip_ranges.ip_ranges_ec2.cidr_blocks

  # clusters = {
  #   for selected_region in var.selected_regions : selected_region => {
  #     vpc_cidr                 = data.terraform_remote_state.vpc.outputs.vpc_cidr_block[selected_region]
  #     vpc_id                   = data.terraform_remote_state.vpc.outputs.vpc_id[selected_region]
  #     availability_zones_count = length(data.terraform_remote_state.vpc.outputs.private_subnets[selected_region])
  #     number_of_broker_nodes   = length(data.terraform_remote_state.vpc.outputs.private_subnets[selected_region]) * var.number_of_broker_nodes
  #     private_subnets          = data.terraform_remote_state.vpc.outputs.private_subnets[selected_region]
  #     cluster_name             = "${var.cluster_name}-${var.env}-${selected_region}"
  #   }
  # }
}
