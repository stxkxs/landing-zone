#!/usr/bin/env bash
set -euo pipefail

# Parse tenants from outputs
TENANTS=$(jq -r '.tenants.value | keys[]' outputs.json)

if [[ -z "$TENANTS" ]]; then
  echo "No tenants configured, nothing to check"
  echo "PASS: all rag checks passed"
  exit 0
fi

for TENANT in $TENANTS; do
  echo "=== Tenant: ${TENANT} ==="

  # --- OpenSearch Serverless ---
  OPENSEARCH_ARN=$(jq -r ".tenants.value[\"${TENANT}\"].opensearch_collection_arn" outputs.json)
  OPENSEARCH_ENDPOINT=$(jq -r ".tenants.value[\"${TENANT}\"].opensearch_endpoint" outputs.json)
  if [[ -n "$OPENSEARCH_ARN" && "$OPENSEARCH_ARN" != "null" ]]; then
    echo "Checking OpenSearch Serverless collection..."
    COLLECTION_ID=$(echo "$OPENSEARCH_ARN" | awk -F'/' '{print $NF}')
    COLLECTION_STATUS=$(aws opensearchserverless batch-get-collection --ids "$COLLECTION_ID" --query 'collectionDetails[0].status' --output text 2>/dev/null || echo "NOT_FOUND")
    if [[ "$COLLECTION_STATUS" != "ACTIVE" ]]; then
      echo "FAIL: OpenSearch collection status is '${COLLECTION_STATUS}'"
      exit 1
    fi
    echo "  OpenSearch collection ACTIVE (${OPENSEARCH_ENDPOINT})"
  fi

  # --- Document Bucket ---
  DOC_BUCKET=$(jq -r ".tenants.value[\"${TENANT}\"].document_bucket" outputs.json)
  echo "Checking document bucket..."
  if ! aws s3api head-bucket --bucket "$DOC_BUCKET" 2>/dev/null; then
    echo "FAIL: document bucket '${DOC_BUCKET}' not found"
    exit 1
  fi
  echo "  Document bucket exists"

  # --- DynamoDB Conversations Table ---
  CONV_TABLE=$(jq -r ".tenants.value[\"${TENANT}\"].conversations_table" outputs.json)
  echo "Checking conversations table..."
  TABLE_STATUS=$(aws dynamodb describe-table --table-name "$CONV_TABLE" --query 'Table.TableStatus' --output text 2>/dev/null || echo "NOT_FOUND")
  if [[ "$TABLE_STATUS" != "ACTIVE" ]]; then
    echo "FAIL: DynamoDB table '${CONV_TABLE}' status is '${TABLE_STATUS}'"
    exit 1
  fi
  echo "  Conversations table ACTIVE"

  # --- IRSA Role ---
  IRSA_ARN=$(jq -r ".tenants.value[\"${TENANT}\"].irsa_arn" outputs.json)
  if [[ -n "$IRSA_ARN" && "$IRSA_ARN" != "null" ]]; then
    ROLE_NAME=$(echo "$IRSA_ARN" | awk -F'/' '{print $NF}')
    echo "Checking IRSA role..."
    aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1 || {
      echo "FAIL: IRSA role '${ROLE_NAME}' not found"
      exit 1
    }
    echo "  IRSA role exists"
  fi
done

echo "PASS: all rag checks passed"
