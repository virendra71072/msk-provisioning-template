data "aws_iam_role" "msk_replicator_role" {
  provider = aws.primary
  name     = "msk-replicator-role" # Replace with your actual IAM role name
}

data "aws_msk_cluster" "msk_primary" {
  provider     = aws.primary
  cluster_name = local.clusters[var.primary_region].cluster_name
}
data "aws_msk_cluster" "msk_secondary" {
  provider     = aws.secondary
  cluster_name = local.clusters[var.secondary_region].cluster_name
}
# MSK Replicator Resource for Cross-Region Replication

resource "awscc_msk_replicator" "msk-replicator" {
  provider                   = awscc.primary
  replicator_name            = "msk-replicator-${var.primary_region}-to-${var.secondary_region}"
  description                = "MSK replicator ${var.primary_region} with ${var.secondary_region}"
  service_execution_role_arn = data.aws_iam_role.msk_replicator_role.arn
  kafka_clusters = [{
    amazon_msk_cluster = {
      msk_cluster_arn = data.aws_msk_cluster.msk_primary.arn
    }

    vpc_config = {
      subnet_ids         = local.clusters[var.primary_region].private_subnets
      security_group_ids = local.primary_security_group_ids
    }
    },
    {
      amazon_msk_cluster = {
        msk_cluster_arn = data.aws_msk_cluster.msk_secondary.arn
      }

      vpc_config = {
        subnet_ids         = local.clusters[var.secondary_region].private_subnets
        security_group_ids = local.secondary_security_group_ids
      }
  }]
  replication_info_list = [{
    source_kafka_cluster_arn = data.aws_msk_cluster.msk_secondary.arn
    target_kafka_cluster_arn = data.aws_msk_cluster.msk_primary.arn
    target_compression_type  = "NONE"

    # Topic Replication Configuration
    topic_replication = {
      topics_to_replicate = [".*"] # Replicate all topics
      starting_position = {
        type = "LATEST" # Replicate from the latest position
      }
      detect_and_copy_new_topics           = true
      copy_access_control_lists_for_topics = true
      copy_topic_configurations            = true
      topic_name_configuration = {
        type = "IDENTICAL" //"PREFIXED_WITH_SOURCE_CLUSTER_ALIAS"|"IDENTICAL"
      }
    }

    # Consumer Group Replication Configuration
    consumer_group_replication = {
      consumer_groups_to_replicate = [".*"] # Replicate all consumer groups
    }
  }]
}

# resource "aws_msk_replicator" "msk-replicator_eu" {
#   provider                   = aws.eu-central-1
#   replicator_name            = "msk-replicator-eu"
#   description                = "MSK replicator eu-central-1 with us-east-1"
#   service_execution_role_arn = aws_iam_role.msk_replicator_role.arn

#   # Source MSK Cluster Configuration (us-east-1)
#   kafka_cluster {
#     amazon_msk_cluster {
#       msk_cluster_arn = aws_msk_cluster.main_eu.arn
#     }

#     vpc_config {
#       subnet_ids          = local.private_subnets_eu
#       security_groups_ids = [aws_security_group.sg_eu.id]
#     }
#   }

#   # Target MSK Cluster Configuration (eu-central-1)
#   kafka_cluster {
#     amazon_msk_cluster {
#       msk_cluster_arn = aws_msk_cluster.main_us.arn
#     }

#     vpc_config {
#       subnet_ids          = local.private_subnets_us
#       security_groups_ids = [aws_security_group.sg_us.id]
#     }
#   }

#   # Replication Information
#   replication_info_list {
#     source_kafka_cluster_arn = aws_msk_cluster.main_us.arn
#     target_kafka_cluster_arn = aws_msk_cluster.main_eu.arn
#     target_compression_type  = "NONE"

#     # Topic Replication Configuration
#     topic_replication {
#       topics_to_replicate = [".*"] # Replicate all topics
#       starting_position {
#         type = "LATEST" # Replicate from the latest position
#       }
#       detect_and_copy_new_topics = true
#       copy_access_control_lists_for_topics = true
#       copy_topic_configurations = true
#     }

#     # Consumer Group Replication Configuration
#     consumer_group_replication {
#       consumer_groups_to_replicate = [".*"] # Replicate all consumer groups
#     }
#   }
# }

# resource "aws_msk_replicator" "msk-replicator_us" {
#   provider                   = aws.us-east-1
#   replicator_name            = "msk-replicator-us"
#   description                = "MSK replicator us-east-1 with eu-central-1"
#   service_execution_role_arn = aws_iam_role.msk_replicator_role.arn

#   # Target MSK Cluster Configuration (us-east-1)
#   kafka_cluster {
#     amazon_msk_cluster {
#       msk_cluster_arn = aws_msk_cluster.main_us.arn
#     }

#     vpc_config {
#       subnet_ids          = local.private_subnets_us
#       security_groups_ids = [aws_security_group.sg_us.id]
#     }
#   }

#   # Source MSK Cluster Configuration (eu-central-1)
#   kafka_cluster {
#     amazon_msk_cluster {
#       msk_cluster_arn = aws_msk_cluster.main_eu.arn
#     }

#     vpc_config {
#       subnet_ids          = local.private_subnets_eu
#       security_groups_ids = [aws_security_group.sg_eu.id]
#     }
#   }

#   # Replication Information
#   replication_info_list {
#     target_kafka_cluster_arn = aws_msk_cluster.main_us.arn
#     source_kafka_cluster_arn = aws_msk_cluster.main_eu.arn
#     target_compression_type  = "NONE"

#     # Topic Replication Configuration
#     topic_replication {
#       topics_to_replicate = [".*"] # Replicate all topics
#       starting_position {
#         type = "LATEST" # Replicate from the latest position
#       }
#       detect_and_copy_new_topics = true
#       copy_access_control_lists_for_topics = true
#       copy_topic_configurations = true
#     }

#     # Consumer Group Replication Configuration
#     consumer_group_replication {
#       consumer_groups_to_replicate = [".*"] # Replicate all consumer groups
#     }
#   }
# }
