# Production Deployment Runbook

> All production deployments are performed exclusively via CI (GitHub Actions).
> Manual `kubectl apply` or `helm upgrade` to production is **forbidden** outside P1 rollback.

## Pre-Deploy Checklist

- [ ] All CI checks pass on `main` (TruffleHog, yamllint, shellcheck, Qodana)
- [ ] Change has been approved via PR review
- [ ] Helm chart version is incremented (if applicable)
- [ ] Docker image is built, signed (cosign), and pushed to GHCR
- [ ] GitHub Environment `production` approval gate is configured
- [ ] Rollback plan is documented in PR description
- [ ] On-call SRE is aware of the deployment

## Deployment Procedure (CI-Only)

1. Merge the approved PR to `main`.
2. GitHub Actions triggers the `reusable/deploy.yml` workflow.
3. Wait for the **production environment approval** from a designated approver.
4. Monitor the deployment:
   ```bash
   kubectl rollout status deployment/<release-name> \
     --namespace=<namespace> --timeout=300s
   ```
5. Verify the deployment in Grafana: check error rate, latency, and availability.

## Rollback Procedure

If issues are detected post-deploy:

1. **Immediate rollback**:
   ```bash
   bash scripts/deployment/rollback.sh <release-name> <namespace>
   ```
2. Verify rollback:
   ```bash
   kubectl rollout status deployment/<release-name> --namespace=<namespace>
   ```
3. Notify `#jol-deploys` channel of the rollback.
4. Open a `pipeline-failure` issue if the rollback was due to a CI/CD defect.
5. Log evidence for SOC 2 audit (CC8.1 Change Management):
   - What was deployed
   - Why it was rolled back
   - Duration of impact

## Post-Deploy Verification

- [ ] Health check endpoints return 200
- [ ] Error rate is within normal range (check Grafana)
- [ ] No new critical alerts in Alertmanager
- [ ] SLO burn rate is acceptable

---

**SOC 2 Evidence**: All deployments must leave an auditable trail in GitHub Actions history (CC8.1).
