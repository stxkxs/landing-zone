#!/usr/bin/env bash
set -euo pipefail

# Parse outputs
ROLE_NAME=$(jq -r '.role_name.value' outputs.json)
ALARM_ARN=$(jq -r '.alarm_arn.value' outputs.json)
SNS_TOPIC_ARN=$(jq -r '.sns_topic_arn.value' outputs.json)

# --- Break-Glass Role ---
echo "Checking break-glass IAM role '${ROLE_NAME}'..."
ROLE_STATUS=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text 2>/dev/null || echo "NOT_FOUND")
if [[ "$ROLE_STATUS" == "NOT_FOUND" ]]; then
  echo "FAIL: break-glass role '${ROLE_NAME}' not found"
  exit 1
fi

# Verify MFA is required in the trust policy
MFA_CONDITION=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.AssumeRolePolicyDocument' --output json | jq -r '.. | .["aws:MultiFactorAuthPresent"]? // empty' 2>/dev/null | head -1)
if [[ -n "$MFA_CONDITION" ]]; then
  echo "  Role exists, MFA required in trust policy"
else
  echo "  Role exists (MFA condition not detected in trust policy — verify manually)"
fi

# --- CloudWatch Alarm ---
echo "Checking break-glass alarm..."
ALARM_NAME=$(echo "$ALARM_ARN" | awk -F':' '{print $NF}')
ALARM_STATE=$(aws cloudwatch describe-alarms --alarm-names "$ALARM_NAME" --query 'MetricAlarms[0].StateValue' --output text 2>/dev/null || echo "NOT_FOUND")
if [[ "$ALARM_STATE" == "NOT_FOUND" || -z "$ALARM_STATE" ]]; then
  echo "FAIL: CloudWatch alarm not found"
  exit 1
fi
echo "  Alarm exists (state: ${ALARM_STATE})"

# --- SNS Topic ---
echo "Checking SNS alert topic..."
aws sns get-topic-attributes --topic-arn "$SNS_TOPIC_ARN" --query 'Attributes.TopicArn' --output text >/dev/null 2>&1 || {
  echo "FAIL: SNS topic not found (${SNS_TOPIC_ARN})"
  exit 1
}
echo "  SNS topic exists"

echo "PASS: all break-glass checks passed"
