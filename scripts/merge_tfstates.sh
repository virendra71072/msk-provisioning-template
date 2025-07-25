#!/bin/bash

# Initialize variables
env=""
region=""
account=""
account_id=""
secondary_region=""
primary_region=""


# Parse command-line arguments
while getopts "e:r:a:i:p:s:" opt; do
  case $opt in
    e) env="$OPTARG" ;;
    r) region="$OPTARG" ;;
    a) account="$OPTARG" ;;
    i) account_id="$OPTARG" ;;
    p) primary_region="$OPTARG" ;;
    s) secondary_region="$OPTARG" ;;
    *) 
      echo "Usage: $0 -e <environment> -r <region> -a <account> -i <account_id> -s <msk_regions_string>"
      exit 1
      ;;
  esac
done

# msk_regions=$(echo "$msk_regions_string" | jq -R 'split(",") | map(gsub("^\\s+|\\s+$"; ""))')

BUCKET_NAME="${account_id}-tfstate"


available_regions=()

# Loop through each region and check if the file exists

if aws s3api head-object --bucket "$BUCKET_NAME" --key "msk/services/${account}/${primary_region}/service.tfstate" >/dev/null 2>&1; then
  available_regions+=("$primary_region")
fi 
if aws s3api head-object --bucket "$BUCKET_NAME" --key "msk/services/${account}/${secondary_region}/service.tfstate" >/dev/null 2>&1; then
  available_regions+=("$secondary_region")
fi   
msk_regions=$(echo "${available_regions[*]}" | jq -R '. | split(" ")')
output_dir="./terraform/merge_tfstates/config/${account}"
mkdir -p "$output_dir"
if [[ $? -ne 0 ]]; then
  echo "Failed to create directory: $output_dir"
  exit 1
fi

      # Create tfvars file
      
      cat <<EOT > ./terraform/merge_tfstates/config/${account}/terraform.tfvars
aws_account = "${account_id}"
msk_regions = ${msk_regions}
primary_region = "${primary_region}"
secondary_region = "${secondary_region}"
EOT

# aws_region  = "${region}"
# environment = "${env}"

if [[ $? -ne 0 ]]; then
  echo "Failed to create terraform.tfvars"
  exit 1
fi
      # Create config.remote file
      cat <<EOT > ./terraform/merge_tfstates/config/${account}/config.remote
bucket         = "${account_id}-tfstate"
key            = "platform/msk"
region         = "eu-central-1"
dynamodb_table = "${account_id}-tfstate-lock"
role_arn       = "arn:aws:iam::${account_id}:role/automation-gha-ci"
EOT

#role_arn       = "arn:aws:iam::${account_id}:role/automation-gha-ci"