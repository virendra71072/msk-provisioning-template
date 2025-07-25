
output "msk_cluster_arn" {
  value = {
    "primary" : try(
      data.terraform_remote_state.msk[var.primary_region].outputs.msk_cluster_arn,
      ""
    )
    "secondary" : try(
      data.terraform_remote_state.msk[var.secondary_region].outputs.msk_cluster_arn,
      ""
    )
  }
}
output "bootstrap_brokers_sasl_iam" {
  value = {
    "primary" : split(",", try(
      data.terraform_remote_state.msk[var.primary_region].outputs.bootstrap_brokers_sasl_iam,
      ""
    ))
    "secondary" : split(",", try(
      data.terraform_remote_state.msk[var.secondary_region].outputs.bootstrap_brokers_sasl_iam,
      ""
    ))
  }
}

output "bootstrap_brokers_vpc_connectivity_sasl_iam" {
  value = {
    "primary" : split(",", try(
      data.terraform_remote_state.msk[var.primary_region].outputs.bootstrap_brokers_vpc_connectivity_sasl_iam,
      ""
    ))
    "secondary" : split(",", try(
      data.terraform_remote_state.msk[var.secondary_region].outputs.bootstrap_brokers_vpc_connectivity_sasl_iam,
      ""
    ))
  }
}

output "number_of_broker_nodes" {
  value = {
    "primary" : try(
      data.terraform_remote_state.msk[var.primary_region].outputs.number_of_broker_nodes,
      ""
    )
    "secondary" : try(
      data.terraform_remote_state.msk[var.secondary_region].outputs.number_of_broker_nodes,
      ""
    )
  }
}

output "zookeeper_connect_string" {
  value = {
    "primary" : split(",", try(
      data.terraform_remote_state.msk[var.primary_region].outputs.zookeeper_connect_string,
      ""
    ))
    "secondary" : split(",", try(
      data.terraform_remote_state.msk[var.secondary_region].outputs.zookeeper_connect_string,
      ""
    ))
  }
}
output "zookeeper_connect_string_tls" {
  value = {
    "primary" : split(",", try(
      data.terraform_remote_state.msk[var.primary_region].outputs.zookeeper_connect_string_tls,
      ""
    ))
    "secondary" : split(",", try(
      data.terraform_remote_state.msk[var.secondary_region].outputs.zookeeper_connect_string_tls,
      ""
    ))
  }
}

output "region_info" {
  value = {
    "primary" : try(
      var.primary_region,
      ""
    )
    "secondary" : try(
      var.secondary_region,
      ""
    )
  }
}
output "security_group_ids" {
  value = {
    for region in local.msk_regions :
    region => try(data.terraform_remote_state.msk[region].outputs.security_group_ids, "")
  }
}