# ADR-001: Centralized Reusable Workflow Library

## Status

**Accepted** (2026-01-15)

## Context

JOL operates multiple repositories across the `journeyoflife-org` organization. Each repository previously maintained its own CI/CD workflows, leading to:

- **Inconsistent** build, scan, and deploy processes across services
- **Duplicated** effort maintaining the same workflow logic in multiple repos
- **Difficulty enforcing** security policies (cosign signing, TruffleHog scanning) uniformly
- **Slow onboarding** of new services due to copy-paste workflow setup

## Decision

We created a **centralized reusable workflow library** in `JOL-DevOps/workflows/reusable/`:

| Workflow            | Purpose                                          |
|---------------------|--------------------------------------------------|
| `build.yml`         | Docker build → GHCR + SBOM + cosign sign (SLSA L2) |
| `security-scan.yml` | TruffleHog + pip-audit + npm audit               |
| `deploy.yml`        | Helm upgrade + GitHub Environment approval gate  |
| `notify.yml`        | Slack/PagerDuty on deploy/incident               |

All JOL repositories consume these workflows via `workflow_call`.

## Consequences

### Positive
- Single source of truth for CI/CD processes
- Security policy enforcement is automatic (cosign, TruffleHog)
- New services onboard by referencing reusable workflows, not duplicating
- Changes to security scanning propagate to all consumers immediately

### Negative
- Breaking changes to reusable workflows affect ALL consumers
- Requires careful versioning and backward compatibility testing
- PR review for `workflows/reusable/` has higher stakes (CODEOWNERS enforces security-review)

### Mitigation
- Backward compatibility checklist in PR template
- Downstream impact notification via Slack `#jol-deploys`
- `workflow_dispatch` testing before merge

## Rejected Alternatives

### 1. Composite Actions Instead of Reusable Workflows
- **Why rejected**: Composite actions cannot define their own `on:` triggers, limiting flexibility. Reusable workflows support environment protection rules and approval gates natively.

### 2. Each Repo Maintains Own Workflows
- **Why rejected**: Unmanageable at scale. Security policy drift is unacceptable for SOC 2 compliance.

### 3. Third-party Workflow Marketplace (e.g., CircleCI Orbs)
- **Why rejected**: We standardize on GitHub Actions for the entire pipeline. Adding external dependencies increases supply chain risk.
