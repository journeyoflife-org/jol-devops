#!/usr/bin/env bash
# check-tools.sh — Verify required CLI tools are installed
# Usage: bash scripts/utils/check-tools.sh

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS=0
FAIL=0

_check_tool() {
  local tool="$1"
  local min_version="${2:-}"

  if command -v "$tool" &>/dev/null; then
    local version
    version=$("$tool" --version 2>/dev/null | head -1 || echo "unknown")
    if [[ -n "$min_version" ]]; then
      echo -e "${GREEN}✓${NC} ${tool} — ${version} (min: ${min_version})"
    else
      echo -e "${GREEN}✓${NC} ${tool} — ${version}"
    fi
    PASS=$((PASS + 1))
  else
    if [[ -n "$min_version" ]]; then
      echo -e "${RED}✗${NC} ${tool} — NOT FOUND (min: ${min_version})"
    else
      echo -e "${RED}✗${NC} ${tool} — NOT FOUND"
    fi
    FAIL=$((FAIL + 1))
  fi
}

echo "═══════════════════════════════════════════"
echo " JOL DevOps — Tool Verification"
echo "═══════════════════════════════════════════"
echo ""

_check_tool "git" "2.40"
_check_tool "docker" "24.x"
_check_tool "kubectl" "1.29"
_check_tool "helm" "3.14"
_check_tool "cosign" "2.2"
_check_tool "qodana" "latest"
_check_tool "yamllint" "1.35"
_check_tool "shellcheck" "0.10"
_check_tool "trufflehog" "latest"
_check_tool "promtool" "2.53"
_check_tool "pre-commit" "latest"

echo ""
echo "═══════════════════════════════════════════"
echo -e " Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}"
echo "═══════════════════════════════════════════"

if [[ "$FAIL" -gt 0 ]]; then
  echo ""
  echo -e "${YELLOW}Install missing tools and re-run this script.${NC}"
  exit 1
fi
