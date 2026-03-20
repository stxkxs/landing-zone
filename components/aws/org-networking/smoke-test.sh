#!/usr/bin/env bash
set -euo pipefail

# Parse outputs
TGW_ID=$(jq -r '.transit_gateway_id.value // "null"' outputs.json)
RAM_SHARE_ARN=$(jq -r '.ram_share_arn.value // "null"' outputs.json)
IPAM_ID=$(jq -r '.ipam_id.value // "null"' outputs.json)
RESOLVER_INBOUND=$(jq -r '.resolver_inbound_endpoint_id.value // "null"' outputs.json)
RESOLVER_OUTBOUND=$(jq -r '.resolver_outbound_endpoint_id.value // "null"' outputs.json)

# --- Transit Gateway ---
if [[ "$TGW_ID" != "null" ]]; then
  echo "Checking Transit Gateway '${TGW_ID}'..."
  TGW_STATE=$(aws ec2 describe-transit-gateways --transit-gateway-ids "$TGW_ID" --query 'TransitGateways[0].State' --output text 2>/dev/null || echo "NOT_FOUND")
  if [[ "$TGW_STATE" != "available" ]]; then
    echo "FAIL: Transit Gateway state is '${TGW_STATE}'"
    exit 1
  fi
  echo "  Transit Gateway is available"
else
  echo "Skipping Transit Gateway (not enabled)"
fi

# --- RAM Share ---
if [[ "$RAM_SHARE_ARN" != "null" ]]; then
  echo "Checking RAM resource share..."
  RAM_STATUS=$(aws ram get-resource-shares --resource-share-arns "$RAM_SHARE_ARN" --resource-owner SELF --query 'resourceShares[0].status' --output text 2>/dev/null || echo "NOT_FOUND")
  if [[ "$RAM_STATUS" != "ACTIVE" ]]; then
    echo "FAIL: RAM share status is '${RAM_STATUS}'"
    exit 1
  fi
  echo "  RAM share is ACTIVE"
fi

# --- IPAM ---
if [[ "$IPAM_ID" != "null" ]]; then
  echo "Checking VPC IPAM..."
  IPAM_STATE=$(aws ec2 describe-ipams --ipam-ids "$IPAM_ID" --query 'Ipams[0].State' --output text 2>/dev/null || echo "NOT_FOUND")
  if [[ "$IPAM_STATE" == "NOT_FOUND" ]]; then
    echo "FAIL: IPAM '${IPAM_ID}' not found"
    exit 1
  fi
  echo "  IPAM exists (state: ${IPAM_STATE})"

  # Check sub-pools
  POOL_IDS=$(jq -r '.ipam_env_pool_ids.value // {} | to_entries[] | "\(.key) \(.value)"' outputs.json)
  if [[ -n "$POOL_IDS" ]]; then
    while IFS=' ' read -r POOL_NAME POOL_ID; do
      POOL_STATE=$(aws ec2 describe-ipam-pools --ipam-pool-ids "$POOL_ID" --query 'IpamPools[0].State' --output text 2>/dev/null || echo "NOT_FOUND")
      echo "  Pool ${POOL_NAME}: ${POOL_STATE}"
    done <<< "$POOL_IDS"
  fi
fi

# --- Route53 Resolver Endpoints ---
if [[ "$RESOLVER_INBOUND" != "null" ]]; then
  echo "Checking Route53 Resolver inbound endpoint..."
  INBOUND_STATUS=$(aws route53resolver get-resolver-endpoint --resolver-endpoint-id "$RESOLVER_INBOUND" --query 'ResolverEndpoint.Status' --output text 2>/dev/null || echo "NOT_FOUND")
  if [[ "$INBOUND_STATUS" != "OPERATIONAL" ]]; then
    echo "FAIL: Resolver inbound endpoint status is '${INBOUND_STATUS}'"
    exit 1
  fi
  echo "  Resolver inbound endpoint is OPERATIONAL"
fi

if [[ "$RESOLVER_OUTBOUND" != "null" ]]; then
  echo "Checking Route53 Resolver outbound endpoint..."
  OUTBOUND_STATUS=$(aws route53resolver get-resolver-endpoint --resolver-endpoint-id "$RESOLVER_OUTBOUND" --query 'ResolverEndpoint.Status' --output text 2>/dev/null || echo "NOT_FOUND")
  if [[ "$OUTBOUND_STATUS" != "OPERATIONAL" ]]; then
    echo "FAIL: Resolver outbound endpoint status is '${OUTBOUND_STATUS}'"
    exit 1
  fi
  echo "  Resolver outbound endpoint is OPERATIONAL"
fi

# --- Resolver Rules ---
echo "Checking resolver rules..."
RULES=$(jq -r '.resolver_rule_ids.value // {} | to_entries[] | "\(.key) \(.value)"' outputs.json)
if [[ -n "$RULES" ]]; then
  while IFS=' ' read -r RULE_NAME RULE_ID; do
    RULE_STATUS=$(aws route53resolver get-resolver-rule --resolver-rule-id "$RULE_ID" --query 'ResolverRule.Status' --output text 2>/dev/null || echo "NOT_FOUND")
    if [[ "$RULE_STATUS" != "COMPLETE" ]]; then
      echo "FAIL: resolver rule '${RULE_NAME}' status is '${RULE_STATUS}'"
      exit 1
    fi
    echo "  ${RULE_NAME}: COMPLETE"
  done <<< "$RULES"
else
  echo "  No resolver rules configured"
fi

echo "PASS: all org-networking checks passed"
