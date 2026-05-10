#!/usr/bin/env bash
set -euo pipefail

# Parse outputs
KMS_KEY_ARN=$(jq -r '.kms_key_arn.value' outputs.json)
CLOUDTRAIL_ARN=$(jq -r '.cloudtrail_arn.value // "null"' outputs.json)
CLOUDTRAIL_BUCKET=$(jq -r '.cloudtrail_bucket_name.value // "null"' outputs.json)
CONFIG_RECORDER_ID=$(jq -r '.config_recorder_id.value // "null"' outputs.json)
CONFIG_BUCKET=$(jq -r '.config_bucket_name.value // "null"' outputs.json)

# --- KMS Key ---
echo "Checking compliance KMS key..."
KEY_STATE=$(aws kms describe-key --key-id "$KMS_KEY_ARN" --query 'KeyMetadata.KeyState' --output text 2>/dev/null || echo "NOT_FOUND")
if [[ "$KEY_STATE" != "Enabled" ]]; then
  echo "FAIL: KMS key state is '${KEY_STATE}'"
  exit 1
fi
echo "  KMS key is Enabled"

# --- CloudTrail ---
if [[ "$CLOUDTRAIL_ARN" != "null" ]]; then
  TRAIL_NAME=$(echo "$CLOUDTRAIL_ARN" | awk -F'/' '{print $NF}')
  echo "Checking CloudTrail '${TRAIL_NAME}'..."
  TRAIL_STATUS=$(aws cloudtrail get-trail-status --name "$TRAIL_NAME" --query 'IsLogging' --output text 2>/dev/null || echo "NOT_FOUND")
  if [[ "$TRAIL_STATUS" != "True" ]]; then
    echo "FAIL: CloudTrail is not logging (status: ${TRAIL_STATUS})"
    exit 1
  fi
  echo "  CloudTrail is logging"

  if [[ "$CLOUDTRAIL_BUCKET" != "null" ]]; then
    echo "Checking CloudTrail S3 bucket..."
    if ! aws s3api head-bucket --bucket "$CLOUDTRAIL_BUCKET" 2>/dev/null; then
      echo "FAIL: CloudTrail bucket '${CLOUDTRAIL_BUCKET}' not found"
      exit 1
    fi
    echo "  CloudTrail bucket exists"
  fi
else
  echo "Skipping CloudTrail (not enabled)"
fi

# --- AWS Config ---
if [[ "$CONFIG_RECORDER_ID" != "null" ]]; then
  echo "Checking AWS Config recorder..."
  RECORDER_STATUS=$(aws configservice describe-configuration-recorder-status --configuration-recorder-names "$CONFIG_RECORDER_ID" --query 'ConfigurationRecordersStatus[0].recording' --output text 2>/dev/null || echo "NOT_FOUND")
  if [[ "$RECORDER_STATUS" != "True" ]]; then
    echo "FAIL: Config recorder is not recording (status: ${RECORDER_STATUS})"
    exit 1
  fi
  echo "  Config recorder is recording"

  if [[ "$CONFIG_BUCKET" != "null" ]]; then
    echo "Checking Config S3 bucket..."
    if ! aws s3api head-bucket --bucket "$CONFIG_BUCKET" 2>/dev/null; then
      echo "FAIL: Config bucket '${CONFIG_BUCKET}' not found"
      exit 1
    fi
    echo "  Config bucket exists"
  fi
else
  echo "Skipping Config recorder (not enabled)"
fi

echo "PASS: all org-compliance checks passed"
