resource "aws_iam_role" "prod_cons_role" {
  name = "MSKProducerConsumerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "msk_policy" {
  name        = "MSK-Policy"
  description = "Policy to allow access to MSK"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kafka:DescribeCluster",
          "kafka:GetBootstrapBrokers",
          "kafka:ListTopics",
          "kafka-cluster:*",
          "ssm:*",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "producer_attachment" {
  role       = aws_iam_role.prod_cons_role.name
  policy_arn = aws_iam_policy.msk_policy.arn
}

# MSK Replicator roles

resource "aws_iam_role" "msk_replicator_role" {
  name = "msk-replicator-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "kafka.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "msk_replicator_policy" {
  name        = "msk-replicator-policy"
  description = "Policy for MSK replicator access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",
          "kafka:WriteDataIdempotently",
          "kafka:DescribeCluster",
          "ec2:CreateNetworkInterface",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "iam:CreateServiceLinkedRole",
          "kafka:CreateReplicator",
          "kafka:CreateReplicatorReference",
          "kafka:DeleteReplicator",
          "kafka:DescribeClusterV2",
          "kafka:DescribeReplicator",
          "kafka:GetBootstrapBrokers",
          "kafka:ListReplicators",
          "kafka:ListTagsForResource",
          "kafka:TagResource",
          "kafka:UntagResource",
          "kafka:UpdateReplicationInfo",
          "kafka:CreateVpcConnection",
          "kafka:GetBootstrapBrokers",
          "kafka:DescribeClusterV2",
          "kafka-cluster:*"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "msk_replicator_attachment" {
  role       = aws_iam_role.msk_replicator_role.name
  policy_arn = aws_iam_policy.msk_replicator_policy.arn
}
resource "aws_iam_role_policy_attachment" "msk_full_access_attachment" {
  role       = aws_iam_role.msk_replicator_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonMSKFullAccess"
}

# resource "aws_iam_role_policy_attachment" "consumer_attachment" {
#   role       = aws_iam_role.consumer_role.name
#   policy_arn = aws_iam_policy.msk_policy.arn
# }

# ## IAM role for be-boilerplate on nitrous-playground account

# data "aws_iam_policy_document" "be_boilerplate_backend_appservice_assume" {
#   statement {
#     sid     = "kafkaTestAccess"
#     actions = ["sts:AssumeRole"]

#     principals {
#       type = "AWS"
#       identifiers = [

#         // GHA for kafka-client
#         "arn:aws:iam::010526239227:role/automation-gha-ci"
#       ]
#     }
#   }
# }

# resource "aws_iam_role" "be_boilerplate_backend_appservice" {
#   name               = "msk-provisioning-be_boilerplate_backend_appservice"
#   assume_role_policy = data.aws_iam_policy_document.be_boilerplate_backend_appservice_assume.json
# }

# data "aws_iam_policy_document" "be_boilerplate_backend_appservice" {
#   statement {
#     actions = [
#       "kafka:*",
#       "kafka-cluster:*"
#     ]
#     resources = aws_msk_cluster.main_eu.arn
#   }
#   statement {
#     actions = [
#       "kafka:*",
#       "kafka-cluster:*"
#     ]
#     resources = aws_msk_cluster.main_us.arn
#   }
# }

# resource "aws_iam_policy" "be_boilerplate_backend_appservice" {
#   name   = "msk-provisioning-policy-be_boilerplate_backend_appservice"
#   policy = data.aws_iam_policy_document.be_boilerplate_backend_appservice.json
# }

# resource "aws_iam_role_policy_attachment" "be_boilerplate_backend_appservice" {
#   role       = aws_iam_role.be_boilerplate_backend_appservice.name
#   policy_arn = aws_iam_policy.be_boilerplate_backend_appservice.arn
# }