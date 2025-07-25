#!/bin/bash

# Initialize variables
env=""
region=""
account=""
account_id=""

# Parse command-line arguments
while getopts "e:r:a:i:" opt; do
  case $opt in
    e) env="$OPTARG" ;;
    r) region="$OPTARG" ;;
    a) account="$OPTARG" ;;
    i) account_id="$OPTARG" ;;
    *) 
      echo "Usage: $0 -e <environment> -r <region> -a <account> -i <account_id>"
      exit 1
      ;;
  esac
done

# Check if all required arguments are provided
if [[ -z "$env" || -z "$region" || -z "$account" || -z "$account_id" ]]; then
  echo "Usage: $0 -e <environment> -r <region> -a <account> -i <account_id>"
  exit 1
fi

output_dir="./terraform/services/config/${account}/${region}"
mkdir -p "$output_dir"
if [[ $? -ne 0 ]]; then
  echo "Failed to create directory: $output_dir"
  exit 1
fi

      # Create tfvars file
      
      cat <<EOT > ./terraform/services/config/${account}/${region}/terraform.tfvars
aws_region  = "${region}"
environment = "${env}"
aws_account = "${account_id}"
EOT

if [[ $? -ne 0 ]]; then
  echo "Failed to create terraform.tfvars"
  exit 1
fi
      # Create config.remote file
      cat <<EOT > ./terraform/services/config/${account}/${region}/config.remote
bucket         = "${account_id}-tfstate"
key            = "msk/services/${account}/${region}/service.tfstate"
region         = "eu-central-1"
dynamodb_table = "${account_id}-tfstate-lock"
role_arn       = "arn:aws:iam::${account_id}:role/automation-gha-ci"
EOT