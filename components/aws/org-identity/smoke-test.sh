#!/usr/bin/env bash
set -euo pipefail

# Parse outputs
SSO_INSTANCE_ARN=$(jq -r '.sso_instance_arn.value' outputs.json)
IDENTITY_STORE_ID=$(jq -r '.identity_store_id.value' outputs.json)

# --- SSO Instance ---
echo "Checking SSO instance..."
SSO_STATUS=$(aws sso-admin list-instances --query "Instances[?InstanceArn=='${SSO_INSTANCE_ARN}'].InstanceArn" --output text 2>/dev/null || echo "NOT_FOUND")
if [[ -z "$SSO_STATUS" || "$SSO_STATUS" == "NOT_FOUND" ]]; then
  echo "FAIL: SSO instance not found (${SSO_INSTANCE_ARN})"
  exit 1
fi
echo "  SSO instance exists"

# --- Permission Sets ---
echo "Checking permission sets..."
PERM_SETS=$(jq -r '.permission_set_arns.value // {} | to_entries[] | "\(.key) \(.value)"' outputs.json)
if [[ -n "$PERM_SETS" ]]; then
  while IFS=' ' read -r PS_NAME PS_ARN; do
    PS_STATUS=$(aws sso-admin describe-permission-set --instance-arn "$SSO_INSTANCE_ARN" --permission-set-arn "$PS_ARN" --query 'PermissionSet.Name' --output text 2>/dev/null || echo "NOT_FOUND")
    if [[ "$PS_STATUS" == "NOT_FOUND" ]]; then
      echo "FAIL: permission set '${PS_NAME}' not found"
      exit 1
    fi
    echo "  ${PS_NAME}: exists"
  done <<< "$PERM_SETS"
else
  echo "  No permission sets configured"
fi

# --- Identity Store Groups ---
echo "Checking identity store groups..."
GROUPS=$(jq -r '.group_ids.value // {} | to_entries[] | "\(.key) \(.value)"' outputs.json)
if [[ -n "$GROUPS" ]]; then
  while IFS=' ' read -r GROUP_NAME GROUP_ID; do
    GROUP_STATUS=$(aws identitystore describe-group --identity-store-id "$IDENTITY_STORE_ID" --group-id "$GROUP_ID" --query 'DisplayName' --output text 2>/dev/null || echo "NOT_FOUND")
    if [[ "$GROUP_STATUS" == "NOT_FOUND" ]]; then
      echo "FAIL: identity store group '${GROUP_NAME}' not found"
      exit 1
    fi
    echo "  ${GROUP_NAME}: exists (${GROUP_ID})"
  done <<< "$GROUPS"
else
  echo "  No identity store groups configured"
fi

echo "PASS: all org-identity checks passed"
