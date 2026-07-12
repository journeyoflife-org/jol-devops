# Contributing to JOL-DevOps

Thank you for your interest in contributing to Journey of Life's DevOps platform.

## How to Contribute

1. **Fork** the repository (external contributors) or create a feature branch.
2. **Branch naming**: `feat/<short-description>`, `fix/<short-description>`, `chore/<short-description>`.
3. **Commit messages**: follow [Conventional Commits](https://www.conventionalcommits.org/).
4. **Open a Pull Request** against `main` and fill out the PR template.

## Development Prerequisites

Run `scripts/utils/check-tools.sh` to verify your environment has:
- `git` ≥ 2.40
- `docker` ≥ 24.x
- `kubectl` ≥ 1.29
- `helm` ≥ 3.14
- `cosign` ≥ 2.2
- `qodana` CLI

## Code Standards

- YAML: validated with `yamllint` (see `.yamllint.yaml`)
- Shell: validated with `shellcheck`
- Python: validated with Qodana + `ruff`
- All secrets must be scanned with TruffleHog before merge

## Review Process

- All PRs require **1 approval** from a CODEOWNER.
- PRs touching `workflows/reusable/` or `policies/` require **security-review** approval.
- CI must pass (TruffleHog, yamllint, shellcheck, Qodana) before merge.

## Code of Conduct

Be respectful. We are a mission-driven non-profit building technology for communities.
