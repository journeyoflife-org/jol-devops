# ADR-002: SLSA Level 2 with Cosign Keyless Signing

## Status

**Accepted** (2026-01-15)

## Context

Supply chain attacks are an increasing threat to open-source and internal software. JOL needed a mechanism to:

- **Prove** that container images were built by authorized CI pipelines
- **Detect** tampered or substituted images before deployment
- **Comply** with SOC 2 and emerging supply chain security standards

We evaluated SLSA (Supply-chain Levels for Software Artifacts) levels and signing mechanisms.

## Decision

We adopted **SLSA Level 2** using **cosign keyless (Fulcio/Sigstore)** signing.

### SLSA Level 2 Requirements

1. **Scripted build**: All builds run on GitHub Actions (hosted runners)
2. **Build service**: Build steps are defined in version-controlled workflow files
3. **Build as code**: Build definition and configuration are stored in source
4. **Hermetic builds**: Build process is reproducible (Docker BuildKit with SBOM)
5. **Provenance**: Build provenance is generated and attached to images

### Cosign Keyless Signing

- Uses **Sigstore Fulcio** for short-lived certificates tied to GitHub Actions OIDC identity
- No long-lived signing keys to manage or rotate
- Verification uses certificate identity + OIDC issuer matching
- Integrated into `reusable/build.yml` workflow

### Verification Command

```bash
cosign verify \
  --certificate-identity-regexp="https://github.com/journeyoflife-org/.*" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/journeyoflife-org/<image>:<tag>
```

## Consequences

### Positive
- No key management overhead (keyless = no keys to rotate or lose)
- Provenance and SBOM provide full supply chain visibility
- Aligns with industry best practices (Sigstore adoption is growing)
- Meets SLSA L2 requirements for supply chain integrity

### Negative
- Requires online verification (Fulcio transparency log must be reachable)
- Keyless certificates are short-lived (minutes) — historical verification requires Rekor log
- Developers unfamiliar with cosign/Sigstore have a learning curve

## Rejected Alternatives

### 1. Cosign with Long-Lived Key Pair
- **Why rejected**: Key management burden, risk of key compromise, key rotation complexity. Keyless eliminates all of these.

### 2. Docker Content Trust (Notary v1)
- **Why rejected**: Deprecated, complex to operate, poor GitHub Actions integration. Sigstore is the modern standard.

### 3. No Signing (Trust CI Only)
- **Why rejected**: CI-only trust doesn't protect against registry compromise or image substitution. Signing provides cryptographic proof of origin.

### 4. SLSA Level 3 (Hermetic + Non-Falsifiable Provenance)
- **Why rejected**: Excessive complexity for our current threat model. L2 provides sufficient integrity guarantees. Can upgrade to L3 if threat landscape changes.
