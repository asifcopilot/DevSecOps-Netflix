#!/bin/bash

# Function to check if the ACR name exists
check_acr_name() {
  local acr_name=$1
  az acr check-name --name "$acr_name" --query 'nameAvailable' --output tsv
}

# Prompt the user for the ACR name
while true; do
  read -p "Enter the Azure Container Registry name: " ACR_NAME
  if [ "$(check_acr_name "$ACR_NAME")" == "true" ]; then
    echo "The name '$ACR_NAME' is available."
    break
  else
    echo "The name '$ACR_NAME' is already taken. Please enter a different name."
  fi
done

# Export the ACR_NAME to be used by Terraform
export TF_VAR_acr_name=$ACR_NAME

# Run Terraform
# terraform init
terraform apply -auto-approve