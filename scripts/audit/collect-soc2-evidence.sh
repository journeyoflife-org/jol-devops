#!/usr/bin/env bash
# collect-soc2-evidence.sh — Quarterly SOC 2 artifact collection
# Covers: CC7.1 (System Operations), CC8.1 (Change Management), CC6.1 (Access Controls)
# Usage: bash scripts/audit/collect-soc2-evidence.sh

set -euo pipefail

OUTPUT_DIR="${1:-./soc2-evidence-$(date +%Y%m%d)}"
mkdir -p "${OUTPUT_DIR}"

echo "═══════════════════════════════════════════"
echo " SOC 2 Evidence Collection"
echo " Output: ${OUTPUT_DIR}"
echo " Date: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "═══════════════════════════════════════════"
echo ""

# ─── CC7.1: System Operations Monitoring ─────────────────────
echo "→ CC7.1: Collecting system operations evidence..."

CC71_DIR="${OUTPUT_DIR}/CC7.1-system-operations"
mkdir -p "${CC71_DIR}"

# Prometheus alerting rules
echo "  Exporting alerting rules..."
cp observability/alerting/rules/*.yml "${CC71_DIR}/" 2>/dev/null || echo "  (no alerting rules found)"

# SLO definitions
echo "  Exporting SLO definitions..."
cp observability/slos/*.yaml "${CC71_DIR}/" 2>/dev/null || echo "  (no SLO definitions found)"

# Alertmanager config
echo "  Exporting Alertmanager config..."
cp monitoring/alertmanager/alertmanager.yaml "${CC71_DIR}/" 2>/dev/null || echo "  (no Alertmanager config found)"

# Prometheus config
echo "  Exporting Prometheus config..."
cp monitoring/prometheus/prometheus.yaml "${CC71_DIR}/" 2>/dev/null || echo "  (no Prometheus config found)"

echo ""

# ─── CC8.1: Change Management ────────────────────────────────
echo "→ CC8.1: Collecting change management evidence..."

CC81_DIR="${OUTPUT_DIR}/CC8.1-change-management"
mkdir -p "${CC81_DIR}"

# GitHub Actions workflow definitions
echo "  Exporting CI/CD workflow definitions..."
cp .github/workflows/*.yml "${CC81_DIR}/" 2>/dev/null || echo "  (no workflows found)"
cp workflows/reusable/*.yml "${CC81_DIR}/" 2>/dev/null || echo "  (no reusable workflows found)"

# CODEOWNERS
echo "  Exporting CODEOWNERS..."
cp .github/CODEOWNERS "${CC81_DIR}/" 2>/dev/null || echo "  (no CODEOWNERS found)"

# PR template
echo "  Exporting PR template..."
cp .github/PULL_REQUEST_TEMPLATE.md "${CC81_DIR}/" 2>/dev/null || echo "  (no PR template found)"

echo ""

# ─── CC6.1: Logical and Physical Access Controls ─────────────
echo "→ CC6.1: Collecting access control evidence..."

CC61_DIR="${OUTPUT_DIR}/CC6.1-access-controls"
mkdir -p "${CC61_DIR}"

# Security policies
echo "  Exporting security policies..."
cp SECURITY.md "${CC61_DIR}/" 2>/dev/null || echo "  (no SECURITY.md found)"
cp policies/slsa/slsa-policy.md "${CC61_DIR}/" 2>/dev/null || echo "  (no SLSA policy found)"
cp policies/sbom/sbom-policy.md "${CC61_DIR}/" 2>/dev/null || echo "  (no SBOM policy found)"

# Pre-commit config (secret detection)
echo "  Exporting pre-commit config..."
cp .pre-commit-config.yaml "${CC61_DIR}/" 2>/dev/null || echo "  (no pre-commit config found)"

echo ""

# ─── Summary ─────────────────────────────────────────────────
echo "═══════════════════════════════════════════"
echo " Evidence collection complete."
echo " Output: ${OUTPUT_DIR}"
echo ""
echo " Contents:"
find "${OUTPUT_DIR}" -type f | sort
echo "═══════════════════════════════════════════"
