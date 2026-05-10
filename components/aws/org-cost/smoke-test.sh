#!/usr/bin/env bash
set -euo pipefail

# Parse outputs
BUDGET_NAME=$(jq -r '.budget_name.value' outputs.json)
ANOMALY_MONITOR_SERVICE=$(jq -r '.anomaly_monitor_service_arn.value // "null"' outputs.json)
ANOMALY_MONITOR_ACCOUNT=$(jq -r '.anomaly_monitor_account_arn.value // "null"' outputs.json)
CUR_BUCKET=$(jq -r '.cur_export_bucket_name.value // "null"' outputs.json)

# --- Org Budget ---
echo "Checking org budget '${BUDGET_NAME}'..."
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
BUDGET_STATUS=$(aws budgets describe-budget --account-id "$ACCOUNT_ID" --budget-name "$BUDGET_NAME" --query 'Budget.BudgetName' --output text 2>/dev/null || echo "NOT_FOUND")
if [[ "$BUDGET_STATUS" == "NOT_FOUND" ]]; then
  echo "FAIL: org budget '${BUDGET_NAME}' not found"
  exit 1
fi
echo "  Org budget exists"

# --- Cost Anomaly Monitors ---
for MONITOR_LABEL in "service:${ANOMALY_MONITOR_SERVICE}" "account:${ANOMALY_MONITOR_ACCOUNT}"; do
  LABEL=${MONITOR_LABEL%%:*}
  ARN=${MONITOR_LABEL#*:}
  if [[ "$ARN" != "null" ]]; then
    echo "Checking cost anomaly monitor (${LABEL})..."
    MONITOR_NAME=$(aws ce get-anomaly-monitors --monitor-arn-list "$ARN" --query 'AnomalyMonitors[0].MonitorName' --output text 2>/dev/null || echo "NOT_FOUND")
    if [[ "$MONITOR_NAME" == "NOT_FOUND" ]]; then
      echo "FAIL: cost anomaly monitor (${LABEL}) not found"
      exit 1
    fi
    echo "  ${LABEL} monitor exists: ${MONITOR_NAME}"
  fi
done

# --- Cost Categories ---
echo "Checking cost categories..."
CATEGORIES=$(jq -r '.cost_category_arns.value // {} | to_entries[] | "\(.key) \(.value)"' outputs.json)
if [[ -n "$CATEGORIES" ]]; then
  while IFS=' ' read -r CAT_NAME CAT_ARN; do
    CAT_STATUS=$(aws ce describe-cost-category-definition --cost-category-arn "$CAT_ARN" --query 'CostCategory.Name' --output text 2>/dev/null || echo "NOT_FOUND")
    if [[ "$CAT_STATUS" == "NOT_FOUND" ]]; then
      echo "FAIL: cost category '${CAT_NAME}' not found"
      exit 1
    fi
    echo "  ${CAT_NAME}: exists"
  done <<< "$CATEGORIES"
else
  echo "  No cost categories configured"
fi

# --- CUR Export Bucket ---
if [[ "$CUR_BUCKET" != "null" ]]; then
  echo "Checking CUR export bucket..."
  if ! aws s3api head-bucket --bucket "$CUR_BUCKET" 2>/dev/null; then
    echo "FAIL: CUR export bucket '${CUR_BUCKET}' not found"
    exit 1
  fi
  echo "  CUR export bucket exists"
fi

echo "PASS: all org-cost checks passed"
