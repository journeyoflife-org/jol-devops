# JOL (Journey Of Life) DevOps Infrastructure

**8-Week Intensive DevOps Learning Program**

[![GDPR Compliant](https://img.shields.io/badge/GDPR-Compliant-green.svg)](docs/gdpr-compliance.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Overview

Production-ready infrastructure for:
- **Kubernetes cluster** (3-node, kubeadm) on Proxmox LXC
- **1C-Bitrix** self-hosted CMS
- **Bitrix24 Cloud** CRM integration
- **Cloudflare** protection (DDoS, WAF, caching)
- **GitHub Actions** CI/CD pipelines

## Architecture

```
80% Home Lab (Proxmox) ←→ Cloudflare Tunnel ←→ Internet
20% Google Cloud (Free Tier) for backup/DR
```

## Quick Start

```bash
# Clone repository
git clone https://github.com/jol-learner/jol-devops.git
cd jol-devops

# Follow week-by-week curriculum
cat docs/week-01-proxmox.md
```

## Hardware Requirements

| Component | Specification |
|-----------|---------------|
| CPU | AMD Ryzen 7 3700X (8 cores) |
| RAM | 64GB DDR4-3600 |
| GPU | 3x RX5500XT (optional, for ML) |
| Storage | 1TB NVMe SSD minimum |

## Compliance

- GDPR (EU/Lithuanian) compliant
- Data processing documentation included
- Audit logging enabled

## Directory Structure

```
jol-devops/
├── infrastructure/    # Proxmox, K8s, Cloudflare configs
├── apps/              # Bitrix, integrations
├── monitoring/        # Prometheus, Grafana
├── scripts/           # Automation scripts
└── docs/              # Week-by-week curriculum
```

## License

MIT License - See [LICENSE](LICENSE)

## Contact

- Domain: gyvenimo-kelias.lt
- Learner: JOL-learner
