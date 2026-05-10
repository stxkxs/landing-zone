#!/usr/bin/env bash
set -euo pipefail

# Parse outputs
SNS_TOPIC_ARN=$(jq -r '.sns_topic_arn.value' outputs.json)

# --- SNS Topic ---
echo "Checking quota alerts SNS topic..."
aws sns get-topic-attributes --topic-arn "$SNS_TOPIC_ARN" --query 'Attributes.TopicArn' --output text >/dev/null 2>&1 || {
  echo "FAIL: SNS topic not found (${SNS_TOPIC_ARN})"
  exit 1
}
echo "  SNS topic exists"

# --- CloudWatch Alarms ---
echo "Checking quota alarms..."
ALARMS=$(jq -r '.alarm_arns.value // {} | to_entries[] | "\(.key) \(.value)"' outputs.json)
if [[ -n "$ALARMS" ]]; then
  while IFS=' ' read -r ALARM_KEY ALARM_ARN; do
    ALARM_NAME=$(echo "$ALARM_ARN" | awk -F':' '{print $NF}')
    ALARM_STATE=$(aws cloudwatch describe-alarms --alarm-names "$ALARM_NAME" --query 'MetricAlarms[0].StateValue' --output text 2>/dev/null || echo "NOT_FOUND")
    if [[ "$ALARM_STATE" == "NOT_FOUND" || -z "$ALARM_STATE" ]]; then
      echo "FAIL: alarm '${ALARM_KEY}' not found"
      exit 1
    fi
    echo "  ${ALARM_KEY}: ${ALARM_STATE}"
  done <<< "$ALARMS"
else
  echo "  No quota alarms configured"
fi

echo "PASS: all service-quotas checks passed"
