#!/usr/bin/env bash
set -euo pipefail

# Parse outputs
CRITICAL_TOPIC=$(jq -r '.sns_topic_arns.value.critical' outputs.json)
WARNING_TOPIC=$(jq -r '.sns_topic_arns.value.warning' outputs.json)
INFO_TOPIC=$(jq -r '.sns_topic_arns.value.info' outputs.json)
DASHBOARD_URL=$(jq -r '.dashboard_url.value // "null"' outputs.json)

# --- SNS Topics ---
echo "Checking SNS topics..."
for SEVERITY in critical warning info; do
  TOPIC_ARN=$(jq -r ".sns_topic_arns.value.${SEVERITY}" outputs.json)
  aws sns get-topic-attributes --topic-arn "$TOPIC_ARN" --query 'Attributes.TopicArn' --output text >/dev/null 2>&1 || {
    echo "FAIL: ${SEVERITY} SNS topic not found (${TOPIC_ARN})"
    exit 1
  }
  echo "  ${SEVERITY}: topic exists"
done

# --- CloudWatch Alarms ---
echo "Checking cluster alarms..."
ALARM_ARNS=$(jq -r '.alarm_arns.value // [] | .[]' outputs.json)
if [[ -n "$ALARM_ARNS" ]]; then
  for ALARM_ARN in $ALARM_ARNS; do
    ALARM_NAME=$(echo "$ALARM_ARN" | awk -F':' '{print $NF}')
    ALARM_STATE=$(aws cloudwatch describe-alarms --alarm-names "$ALARM_NAME" --query 'MetricAlarms[0].StateValue' --output text 2>/dev/null || echo "NOT_FOUND")
    if [[ "$ALARM_STATE" == "NOT_FOUND" || -z "$ALARM_STATE" ]]; then
      echo "FAIL: alarm not found (${ALARM_NAME})"
      exit 1
    fi
    echo "  ${ALARM_NAME}: ${ALARM_STATE}"
  done
else
  echo "  No cluster alarms configured"
fi

# --- Dashboard ---
if [[ "$DASHBOARD_URL" != "null" ]]; then
  echo "Checking CloudWatch dashboard..."
  # Extract dashboard name from URL
  DASH_NAME=$(echo "$DASHBOARD_URL" | grep -o 'name=.*' | sed 's/name=//')
  DASH_EXISTS=$(aws cloudwatch get-dashboard --dashboard-name "$DASH_NAME" --query 'DashboardName' --output text 2>/dev/null || echo "NOT_FOUND")
  if [[ "$DASH_EXISTS" == "NOT_FOUND" ]]; then
    echo "FAIL: dashboard '${DASH_NAME}' not found"
    exit 1
  fi
  echo "  Dashboard exists: ${DASH_NAME}"
else
  echo "Skipping dashboard (not enabled)"
fi

echo "PASS: all observability checks passed"
