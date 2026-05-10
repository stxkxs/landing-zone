#!/usr/bin/env bash
set -euo pipefail

# Creates the Azure storage account for Terraform state.
# Usage: ./scripts/init-backend-azure.sh <subscription_id> <region>

SUBSCRIPTION_ID="${1:?Usage: init-backend-azure.sh <subscription_id> <region>}"
REGION="${2:?Usage: init-backend-azure.sh <subscription_id> <region>}"
RESOURCE_GROUP="tfstate-rg"
STORAGE_ACCOUNT="tfstate$(echo "${SUBSCRIPTION_ID}" | tr -d '-' | cut -c1-12)"
CONTAINER="tfstate"

echo "Setting subscription: ${SUBSCRIPTION_ID}"
az account set --subscription "${SUBSCRIPTION_ID}"

echo "Creating resource group: ${RESOURCE_GROUP}"
az group create \
  --name "${RESOURCE_GROUP}" \
  --location "${REGION}" \
  --output none 2>/dev/null || true

echo "Creating storage account: ${STORAGE_ACCOUNT}"
if az storage account show --name "${STORAGE_ACCOUNT}" --resource-group "${RESOURCE_GROUP}" > /dev/null 2>&1; then
  echo "Storage account already exists."
else
  az storage account create \
    --name "${STORAGE_ACCOUNT}" \
    --resource-group "${RESOURCE_GROUP}" \
    --location "${REGION}" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --min-tls-version TLS1_2 \
    --allow-blob-public-access false \
    --output none

  echo "Storage account created."
fi

echo "Creating blob container: ${CONTAINER}"
az storage container create \
  --name "${CONTAINER}" \
  --account-name "${STORAGE_ACCOUNT}" \
  --output none 2>/dev/null || true

echo "Backend infrastructure ready."
