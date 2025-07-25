variable "vpc_cidr_eu" {
  description = "CIDR block for the VPC"
  default     = "10.1.0.0/16"
}

variable "instance_type" {
  description = "Instance type for the Kafka brokers"
  default     = "kafka.m5.large"
}

variable "number_of_broker_nodes" {
  description = "Number of broker nodes in the MSK cluster"
  type        = number
  default     = 1
  validation {
    condition     = var.number_of_broker_nodes > 0 && var.number_of_broker_nodes <= 30
    error_message = "Number of broker nodes must be between 1 to 30."
  }
}

variable "broker_volume_size" {
  description = "Size of the EBS volume for each broker node"
  default     = 50
}

variable "environment" {
  description = "The environment"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "The environment"
  type        = string
  default     = "provision-cluster"
}

variable "cluster_node_name" {
  description = "The environment"
  type        = string
  default     = "msk_node_group"
}

variable "ec2_enabled" {
  type        = bool
  description = "Enables EC2 for MSK use"
  default     = false
}

# variable "serviceIP" {
#   description = "EC2 Instance Connect service IP"
#   default     = "18.206.107.24/29"
# }

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_account" {
  type    = string
  default = "010526239227"
}

variable "aws_secret_profile" {
  type    = string
  default = "secrets"
}

variable "aws_account_name" {
  type    = string
  default = "scylladb-stage"
}

variable "topics" {
  type    = list(string)
  default = ["TopicAP", "TopicPA", "TopicAAP"]
}
