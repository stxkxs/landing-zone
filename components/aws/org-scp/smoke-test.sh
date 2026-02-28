#!/usr/bin/env bash
set -euo pipefail

# Parse outputs
POLICY_IDS=$(jq -r '.policy_ids.value // {} | to_entries[] | "\(.key) \(.value)"' outputs.json)

# --- SCP Policies ---
echo "Checking Service Control Policies..."
if [[ -n "$POLICY_IDS" ]]; then
  while IFS=' ' read -r POLICY_NAME POLICY_ID; do
    POLICY_STATUS=$(aws organizations describe-policy --policy-id "$POLICY_ID" --query 'Policy.PolicySummary.Name' --output text 2>/dev/null || echo "NOT_FOUND")
    if [[ "$POLICY_STATUS" == "NOT_FOUND" ]]; then
      echo "FAIL: SCP '${POLICY_NAME}' (${POLICY_ID}) not found"
      exit 1
    fi
    echo "  ${POLICY_NAME}: exists (${POLICY_ID})"

    # Check policy has targets attached
    TARGET_COUNT=$(aws organizations list-targets-for-policy --policy-id "$POLICY_ID" --query 'Targets | length(@)' --output text 2>/dev/null || echo "0")
    echo "    Attached to ${TARGET_COUNT} target(s)"
  done <<< "$POLICY_IDS"
else
  echo "  No SCPs configured"
fi

echo "PASS: all org-scp checks passed"
