output "msk_cluster_arn" {
  value = aws_msk_cluster.main.arn
}

output "bootstrap_brokers_sasl_iam" {
  value = aws_msk_cluster.main.bootstrap_brokers_sasl_iam
}

output "bootstrap_brokers_vpc_connectivity_sasl_iam" {
  value = aws_msk_cluster.main.bootstrap_brokers_vpc_connectivity_sasl_iam
}

output "number_of_broker_nodes" {
  value = local.number_of_broker_nodes
}

output "zookeeper_connect_string" {
  value = aws_msk_cluster.main.zookeeper_connect_string
}

output "zookeeper_connect_string_tls" {
  value = aws_msk_cluster.main.zookeeper_connect_string_tls
}

output "security_group_ids" {
  value = [aws_security_group.sg.id]
}