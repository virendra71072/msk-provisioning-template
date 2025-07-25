# Create MSK Configuration
resource "aws_msk_configuration" "custom_config" {
  name           = "msk-multi-vpc-connectivity-config-${var.aws_region}"
  kafka_versions = [local.kafka_version] # Specify your Kafka version

  server_properties = <<PROPERTIES
auto.create.topics.enable = false
allow.everyone.if.no.acl.found = false
PROPERTIES
}

resource "aws_msk_cluster" "main" {
  cluster_name           = local.cluster_name
  kafka_version          = local.kafka_version
  number_of_broker_nodes = local.number_of_broker_nodes

  broker_node_group_info {
    instance_type = var.instance_type
    storage_info {
      ebs_storage_info {
        # provisioned_throughput {
        #   enabled           = true
        #   volume_throughput = 250
        # }
        volume_size = var.broker_volume_size
      }
    }

    client_subnets  = local.private_subnets
    security_groups = [aws_security_group.sg.id]
    connectivity_info {
      vpc_connectivity {
        client_authentication {
          sasl {
            iam = "true"
          }
        }
      }
      public_access {
        type = "DISABLED"
      }
    }
  }
  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }
  configuration_info {
    arn      = aws_msk_configuration.custom_config.arn
    revision = aws_msk_configuration.custom_config.latest_revision
  }
  client_authentication {
    unauthenticated = false
    sasl {
      iam   = true
      scram = false
    }

    tls {}
  }
  tags = {
    Name = "msk-provisioned-cluster-${var.aws_region}"
  }
  timeouts {
    create = "3h" # Increase timeout for creation to 1 hour
    update = "3h" # Increase timeout for updates to 1 hour
    delete = "1h" # Increase timeout for deletion to 30 minutes
  }

  # avoids issues with empty updates after manually setting multi-vpc connectivity & public endpoints: https://github.com/hashicorp/terraform-provider-aws/issues/24914
  lifecycle {
    ignore_changes = all
  }
}
resource "aws_msk_cluster_policy" "msk_cluster_policy" {
  cluster_arn = aws_msk_cluster.main.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow"
      "Principal" : {
        "AWS" : "*",
        Service = "kafka.amazonaws.com"
      },
      Action = [
        "kafka:CreateVpcConnection",
        "kafka:GetBootstrapBrokers",
        "kafka:DescribeCluster",
        "kafka:DescribeClusterV2",
        "kafka-cluster:Connect",
        "kafka-cluster:DescribeTopic",
        "kafka-cluster:*",
      ]
      Resource = "${aws_msk_cluster.main.arn}"
    }]
  })
  lifecycle {
    ignore_changes = all
  }
}

# resource "aws_vpc_endpoint" "msk" {
#   vpc_id             = local.vpc_id
#   service_name       = "com.amazonaws.${var.aws_region}.kafka"
#   vpc_endpoint_type  = "Interface"
#   subnet_ids         = local.private_subnets
#   security_group_ids = [aws_security_group.sg.id]
# }
