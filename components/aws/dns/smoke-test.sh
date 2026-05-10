#!/usr/bin/env bash
set -euo pipefail

# Parse outputs
HOSTED_ZONE_ID=$(jq -r '.hosted_zone_id.value // ""' outputs.json)
DOMAIN_NAME=$(jq -r '.domain_name.value' outputs.json)

# --- Primary Hosted Zone ---
if [[ -n "$HOSTED_ZONE_ID" ]]; then
  echo "Checking primary hosted zone '${DOMAIN_NAME}' (${HOSTED_ZONE_ID})..."
  ZONE_NAME=$(aws route53 get-hosted-zone --id "$HOSTED_ZONE_ID" --query 'HostedZone.Name' --output text 2>/dev/null || echo "NOT_FOUND")
  if [[ "$ZONE_NAME" == "NOT_FOUND" ]]; then
    echo "FAIL: hosted zone ${HOSTED_ZONE_ID} not found"
    exit 1
  fi
  echo "  Primary zone exists: ${ZONE_NAME}"

  # Check NS records are present
  NS_COUNT=$(aws route53 list-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --query "ResourceRecordSets[?Type=='NS'] | length(@)" --output text)
  echo "  NS record sets: ${NS_COUNT}"
else
  echo "Skipping primary hosted zone (not configured)"
fi

# --- Subdomain Zones ---
echo "Checking subdomain zones..."
SUBDOMAIN_ZONES=$(jq -r '.subdomain_zone_ids.value // {} | to_entries[] | "\(.key) \(.value)"' outputs.json)
if [[ -n "$SUBDOMAIN_ZONES" ]]; then
  while IFS=' ' read -r PREFIX ZONE_ID; do
    ZONE_NAME=$(aws route53 get-hosted-zone --id "$ZONE_ID" --query 'HostedZone.Name' --output text 2>/dev/null || echo "NOT_FOUND")
    if [[ "$ZONE_NAME" == "NOT_FOUND" ]]; then
      echo "FAIL: subdomain zone '${PREFIX}' (${ZONE_ID}) not found"
      exit 1
    fi
    echo "  ${PREFIX}: zone exists (${ZONE_NAME})"
  done <<< "$SUBDOMAIN_ZONES"
else
  echo "  No subdomain zones configured"
fi

# --- ACM Certificates ---
echo "Checking ACM certificates..."
CERT_ARNS=$(jq -r '.acm_certificate_arns.value // {} | to_entries[] | "\(.key) \(.value)"' outputs.json)
if [[ -n "$CERT_ARNS" ]]; then
  while IFS=' ' read -r CERT_KEY CERT_ARN; do
    CERT_STATUS=$(aws acm describe-certificate --certificate-arn "$CERT_ARN" --query 'Certificate.Status' --output text 2>/dev/null || echo "NOT_FOUND")
    if [[ "$CERT_STATUS" == "NOT_FOUND" ]]; then
      echo "FAIL: ACM certificate '${CERT_KEY}' not found"
      exit 1
    fi
    echo "  ${CERT_KEY}: ${CERT_STATUS}"
  done <<< "$CERT_ARNS"
else
  echo "  No ACM certificates configured"
fi

echo "PASS: all dns checks passed"
