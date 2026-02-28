#!/usr/bin/env bash
set -euo pipefail

# Parse outputs
GUARDDUTY_ID=$(jq -r '.guardduty_detector_id.value // "null"' outputs.json)
SECURITYHUB_ARN=$(jq -r '.securityhub_arn.value // "null"' outputs.json)
SNS_TOPIC_ARN=$(jq -r '.sns_topic_arn.value' outputs.json)

# --- GuardDuty ---
if [[ "$GUARDDUTY_ID" != "null" ]]; then
  echo "Checking GuardDuty detector..."
  GD_STATUS=$(aws guardduty get-detector --detector-id "$GUARDDUTY_ID" --query 'Status' --output text 2>/dev/null || echo "NOT_FOUND")
  if [[ "$GD_STATUS" != "ENABLED" ]]; then
    echo "FAIL: GuardDuty detector status is '${GD_STATUS}'"
    exit 1
  fi
  echo "  GuardDuty detector is ENABLED"
else
  echo "Skipping GuardDuty (not enabled)"
fi

# --- Security Hub ---
if [[ "$SECURITYHUB_ARN" != "null" ]]; then
  echo "Checking Security Hub..."
  SH_STATUS=$(aws securityhub describe-hub --query 'HubArn' --output text 2>/dev/null || echo "NOT_FOUND")
  if [[ "$SH_STATUS" == "NOT_FOUND" ]]; then
    echo "FAIL: Security Hub not found"
    exit 1
  fi
  echo "  Security Hub is enabled"

  # Check enabled standards
  STANDARDS_COUNT=$(aws securityhub get-enabled-standards --query 'StandardsSubscriptions | length(@)' --output text 2>/dev/null || echo "0")
  echo "  ${STANDARDS_COUNT} security standard(s) enabled"
else
  echo "Skipping Security Hub (not enabled)"
fi

# --- SNS Topic ---
echo "Checking security alerts SNS topic..."
aws sns get-topic-attributes --topic-arn "$SNS_TOPIC_ARN" --query 'Attributes.TopicArn' --output text >/dev/null 2>&1 || {
  echo "FAIL: SNS topic not found (${SNS_TOPIC_ARN})"
  exit 1
}
echo "  SNS topic exists"

echo "PASS: all org-security checks passed"
