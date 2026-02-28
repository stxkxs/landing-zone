#!/usr/bin/env bash
set -euo pipefail

# Parse outputs
VAULT_NAME=$(jq -r '.vault_name.value' outputs.json)
BACKUP_ROLE_ARN=$(jq -r '.backup_role_arn.value' outputs.json)
NOTIFICATION_TOPIC=$(jq -r '.notification_topic_arn.value' outputs.json)

# --- Backup Vault ---
echo "Checking backup vault '${VAULT_NAME}'..."
VAULT_EXISTS=$(aws backup describe-backup-vault --backup-vault-name "$VAULT_NAME" --query 'BackupVaultName' --output text 2>/dev/null || echo "NOT_FOUND")
if [[ "$VAULT_EXISTS" == "NOT_FOUND" ]]; then
  echo "FAIL: backup vault '${VAULT_NAME}' not found"
  exit 1
fi

ENCRYPTION=$(aws backup describe-backup-vault --backup-vault-name "$VAULT_NAME" --query 'EncryptionKeyArn' --output text)
if [[ -z "$ENCRYPTION" || "$ENCRYPTION" == "None" ]]; then
  echo "FAIL: backup vault has no encryption key"
  exit 1
fi
echo "  Vault exists, encrypted with KMS"

# --- Backup Plans ---
echo "Checking backup plans..."
PLAN_ARNS=$(jq -r '.plan_arns.value // {} | to_entries[] | "\(.key) \(.value)"' outputs.json)
if [[ -n "$PLAN_ARNS" ]]; then
  while IFS=' ' read -r PLAN_NAME PLAN_ARN; do
    PLAN_ID=$(echo "$PLAN_ARN" | awk -F'/' '{print $2}')
    PLAN_STATUS=$(aws backup get-backup-plan --backup-plan-id "$PLAN_ID" --query 'BackupPlanId' --output text 2>/dev/null || echo "NOT_FOUND")
    if [[ "$PLAN_STATUS" == "NOT_FOUND" ]]; then
      echo "FAIL: backup plan '${PLAN_NAME}' not found"
      exit 1
    fi
    echo "  ${PLAN_NAME}: plan exists"
  done <<< "$PLAN_ARNS"
else
  echo "  No backup plans configured"
fi

# --- IAM Role ---
echo "Checking backup IAM role..."
ROLE_NAME=$(echo "$BACKUP_ROLE_ARN" | awk -F'/' '{print $NF}')
aws iam get-role --role-name "$ROLE_NAME" --query 'Role.RoleName' --output text >/dev/null 2>&1 || {
  echo "FAIL: backup IAM role '${ROLE_NAME}' not found"
  exit 1
}
echo "  Backup IAM role exists"

# --- SNS Topic ---
echo "Checking notification topic..."
aws sns get-topic-attributes --topic-arn "$NOTIFICATION_TOPIC" --query 'Attributes.TopicArn' --output text >/dev/null 2>&1 || {
  echo "FAIL: SNS topic not found (${NOTIFICATION_TOPIC})"
  exit 1
}
echo "  SNS notification topic exists"

echo "PASS: all backup checks passed"
