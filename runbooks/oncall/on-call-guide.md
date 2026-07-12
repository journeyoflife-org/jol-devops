# On-Call Guide

> JOL on-call rotation is managed via PagerDuty.  
> This guide covers escalation paths and common troubleshooting procedures.

## Escalation Path

| Level | Role                  | Contact Method       | Response SLA |
|-------|-----------------------|----------------------|--------------|
| L1    | On-call SRE           | PagerDuty rotation   | 15 min       |
| L2    | Senior SRE / Team Lead| PagerDuty escalation | 30 min       |
| L3    | VP Engineering        | Phone call           | 60 min       |

## On-Call Handoff Checklist

- [ ] Review all open incidents from the previous shift
- [ ] Check PagerDuty for scheduled maintenance windows
- [ ] Confirm all alerting rules are active: `promtool check rules`
- [ ] Review Grafana dashboards for anomalies

## Common Issues

| Symptom                              | Likely Cause                 | Resolution                                  |
|--------------------------------------|------------------------------|---------------------------------------------|
| Pod CrashLoopBackOff                 | Config error, missing secret | Check logs: `kubectl logs <pod> -p`         |
| 502 Bad Gateway                      | Ingress misconfiguration     | Verify ingress: `kubectl get ingress -A`    |
| High memory usage                    | Resource limits too low      | Check HPA/VPA: `kubectl top pods -n <ns>`  |
| Certificate expiry alert             | Cert not auto-renewed        | Check cert-manager: `kubectl get cert -A`   |
| Database connection timeout          | Connection pool exhaustion   | Check DB metrics in Grafana                 |
| Disk space alert (PVC > 80%)         | Log accumulation             | Trigger log archival: `scripts/maintenance/log-archive.sh` |

## Useful Commands

```bash
# Check all non-running pods
kubectl get pods -A --field-selector=status.phase!=Running

# Check recent events
kubectl get events -A --sort-by='.lastTimestamp' | tail -20

# Check resource usage
kubectl top pods -A | sort -k3 -rn | head -20

# Restart a deployment (last resort)
kubectl rollout restart deployment/<name> -n <namespace>
```

## Escalation Rules

1. **Auto-escalate to L2** if incident is not acknowledged within 15 minutes.
2. **Auto-escalate to L3** if P1 is not mitigated within 60 minutes.
3. **Notify security team immediately** for any suspected breach or unauthorized access.

---

**Note**: On-call engineers have authority to roll back any deployment without prior approval during P1 incidents.
