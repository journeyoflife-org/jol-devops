# Secret Exposure Response Runbook

> **Time Target**: Revoke the exposed credential within **15 minutes** of discovery.

## Overview

This runbook follows: **Revoke → Rotate → Roll → Preserve Evidence**.

---

## Phase 1: Revoke (0–15 min)

1. **Identify** the exposed secret type and location:
   - Git commit with hardcoded credential
   - CI/CD log output
   - Slack message / documentation
   - Public repository exposure

2. **Revoke immediately** — do NOT wait for rotation:

   | Secret Type          | Revocation Method                                  |
   |----------------------|----------------------------------------------------|
   | GitHub PAT           | GitHub Settings → Developer Settings → Revoke token |
   | AWS Access Key       | IAM Console → Delete access key                    |
   | Kubernetes Secret    | `kubectl delete secret <name> -n <ns>`            |
   | Database password    | Change password in DB directly                     |
   | SSH key              | Remove from `~/.ssh/authorized_keys` on target     |
   | OAuth token          | Revoke via provider's token management page        |

3. **Verify revocation**: attempt to use the revoked credential — it must fail.

## Phase 2: Rotate (15–60 min)

1. Generate a new credential of the same type.
2. Update the credential in all dependent systems:
   - GitHub repository secrets
   - Kubernetes secrets (recreate, not patch)
   - External secret stores (Vault, AWS Secrets Manager)
3. Deploy the updated secrets:
   ```bash
   kubectl create secret generic <name> \
     --from-literal=key=<new-value> \
     --namespace=<ns> --dry-run=client -o yaml | kubectl apply -f -
   ```
4. Restart affected deployments to pick up new secrets:
   ```bash
   kubectl rollout restart deployment/<name> -n <ns>
   ```

## Phase 3: Roll (60 min–4 hrs)

1. Remove the exposed secret from Git history (if committed):
   ```bash
   # Use BFG Repo-Cleaner or git filter-repo
   git filter-repo --invert-paths --path <file-with-secret>
   git push --force --all
   ```
2. Notify all repository contributors to re-clone.
3. Verify TruffleHog no longer flags the secret in the cleaned history.

## Phase 4: Preserve Evidence

1. Capture the following for SOC 2 audit trail (CC6.1, CC7.2):
   - Screenshot or copy of the exposed secret location
   - Timestamp of discovery
   - Timestamp of revocation
   - List of systems potentially accessed using the exposed secret
   - Git commit SHA (if applicable)

2. File an incident report using the `runbook-gap` issue template if the exposure was due to a process gap.

---

**SOC 2 Compliance**: All secret exposure events must be documented and retained for audit (CC6.1 Logical Access Controls).
