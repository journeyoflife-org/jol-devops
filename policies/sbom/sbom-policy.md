# SBOM Policy — Software Bill of Materials

## Policy Statement

All container images produced by JOL MUST include a Software Bill of Materials (SBOM) in a recognized standard format.

## Requirements

### 1. Format

SBOMs MUST be generated in one of the following formats:
- **CycloneDX** (preferred, JSON format)
- **SPDX** (JSON format)

### 2. Generation

- SBOMs MUST be generated during the Docker build step using `docker/build-push-action` with `sbom: true`.
- SBOMs MUST be attached to the container image in the registry as an OCI artifact.

### 3. Vulnerability Scanning

- All SBOMs MUST be scanned with **Trivy** for known vulnerabilities (CVEs).
- Images with **critical or high severity** CVEs MUST be blocked from deployment.
- Scanning is automated in `reusable/build.yml` and `reusable/security-scan.yml`.

### 4. Retention

- SBOMs MUST be retained for a minimum of **24 months** in the container registry.
- SBOMs associated with production deployments MUST be retained for the lifetime of the deployment plus 24 months.

### 5. Audit Access

- SBOMs MUST be accessible to the security team and auditors on demand.
- Quarterly SOC 2 evidence collection (`scripts/audit/collect-soc2-evidence.sh`) MUST include SBOM exports.

## Enforcement

- The `reusable/build.yml` workflow generates and attaches SBOMs automatically.
- The `reusable/security-scan.yml` workflow runs Trivy vulnerability scanning.
- Deployments with unresolved critical CVEs are blocked by the deploy workflow gate.

## Review

This policy is reviewed annually by the security team.  
Last reviewed: 2026-01-15
