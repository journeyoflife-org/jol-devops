.DEFAULT_GOAL := help

SHELL := /bin/bash
.ONESHELL:

# ─── Variables ───────────────────────────────────────────────
REPO_ROOT := $(shell git rev-parse --show-toplevel)

# ─── Targets ─────────────────────────────────────────────────

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: pre-commit
pre-commit: ## Run pre-commit hooks on all files
	pre-commit run --all-files

.PHONY: lint-yaml
lint-yaml: ## Lint all YAML files
	yamllint -c .yamllint.yaml .

.PHONY: lint-shell
lint-shell: ## Lint all shell scripts
	find . -name '*.sh' -not -path './.venv/*' -exec shellcheck {} +

.PHONY: scan-secrets
scan-secrets: ## Run TruffleHog scan on repo
	trufflehog filesystem --directory . --fail

.PHONY: check-tools
check-tools: ## Verify required CLI tools are installed
	bash scripts/utils/check-tools.sh

.PHONY: validate-alerts
validate-alerts: ## Validate Prometheus alerting rules with promtool
	promtool check rules observability/alerting/rules/*.yml

.PHONY: collect-evidence
collect-evidence: ## Run SOC 2 evidence collection
	bash scripts/audit/collect-soc2-evidence.sh
