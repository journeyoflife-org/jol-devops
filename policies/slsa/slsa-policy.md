# SLSA Policy — Supply-chain Levels for Software Artifacts

## Policy Statement

All container images produced by JOL must meet **SLSA Level 2** requirements before deployment to production.

## Requirements

### 1. Hosted Build Platform

- All builds MUST run on GitHub Actions (hosted runners).
- Self-hosted runners are NOT permitted for release builds.

### 2. Build Provenance

- Build provenance MUST be generated using `docker/build-push-action` with `provenance: true`.
- Provenance attestations MUST be pushed to the container registry alongside the image.

### 3. Cosign Keyless Signing

- All production images MUST be signed with `cosign` using **keyless (Fulcio/Sigstore)** signing.
- Signing MUST use the GitHub Actions OIDC token (`id-token: write` permission).
- The signing step MUST occur in the same workflow job as the build (no separate signing job).

### 4. Verification

Before deployment, images MUST be verified:

```bash
cosign verify \
  --certificate-identity-regexp="https://github.com/journeyoflife-org/.*" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/journeyoflife-org/<image>:<tag>
```

### 5. Exceptions

- Development/staging images MAY skip signing if explicitly documented.
- Emergency hotfixes MAY bypass signing with CTO approval (must be logged as an incident).

## Enforcement

- The `reusable/build.yml` workflow enforces this policy automatically.
- The `reusable/deploy.yml` workflow includes a verification gate before Helm upgrade.

## Review

This policy is reviewed annually by the security team.  
Last reviewed: 2026-01-15
