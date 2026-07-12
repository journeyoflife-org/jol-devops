# P1 Incident Response Runbook

> **Severity**: P1 — Service outage affecting end users or SOC 2 controlled systems.

## Overview

This runbook follows the **Contain → Notify → Assess → DPA Notify → Recover → RCA** sequence.

---

## Phase 1: Contain

**Goal**: Stop the bleeding. Limit blast radius.

1. Identify the affected service/namespace:
   ```bash
   kubectl get pods -A --field-selector=status.phase!=Running
   ```
2. If caused by a recent deployment, roll back:
   ```bash
   bash scripts/deployment/rollback.sh <release-name> <namespace>
   ```
3. If security incident (unauthorized access, data leak), isolate the affected namespace:
   ```bash
   kubectl create networkpolicy isolate --namespace=<ns> --dry-run=client -o yaml | kubectl apply -f -
   ```
4. Preserve evidence: capture logs, metrics screenshots, and current pod state.

## Phase 2: Notify

**Goal**: Get the right people on the bridge.

| Action                             | Method                          | SLA         |
|------------------------------------|----------------------------------|-------------|
| Open PagerDuty incident            | Trigger `P1-INCIDENT` service    | Immediate   |
| Notify `#jol-incidents` Slack      | Automated via PagerDuty→Slack    | < 5 min    |
| Page on-call SRE                   | PagerDuty rotation               | < 10 min   |
| Notify Engineering Lead            | Direct Slack / phone call        | < 15 min   |

## Phase 3: Assess

**Goal**: Determine root cause and impact scope.

1. Check Prometheus alerts: `https://prometheus.jol.internal/alerts`
2. Check Grafana dashboards: `https://grafana.jol.internal/d/jol-platform`
3. Review recent deployments:
   ```bash
   helm history <release-name> --namespace=<ns>
   ```
4. Identify affected users/services and estimate impact duration.

## Phase 4: DPA Notify (if applicable)

**Trigger**: If incident involves personal data (PII, health data, donor information).

1. Notify the **Data Protection Officer** (DPO) immediately.
2. Log the breach details: timestamp, data categories, affected individuals count.
3. DPO determines if supervisory authority notification is required (72-hour window).
4. Document everything in the incident ticket — this is a legal requirement under GDPR.

## Phase 5: Recover

**Goal**: Restore service to normal operation.

1. Apply the fix (patch, config change, rollback).
2. Verify recovery:
   ```bash
   kubectl rollout status deployment/<name> --namespace=<ns>
   ```
3. Monitor for 30 minutes post-recovery to confirm stability.
4. Close the PagerDuty incident and notify `#jol-incidents` of resolution.

## Phase 6: RCA (Root Cause Analysis)

**Goal**: Prevent recurrence.

1. Schedule RCA meeting within **5 business days**.
2. Document:
   - Timeline of events (UTC timestamps)
   - Root cause
   - Contributing factors
   - Action items with owners and deadlines
3. Publish RCA in `docs/postmortems/` (or linked issue tracker).
4. Update this runbook if any steps were unclear or missing.

---

**SOC 2 Evidence**: Incident timeline, containment actions, and RCA must be retained for audit evidence (CC7.2).
