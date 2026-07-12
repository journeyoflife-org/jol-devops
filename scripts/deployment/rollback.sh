#!/usr/bin/env bash
# rollback.sh — Helm rollback with evidence logging
# Usage: bash scripts/deployment/rollback.sh <release-name> <namespace> [revision]

set -euo pipefail

RELEASE_NAME="${1:?Usage: rollback.sh <release-name> <namespace> [revision]}"
NAMESPACE="${2:?Usage: rollback.sh <release-name> <namespace> [revision]}"
REVISION="${3:-0}"  # 0 = rollback to previous revision

echo "═══════════════════════════════════════════"
echo " JOL Deployment Rollback"
echo " Release: ${RELEASE_NAME}"
echo " Namespace: ${NAMESPACE}"
echo " Target Revision: ${REVISION:-previous}"
echo "═══════════════════════════════════════════"
echo ""

# Pre-rollback: capture current state for evidence
echo "→ Capturing pre-rollback state..."
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EVIDENCE_FILE="/tmp/rollback-evidence-${RELEASE_NAME}-$(date +%s).txt"

{
  echo "Rollback Evidence — ${TIMESTAMP}"
  echo "Release: ${RELEASE_NAME}"
  echo "Namespace: ${NAMESPACE}"
  echo ""
  echo "=== Helm History ==="
  helm history "${RELEASE_NAME}" --namespace "${NAMESPACE}" 2>&1 || true
  echo ""
  echo "=== Current Pod Status ==="
  kubectl get pods -n "${NAMESPACE}" -l app.kubernetes.io/name="${RELEASE_NAME}" 2>&1 || true
} > "${EVIDENCE_FILE}"

echo "  Evidence saved to: ${EVIDENCE_FILE}"
echo ""

# Perform rollback
echo "→ Performing Helm rollback..."
if [[ "${REVISION}" -eq 0 ]]; then
  helm rollback "${RELEASE_NAME}" --namespace "${NAMESPACE}" --wait --timeout 5m
else
  helm rollback "${RELEASE_NAME}" "${REVISION}" --namespace "${NAMESPACE}" --wait --timeout 5m
fi

echo ""

# Post-rollback: verify status
echo "→ Verifying rollback..."
helm status "${RELEASE_NAME}" --namespace "${NAMESPACE}"

echo ""
echo "→ Rollout status:"
kubectl rollout status "deployment/${RELEASE_NAME}" \
  --namespace "${NAMESPACE}" --timeout=120s 2>/dev/null || true

echo ""
echo "═══════════════════════════════════════════"
echo " Rollback complete. Evidence: ${EVIDENCE_FILE}"
echo ""
echo " Next steps:"
echo "  1. Notify #jol-deploys of the rollback"
echo "  2. Investigate root cause"
echo "  3. Log evidence for SOC 2 audit (CC8.1)"
echo "═══════════════════════════════════════════"
