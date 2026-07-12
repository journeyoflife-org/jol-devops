# Log Retention Policy

> SOC 2 Type II Compliance — 12-Month Minimum Retention

## Overview

This policy defines log retention requirements for all JOL platform services to satisfy SOC 2 Trust Service Criteria.

## Retention Schedule

| Log Category                  | Retention Period | Storage Location           | Encryption    | SOC 2 Criterion |
|-------------------------------|------------------|---------------------------|---------------|-----------------|
| Application logs              | 12 months        | Loki → S3 (KMS)          | AES-256 (KMS) | CC7.1           |
| Kubernetes audit logs         | 12 months        | S3 (KMS)                 | AES-256 (KMS) | CC7.1, CC6.1    |
| CI/CD pipeline logs           | 12 months        | GitHub Actions (native)   | GitHub-managed| CC8.1           |
| Authentication/access logs    | 12 months        | Loki → S3 (KMS)          | AES-256 (KMS) | CC6.1           |
| Incident response records     | 36 months        | Issue tracker + S3        | AES-256 (KMS) | CC7.2           |
| Change management records     | 36 months        | GitHub PRs + commits      | GitHub-managed| CC8.1           |
| SBOM artifacts                | 24 months        | GHCR (OCI artifacts)      | Registry-managed| CC6.1         |
| Security scan results         | 24 months        | GitHub Security tab       | GitHub-managed| CC6.1           |

## Storage Architecture

```
Logs → Loki (hot storage, 30 days) → S3 (cold storage, 12 months, KMS encrypted)
```

- **Hot storage** (Loki): last 30 days, indexed for fast querying
- **Cold storage** (S3): 30 days – 12 months, compressed archives with KMS encryption
- **Long-term** (S3 Glacier): >12 months for incident and change management records

## Access Controls

- Log archives in S3 are accessible only to:
  - SRE team (read)
  - Security team (read)
  - Compliance/audit role (read)
- Write access to S3 log buckets is restricted to the log archival service account.
- All access to log archives is logged (CloudTrail / S3 access logging).

## Archival Process

Log archival is performed by `scripts/maintenance/log-archive.sh`:
1. Export logs from Loki for the specified time range
2. Compress and encrypt with KMS
3. Upload to S3 with retention metadata
4. Verify upload integrity

## Deletion

- Logs past their retention period are automatically deleted by S3 lifecycle policies.
- Manual deletion requires approval from the compliance team.
- Deletion events are logged for audit trail.

## Review

This policy is reviewed annually by the compliance team.  
Last reviewed: 2026-01-15
