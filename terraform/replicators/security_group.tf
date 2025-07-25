# # Security Group
# resource "aws_security_group" "primary_sg" {
#   provider = aws.primary
#   vpc_id   = local.clusters[var.primary_region].vpc_id
#   ingress {
#     from_port   = 9098
#     to_port     = 9100
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "MSK-replicator-sg-${var.primary_region}"
#   }
# }

# resource "aws_security_group" "secondary_sg" {
#   provider = aws.secondary
#   vpc_id   = local.clusters[var.secondary_region].vpc_id
#   ingress {
#     from_port   = 9098
#     to_port     = 9100
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "MSK-replicator-sg-${var.secondary_region}"
#   }
# }
