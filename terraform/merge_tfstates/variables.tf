# variable "environment" {
#   description = "The environment"
#   type        = string
#   default     = "dev"
# }

# variable "aws_region" {
#   type    = string
#   default = "us-east-1"
# }

variable "aws_account" {
  type = string
}

variable "msk_regions" {
  description = "List of regions to fetch MSK data"
  type        = list(string)
  default     = [] # Example regions
}

variable "aws_account_name" {
  type = string
}

variable "primary_region" {
  description = "List of regions to fetch MSK data"
  type        = string
  default     = ""
}

variable "secondary_region" {
  description = "List of regions to fetch MSK data"
  type        = string
  default     = ""
}