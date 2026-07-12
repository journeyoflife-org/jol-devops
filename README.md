# JOL-DevOps

Centralized DevOps platform for [Journey of Life](https://journeyoflife.org) — providing reusable CI/CD workflows, operational runbooks, observability configuration, security policies, and audit tooling.

## Repository Structure

```
jol-devops/
├── .github/          # GitHub configuration (CODEOWNERS, PR template, issue templates, CI workflows)
├── workflows/        # Reusable GitHub Actions workflows (consumed by ALL JOL repositories)
├── runbooks/         # Operational runbooks (incident response, deployment, on-call, security)
├── observability/    # Prometheus alerting rules, SLOs, silence templates
├── monitoring/       # Prometheus and Alertmanager configurations
├── policies/         # Security policies (SLSA, SBOM)
├── scripts/          # Automation scripts (tool checks, rollback, SOC 2 evidence, log archival)
└── docs/             # Architecture Decision Records, SLA policies, developer setup guides
```

## Quick Start

1. **Verify your environment**:
   ```bash
   make check-tools
   ```

2. **Install pre-commit hooks**:
   ```bash
   pre-commit install
   ```

3. **Run linting**:
   ```bash
   make lint-yaml
   make lint-shell
   ```

4. **Scan for secrets**:
   ```bash
   make scan-secrets
   ```

## Key Features

- **Reusable Workflows**: Docker build with SBOM + cosign signing (SLSA L2), security scanning, Helm deployment with approval gates, Slack/PagerDuty notifications
- **Observability**: Prometheus alerting rules (ServiceDown, HighErrorRate, BruteForce, CertExpiry, SLOBurn), SLO definitions (99.9% availability, p95 latency)
- **SOC 2 Compliance**: Automated evidence collection (CC7.1, CC8.1, CC6.1), 12-month log retention, quarterly compliance scans
- **Security**: TruffleHog secret scanning, cosign keyless image signing, pre-commit hooks with gitleaks

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines and review process.

## Security

See [SECURITY.md](SECURITY.md) for vulnerability reporting procedures.

## License

[MIT](LICENSE)
