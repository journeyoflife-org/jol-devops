# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Full repository structure: reusable workflows, runbooks, observability, monitoring, policies, docs
- Reusable GitHub Actions workflows (build, security-scan, deploy, notify)
- Incident response runbook (P1)
- SOC 2 evidence collection scripts (CC7.1, CC8.1, CC6.1)
- Prometheus alerting rules and Alertmanager routing
- SLO definitions (99.9% availability, p95 latency)
- SLSA L2 policy and SBOM policy
- ADR-001 (reusable workflows) and ADR-002 (SLSA cosign keyless)
- Weekly compliance workflow with full-history TruffleHog scan
- Qodana static analysis integration
- Pre-commit hooks configuration

### Changed
- Migrated from single `deploy-k8s.yml` to modular CI + reusable workflow architecture

### Security
- Added TruffleHog secret scanning to all PRs
- Added cosign keyless image signing (SLSA L2)
