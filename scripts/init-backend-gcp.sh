#!/usr/bin/env bash
set -euo pipefail

# Creates the GCS bucket for Terraform state.
# Usage: ./scripts/init-backend-gcp.sh <project_id> <region>

PROJECT_ID="${1:?Usage: init-backend-gcp.sh <project_id> <region>}"
REGION="${2:?Usage: init-backend-gcp.sh <project_id> <region>}"
BUCKET="${PROJECT_ID}-${REGION}-tfstate"

echo "Creating GCS bucket: ${BUCKET}"
if gcloud storage buckets describe "gs://${BUCKET}" --project="${PROJECT_ID}" > /dev/null 2>&1; then
  echo "Bucket already exists."
else
  gcloud storage buckets create "gs://${BUCKET}" \
    --project="${PROJECT_ID}" \
    --location="${REGION}" \
    --uniform-bucket-level-access \
    --public-access-prevention

  gcloud storage buckets update "gs://${BUCKET}" \
    --versioning

  echo "Bucket created and configured."
fi

echo "Backend infrastructure ready."
