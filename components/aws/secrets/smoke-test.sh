#!/usr/bin/env bash
set -euo pipefail

# Parse outputs
KMS_KEY_ID=$(jq -r '.kms_key_id.value' outputs.json)
IRSA_ROLE_ARN=$(jq -r '.irsa_role_arn.value' outputs.json)

# --- KMS Key ---
echo "Checking secrets KMS key..."
KEY_STATE=$(aws kms describe-key --key-id "$KMS_KEY_ID" --query 'KeyMetadata.KeyState' --output text 2>/dev/null || echo "NOT_FOUND")
if [[ "$KEY_STATE" != "Enabled" ]]; then
  echo "FAIL: KMS key state is '${KEY_STATE}', expected 'Enabled'"
  exit 1
fi
echo "  KMS key is Enabled"

# --- Secrets ---
echo "Checking Secrets Manager secrets..."
SECRETS=$(jq -r '.secret_arns.value // {} | to_entries[] | "\(.key) \(.value)"' outputs.json)
if [[ -n "$SECRETS" ]]; then
  while IFS=' ' read -r SECRET_KEY SECRET_ARN; do
    SECRET_STATUS=$(aws secretsmanager describe-secret --secret-id "$SECRET_ARN" --query 'Name' --output text 2>/dev/null || echo "NOT_FOUND")
    if [[ "$SECRET_STATUS" == "NOT_FOUND" ]]; then
      echo "FAIL: secret '${SECRET_KEY}' not found (${SECRET_ARN})"
      exit 1
    fi
    echo "  ${SECRET_KEY}: exists"
  done <<< "$SECRETS"
else
  echo "  No secrets configured"
fi

# --- IRSA Role ---
echo "Checking external-secrets IRSA role..."
ROLE_NAME=$(echo "$IRSA_ROLE_ARN" | awk -F'/' '{print $NF}')
aws iam get-role --role-name "$ROLE_NAME" --query 'Role.RoleName' --output text >/dev/null 2>&1 || {
  echo "FAIL: IRSA role '${ROLE_NAME}' not found"
  exit 1
}
echo "  IRSA role exists"

echo "PASS: all secrets checks passed"
