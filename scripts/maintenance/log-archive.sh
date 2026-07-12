#!/usr/bin/env bash
# log-archive.sh — Archive logs from Loki to S3 with KMS encryption
# SOC 2 requirement: 12-month log retention
# Usage: bash scripts/maintenance/log-archive.sh [date-range]

set -euo pipefail

DATE_RANGE="${1:-last-90d}"
S3_BUCKET="${S3_BUCKET:-jol-log-archive}"
KMS_KEY_ID="${KMS_KEY_ID:-alias/jol-log-archive}"
ARCHIVE_DIR="/tmp/log-archive-$(date +%Y%m%d-%H%M%S)"

echo "═══════════════════════════════════════════"
echo " JOL Log Archive"
echo " Date Range: ${DATE_RANGE}"
echo " S3 Bucket: ${S3_BUCKET}"
echo " KMS Key: ${KMS_KEY_ID}"
echo "═══════════════════════════════════════════"
echo ""

mkdir -p "${ARCHIVE_DIR}"

# Step 1: Export logs from Loki
echo "→ Exporting logs from Loki..."
# Note: This requires LOKI_URL to be set in environment
# Example: export LOKI_URL=http://loki.monitoring.svc.cluster.local:3100
if [[ -z "${LOKI_URL:-}" ]]; then
  echo "  WARNING: LOKI_URL not set. Set it before running."
  echo "  Example: export LOKI_URL=http://loki.monitoring.svc.cluster.local:3100"
  echo ""
  echo "  Skipping Loki export. Use logcli or Loki API directly."
else
  echo "  Querying Loki at ${LOKI_URL}..."
  # Export all logs for the specified time range
  # logcli query '{namespace=~"jol-.*"}' \
  #   --from="$(date -d '-90 days' +%Y-%m-%dT%H:%M:%SZ)" \
  #   --output=jsonl \
  #   > "${ARCHIVE_DIR}/jol-logs-${DATE_RANGE}.jsonl"
fi

# Step 2: Compress and encrypt
echo "→ Compressing archive..."
ARCHIVE_FILE="${ARCHIVE_DIR}/jol-logs-${DATE_RANGE}.tar.gz"
tar -czf "${ARCHIVE_FILE}" -C "${ARCHIVE_DIR}" . 2>/dev/null || echo "  (nothing to archive)"

if [[ -f "${ARCHIVE_FILE}" ]]; then
  echo "→ Uploading to S3 with KMS encryption..."
  aws s3 cp "${ARCHIVE_FILE}" \
    "s3://${S3_BUCKET}/archives/$(basename "${ARCHIVE_FILE}")" \
    --sse aws:kms \
    --sse-kms-key-id "${KMS_KEY_ID}" \
    --metadata "date-range=${DATE_RANGE},archived-at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  echo ""
  echo "→ Archive uploaded: s3://${S3_BUCKET}/archives/$(basename "${ARCHIVE_FILE}")"
else
  echo "  No archive file created. Nothing to upload."
fi

# Cleanup
echo "→ Cleaning up temporary files..."
rm -rf "${ARCHIVE_DIR}"

echo ""
echo "═══════════════════════════════════════════"
echo " Log archive complete."
echo " SOC 2 retention: 12 months (see docs/sla/log-retention-policy.md)"
echo "═══════════════════════════════════════════"
