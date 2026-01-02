# JOL (Journey Of Life) DevOps Learning Curriculum
## 8-Week Intensive Program for Compliance-Driven Infrastructure

**Version:** 1.0  
**Target:** Intermediate Linux learner (50+, career pivot)  
**Compliance Framework:** GDPR (EU/Lithuanian)  
**Branding:** JOL-learner  

---

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Hardware Architecture](#hardware-architecture)
3. [Week-by-Week Syllabus](#week-by-week-syllabus)
4. [Daily Task Breakdown](#daily-task-breakdown)
5. [GitHub Repository Structure](#github-repository-structure)
6. [AI Prompts for Each Module](#ai-prompts-for-each-module)
7. [Compliance Checklists](#compliance-checklists)
8. [Troubleshooting Guide](#troubleshooting-guide)

---

## Executive Summary

### What You Will Build
By Week 8, you will have:
- **Production Kubernetes cluster** (3-node) on Proxmox LXC
- **Cloudflare-protected domain** with DDoS protection
- **Self-hosted 1C-Bitrix** CMS with GDPR compliance
- **Bitrix24 Cloud** integration with your infrastructure
- **CI/CD pipeline** via GitHub Actions
- **Monitoring stack** (Prometheus + Grafana)
- **GPU-accelerated ML workloads** (optional)

### Your Infrastructure Map
```
┌─────────────────────────────────────────────────────────────────┐
│                    INTERNET                                      │
│                        │                                         │
│                   Cloudflare                                     │
│              (DDoS, Cache, WAF)                                  │
│                        │                                         │
├─────────────────────────────────────────────────────────────────┤
│                 HOME LAB (80%)                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  PRIMARY SERVER (Ryzen 7 3700X, 64GB, 3x RX5500XT)      │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │    │
│  │  │ Proxmox VE  │  │ K8s Master  │  │ K8s Worker1 │      │    │
│  │  │   (Host)    │  │   (LXC)     │  │   (LXC)     │      │    │
│  │  └─────────────┘  └─────────────┘  └─────────────┘      │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │    │
│  │  │ K8s Worker2 │  │  1C-Bitrix  │  │  Monitoring │      │    │
│  │  │   (LXC)     │  │   (LXC)     │  │   (LXC)     │      │    │
│  │  └─────────────┘  └─────────────┘  └─────────────┘      │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  SECONDARY SERVER (Intel i5, 16GB) - Test/Staging       │    │
│  │  ┌─────────────┐  ┌─────────────┐                       │    │
│  │  │  Ubuntu     │  │   Staging   │                       │    │
│  │  │  Server     │  │   K8s Node  │                       │    │
│  │  └─────────────┘  └─────────────┘                       │    │
│  └─────────────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────────────┤
│                 CLOUD (20% - Free Tier)                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │ Google Cloud │  │  Bitrix24    │  │   GitHub     │           │
│  │  (Backup,    │  │   Cloud      │  │   Actions    │           │
│  │   DR, API)   │  │   (CRM)      │  │   (CI/CD)    │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
└─────────────────────────────────────────────────────────────────┘
```

---

## Hardware Architecture

### Primary Server Setup (AlmaLinux 9.6 → Proxmox)

#### Step 1.1: Why We Replace AlmaLinux with Proxmox
**Current state:** You have AlmaLinux 9.6 installed  
**Target state:** Proxmox VE 8.x as hypervisor  

**Reason:** Proxmox provides:
- Web-based VM/LXC management
- Built-in backup system
- Cluster capability
- Better resource isolation for Kubernetes

#### Step 1.2: Backup Before Destruction
```bash
# On your current AlmaLinux, backup any existing data
sudo tar -czvf /tmp/home-backup.tar.gz /home/
sudo tar -czvf /tmp/etc-backup.tar.gz /etc/

# Copy to USB drive
sudo mount /dev/sdb1 /mnt/usb
sudo cp /tmp/*.tar.gz /mnt/usb/
sudo umount /mnt/usb
```

#### Step 1.3: Proxmox Installation
1. Download Proxmox VE ISO from https://www.proxmox.com/en/downloads
2. Create bootable USB with Rufus (Windows) or `dd` (Linux)
3. Boot from USB, select "Install Proxmox VE"
4. **Critical settings:**
   - Filesystem: ZFS (RAID-Z1 if multiple disks, or single disk)
   - Hostname: `pve-jol-master.local`
   - IP: Static (e.g., 192.168.1.100/24)
   - Gateway: Your router IP
   - DNS: 8.8.8.8, 1.1.1.1

#### Step 1.4: Post-Installation Proxmox Configuration
```bash
# SSH into Proxmox
ssh root@192.168.1.100

# Update repositories (remove enterprise repo, add no-subscription)
sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list

# Update system
apt update && apt full-upgrade -y

# Install useful tools
apt install -y vim htop iotop net-tools curl wget git
```

### Secondary Server Setup (Intel i5 → Ubuntu Server)

#### Step 1.5: Ubuntu Server Installation
1. Download Ubuntu Server 22.04 LTS
2. Install with minimal configuration
3. **Network:** Static IP 192.168.1.101/24
4. **Hostname:** `jol-staging`
5. Enable SSH during installation

---

## Week-by-Week Syllabus

### WEEK 1: Foundation & Proxmox Mastery
**Goal:** Fully operational Proxmox with LXC containers ready for Kubernetes

| Day | Hours | Topic | Hands-On Lab |
|-----|-------|-------|--------------|
| 1 | 8h | Proxmox installation & network config | Install Proxmox, configure bridges |
| 2 | 8h | LXC fundamentals | Create 5 LXC containers |
| 3 | 8h | Storage configuration | ZFS pools, NFS shares |
| 4 | 8h | Backup & restore | Configure backup schedules |
| 5 | 8h | Networking deep-dive | VLANs, bridges, firewall |
| 6 | 8h | Templates & automation | Create AlmaLinux LXC template |
| 7 | 8h | Review & troubleshooting | Fix common issues |

#### Day 1 Detailed Breakdown

**Hour 1-2: Network Planning**
Before touching hardware, document your network:
```
Network Plan:
- Router IP: 192.168.1.1
- Proxmox Host: 192.168.1.100
- K8s Master: 192.168.1.110
- K8s Worker1: 192.168.1.111
- K8s Worker2: 192.168.1.112
- 1C-Bitrix: 192.168.1.120
- Monitoring: 192.168.1.130
- Reserved for DHCP: 192.168.1.200-254
```

**Hour 3-4: Proxmox Installation**
Follow Step 1.3 above. Take screenshots at each step.

**Hour 5-6: Web Interface Exploration**
1. Open browser: `https://192.168.1.100:8006`
2. Login as root
3. Explore: Datacenter → Storage → Network
4. **Screenshot each section** for your documentation

**Hour 7-8: First LXC Container**
```bash
# Download AlmaLinux template
pveam update
pveam available | grep alma
pveam download local almalinux-9-default_20230615_amd64.tar.xz

# Create container via GUI:
# Datacenter → pve-jol-master → Create CT
# - CT ID: 110
# - Hostname: k8s-master
# - Template: almalinux-9
# - Disk: 32GB
# - CPU: 4 cores
# - Memory: 8192 MB
# - Network: vmbr0, Static IP 192.168.1.110/24
```

---

### WEEK 2: Kubernetes Fundamentals (kubeadm)
**Goal:** 3-node Kubernetes cluster operational

| Day | Hours | Topic | Hands-On Lab |
|-----|-------|-------|--------------|
| 1 | 8h | Container runtime (containerd) | Install on all nodes |
| 2 | 8h | kubeadm installation | Prepare all nodes |
| 3 | 8h | Cluster initialization | Initialize master, join workers |
| 4 | 8h | kubectl mastery | Deploy first applications |
| 5 | 8h | Networking (Calico) | CNI configuration |
| 6 | 8h | Storage (Longhorn) | Persistent volumes |
| 7 | 8h | Review & troubleshooting | Debug cluster issues |

#### Day 3 Detailed: Cluster Initialization

**Hour 1-2: Pre-flight Checks (ALL NODES)**
```bash
# Disable swap (Kubernetes requirement)
swapoff -a
sed -i '/swap/d' /etc/fstab

# Load kernel modules
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

# Sysctl settings
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

# Disable SELinux (or configure properly)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```

**Hour 3-4: Install kubeadm, kubelet, kubectl (ALL NODES)**
```bash
# Add Kubernetes repo
cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
EOF

# Install
dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet
```

**Hour 5-6: Initialize Master Node**
```bash
# On k8s-master (192.168.1.110) ONLY
kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address=192.168.1.110 \
  --control-plane-endpoint=192.168.1.110

# SAVE THE JOIN COMMAND OUTPUT!
# It looks like:
# kubeadm join 192.168.1.110:6443 --token xxx --discovery-token-ca-cert-hash sha256:xxx

# Configure kubectl for root user
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```

**Hour 7-8: Join Worker Nodes**
```bash
# On k8s-worker1 and k8s-worker2
kubeadm join 192.168.1.110:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

# Verify on master
kubectl get nodes
# Expected output:
# NAME          STATUS     ROLES           AGE   VERSION
# k8s-master    NotReady   control-plane   5m    v1.29.x
# k8s-worker1   NotReady   <none>          2m    v1.29.x
# k8s-worker2   NotReady   <none>          1m    v1.29.x
```

---

### WEEK 3: Kubernetes Operations & Security
**Goal:** Production-ready cluster with RBAC and network policies

| Day | Hours | Topic | Hands-On Lab |
|-----|-------|-------|--------------|
| 1 | 8h | RBAC fundamentals | Create roles, service accounts |
| 2 | 8h | Network policies | Implement zero-trust networking |
| 3 | 8h | Secrets management | External secrets, sealed secrets |
| 4 | 8h | Pod security standards | Configure PSS/PSA |
| 5 | 8h | Resource quotas & limits | Namespace isolation |
| 6 | 8h | Ingress (NGINX) | SSL termination setup |
| 7 | 8h | Review & GDPR audit | Compliance checklist |

#### GDPR Compliance Checklist for Kubernetes

```markdown
## GDPR Kubernetes Compliance Audit

### Data Processing (Article 5)
- [ ] All PII stored in encrypted PersistentVolumes
- [ ] Secrets encrypted at rest (etcd encryption)
- [ ] Network policies restrict PII access to authorized pods only
- [ ] Audit logging enabled for all PII access

### Data Subject Rights (Articles 15-22)
- [ ] Mechanism to export user data (right to portability)
- [ ] Mechanism to delete user data (right to erasure)
- [ ] Data retention policies implemented via CronJobs

### Security (Article 32)
- [ ] TLS everywhere (service mesh or ingress)
- [ ] RBAC configured with least privilege
- [ ] Pod Security Standards enforced
- [ ] Container images scanned for vulnerabilities
- [ ] Network segmentation via NetworkPolicies

### Breach Notification (Article 33)
- [ ] Alerting configured for security events
- [ ] Incident response runbook documented
- [ ] 72-hour notification process defined
```

---

### WEEK 4: Cloudflare Integration & Networking
**Goal:** Secure external access with DDoS protection

| Day | Hours | Topic | Hands-On Lab |
|-----|-------|-------|--------------|
| 1 | 8h | Cloudflare account & DNS | Transfer gyvenimo-kelias.lt |
| 2 | 8h | Cloudflare Tunnel (Zero Trust) | Secure home lab exposure |
| 3 | 8h | WAF rules | GDPR-compliant blocking |
| 4 | 8h | Page rules & caching | Optimize performance |
| 5 | 8h | Cloudflare Workers | Edge computing basics |
| 6 | 8h | DDoS protection config | Attack simulation |
| 7 | 8h | Review & testing | End-to-end validation |

#### Day 2 Detailed: Cloudflare Tunnel Setup

**Why Cloudflare Tunnel (not port forwarding)?**
- No exposed ports on home router
- No need for static IP
- Built-in DDoS protection
- Zero Trust access control
- GDPR-compliant (EU data centers)

**Hour 1-2: Install cloudflared**
```bash
# On Proxmox host or dedicated LXC
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared
chmod +x /usr/local/bin/cloudflared

# Authenticate
cloudflared tunnel login
# This opens browser - login to Cloudflare dashboard
```

**Hour 3-4: Create Tunnel**
```bash
# Create tunnel
cloudflared tunnel create jol-homelab

# This creates credentials file at:
# ~/.cloudflared/<TUNNEL_ID>.json

# Create config file
cat <<EOF > ~/.cloudflared/config.yml
tunnel: <TUNNEL_ID>
credentials-file: /root/.cloudflared/<TUNNEL_ID>.json

ingress:
  # Kubernetes Dashboard
  - hostname: k8s.gyvenimo-kelias.lt
    service: https://192.168.1.110:6443
    originRequest:
      noTLSVerify: true
  
  # 1C-Bitrix (will configure in Week 6)
  - hostname: bitrix.gyvenimo-kelias.lt
    service: http://192.168.1.120:80
  
  # Grafana monitoring
  - hostname: monitor.gyvenimo-kelias.lt
    service: http://192.168.1.130:3000
  
  # Catch-all
  - service: http_status:404
EOF
```

**Hour 5-6: DNS Configuration**
```bash
# Route DNS to tunnel
cloudflared tunnel route dns jol-homelab k8s.gyvenimo-kelias.lt
cloudflared tunnel route dns jol-homelab bitrix.gyvenimo-kelias.lt
cloudflared tunnel route dns jol-homelab monitor.gyvenimo-kelias.lt
```

**Hour 7-8: Run as Service**
```bash
# Install as systemd service
cloudflared service install

# Start tunnel
systemctl enable cloudflared
systemctl start cloudflared

# Verify
cloudflared tunnel info jol-homelab
```

---

### WEEK 5: CI/CD with GitHub Actions
**Goal:** Automated deployment pipeline

| Day | Hours | Topic | Hands-On Lab |
|-----|-------|-------|--------------|
| 1 | 8h | Git fundamentals | Repository structure |
| 2 | 8h | GitHub Actions basics | First workflow |
| 3 | 8h | Docker builds | Multi-stage Dockerfiles |
| 4 | 8h | Kubernetes deployments | GitOps with manifests |
| 5 | 8h | Secrets in CI/CD | GitHub Secrets, SOPS |
| 6 | 8h | Testing in pipeline | Unit, integration tests |
| 7 | 8h | Review & optimization | Pipeline performance |

#### GitHub Actions Workflow for Kubernetes

```yaml
# .github/workflows/deploy-to-k8s.yml
name: Deploy to JOL Kubernetes

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      
      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
  
  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      
      - name: Install kubectl
        uses: azure/setup-kubectl@v3
      
      - name: Configure kubectl
        run: |
          mkdir -p ~/.kube
          echo "${{ secrets.KUBECONFIG }}" | base64 -d > ~/.kube/config
      
      - name: Deploy to Kubernetes
        run: |
          kubectl set image deployment/app \
            app=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }} \
            -n production
          kubectl rollout status deployment/app -n production
```

---

### WEEK 6: 1C-Bitrix Self-Hosted Installation
**Goal:** GDPR-compliant CMS on Kubernetes

| Day | Hours | Topic | Hands-On Lab |
|-----|-------|-------|--------------|
| 1 | 8h | 1C-Bitrix architecture | Understanding components |
| 2 | 8h | MySQL/MariaDB setup | Database on K8s |
| 3 | 8h | Bitrix installation | Docker container build |
| 4 | 8h | Bitrix configuration | Site wizard, modules |
| 5 | 8h | GDPR compliance | Cookie consent, data handling |
| 6 | 8h | Backup & restore | Automated backups |
| 7 | 8h | Performance tuning | Caching, optimization |

#### Day 3 Detailed: Bitrix Docker Installation

**Hour 1-2: Create Bitrix Dockerfile**
```dockerfile
# bitrix/Dockerfile
FROM php:8.1-apache

# Install required PHP extensions
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libonig-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        mysqli \
        pdo_mysql \
        opcache \
        zip \
        intl \
        soap \
        mbstring

# PHP configuration for Bitrix
RUN echo "short_open_tag = On" >> /usr/local/etc/php/conf.d/bitrix.ini \
    && echo "mbstring.func_overload = 0" >> /usr/local/etc/php/conf.d/bitrix.ini \
    && echo "max_input_vars = 10000" >> /usr/local/etc/php/conf.d/bitrix.ini \
    && echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/bitrix.ini \
    && echo "upload_max_filesize = 100M" >> /usr/local/etc/php/conf.d/bitrix.ini \
    && echo "post_max_size = 100M" >> /usr/local/etc/php/conf.d/bitrix.ini

# Enable Apache modules
RUN a2enmod rewrite headers

WORKDIR /var/www/html

# Download Bitrix (trial version for learning)
# For production, use licensed version
RUN curl -o bitrixsetup.php https://www.1c-bitrix.ru/download/scripts/bitrixsetup.php

EXPOSE 80
```

**Hour 3-4: Kubernetes Manifests**
```yaml
# bitrix/k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: bitrix
  labels:
    name: bitrix
    gdpr-compliant: "true"

---
# bitrix/k8s/mysql-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
  namespace: bitrix
type: Opaque
stringData:
  MYSQL_ROOT_PASSWORD: "ChangeMe!Secure123"
  MYSQL_DATABASE: "bitrix"
  MYSQL_USER: "bitrix"
  MYSQL_PASSWORD: "BitrixSecure!456"

---
# bitrix/k8s/mysql-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  namespace: bitrix
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:8.0
          envFrom:
            - secretRef:
                name: mysql-secret
          ports:
            - containerPort: 3306
          volumeMounts:
            - name: mysql-data
              mountPath: /var/lib/mysql
      volumes:
        - name: mysql-data
          persistentVolumeClaim:
            claimName: mysql-pvc

---
# bitrix/k8s/bitrix-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bitrix
  namespace: bitrix
spec:
  replicas: 2
  selector:
    matchLabels:
      app: bitrix
  template:
    metadata:
      labels:
        app: bitrix
    spec:
      containers:
        - name: bitrix
          image: ghcr.io/jol-learner/bitrix:latest
          ports:
            - containerPort: 80
          volumeMounts:
            - name: bitrix-data
              mountPath: /var/www/html
          env:
            - name: DB_HOST
              value: "mysql"
            - name: DB_NAME
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: MYSQL_DATABASE
            - name: DB_USER
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: MYSQL_USER
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: MYSQL_PASSWORD
      volumes:
        - name: bitrix-data
          persistentVolumeClaim:
            claimName: bitrix-pvc
```

**Hour 5-6: GDPR Configuration for Bitrix**
```php
<?php
// bitrix/gdpr-config.php
// Add to /var/www/html/bitrix/.settings.php

return [
    'cookies' => [
        'value' => [
            // GDPR-compliant cookie settings
            'secure' => true,
            'httponly' => true,
            'samesite' => 'Strict',
        ],
    ],
    'session' => [
        'value' => [
            'lifetime' => 3600, // 1 hour session
            'cookie_secure' => true,
            'cookie_httponly' => true,
            'cookie_samesite' => 'Strict',
        ],
    ],
];
```

---

### WEEK 7: Bitrix24 Cloud Integration
**Goal:** Connect cloud CRM with self-hosted infrastructure

| Day | Hours | Topic | Hands-On Lab |
|-----|-------|-------|--------------|
| 1 | 8h | Bitrix24 account setup | Free plan configuration |
| 2 | 8h | REST API fundamentals | Authentication, endpoints |
| 3 | 8h | Webhook integration | Event-driven architecture |
| 4 | 8h | CRM module | Leads, contacts, deals |
| 5 | 8h | Bitrix24 + K8s integration | API gateway setup |
| 6 | 8h | Data sync | 1C-Bitrix ↔ Bitrix24 |
| 7 | 8h | GDPR compliance | Data processing agreements |

#### Bitrix24 REST API Integration

```python
# bitrix24/api_client.py
"""
Bitrix24 REST API Client for JOL Infrastructure
GDPR-Compliant Implementation
"""

import requests
from typing import Dict, Any, Optional
from datetime import datetime
import hashlib
import hmac

class Bitrix24Client:
    """
    Secure Bitrix24 API client with GDPR logging
    """
    
    def __init__(self, webhook_url: str, gdpr_log_path: str = "/var/log/bitrix24_gdpr.log"):
        self.webhook_url = webhook_url.rstrip('/')
        self.gdpr_log_path = gdpr_log_path
    
    def _log_gdpr_access(self, method: str, endpoint: str, contains_pii: bool):
        """Log all API calls for GDPR audit trail"""
        log_entry = {
            "timestamp": datetime.utcnow().isoformat(),
            "method": method,
            "endpoint": endpoint,
            "contains_pii": contains_pii,
            "source": "jol-infrastructure"
        }
        with open(self.gdpr_log_path, 'a') as f:
            f.write(f"{log_entry}\n")
    
    def call(self, method: str, params: Optional[Dict[str, Any]] = None) -> Dict:
        """
        Make API call to Bitrix24
        
        Example:
            client.call('crm.lead.list', {'filter': {'STATUS_ID': 'NEW'}})
        """
        url = f"{self.webhook_url}/{method}"
        
        # Determine if this call involves PII
        pii_methods = ['crm.contact', 'crm.lead', 'user.get', 'user.search']
        contains_pii = any(m in method for m in pii_methods)
        
        self._log_gdpr_access("POST", method, contains_pii)
        
        response = requests.post(url, json=params or {})
        response.raise_for_status()
        
        return response.json()
    
    # CRM Methods
    def get_leads(self, filters: Optional[Dict] = None) -> Dict:
        """Get CRM leads with optional filters"""
        return self.call('crm.lead.list', {'filter': filters or {}})
    
    def create_lead(self, data: Dict) -> Dict:
        """Create new CRM lead"""
        return self.call('crm.lead.add', {'fields': data})
    
    def get_contacts(self, filters: Optional[Dict] = None) -> Dict:
        """Get contacts (PII - logged for GDPR)"""
        return self.call('crm.contact.list', {'filter': filters or {}})
    
    # GDPR Compliance Methods
    def export_user_data(self, user_id: int) -> Dict:
        """Export all user data for GDPR portability request"""
        data = {
            'leads': self.call('crm.lead.list', {'filter': {'ASSIGNED_BY_ID': user_id}}),
            'contacts': self.call('crm.contact.list', {'filter': {'ASSIGNED_BY_ID': user_id}}),
            'deals': self.call('crm.deal.list', {'filter': {'ASSIGNED_BY_ID': user_id}}),
        }
        return data
    
    def delete_user_data(self, user_id: int) -> bool:
        """Delete user data for GDPR erasure request"""
        # This is a placeholder - implement according to your data retention policy
        self._log_gdpr_access("DELETE", f"user_data/{user_id}", True)
        return True


# Usage Example
if __name__ == "__main__":
    # Your Bitrix24 webhook URL (get from Bitrix24 admin panel)
    WEBHOOK_URL = "https://your-domain.bitrix24.com/rest/1/your-webhook-token"
    
    client = Bitrix24Client(WEBHOOK_URL)
    
    # Create a lead
    new_lead = client.create_lead({
        'TITLE': 'New Lead from JOL Infrastructure',
        'NAME': 'Test',
        'PHONE': [{'VALUE': '+370123456789', 'VALUE_TYPE': 'WORK'}],
    })
    print(f"Created lead: {new_lead}")
```

---

### WEEK 8: Monitoring, GPU & Final Integration
**Goal:** Complete production-ready infrastructure

| Day | Hours | Topic | Hands-On Lab |
|-----|-------|-------|--------------|
| 1 | 8h | Prometheus setup | Metrics collection |
| 2 | 8h | Grafana dashboards | Visualization |
| 3 | 8h | Alerting | PagerDuty/Slack integration |
| 4 | 8h | GPU passthrough | RX5500XT to K8s pods |
| 5 | 8h | ML workload example | TensorFlow/PyTorch |
| 6 | 8h | Final integration testing | End-to-end validation |
| 7 | 8h | Documentation & handoff | Complete all docs |

#### GPU Passthrough Configuration

**Why GPU in Kubernetes?**
Your 3x RX5500XT GPUs can be used for:
- Machine learning inference
- Video transcoding
- Rendering workloads

**Step-by-Step GPU Passthrough**

```bash
# 1. On Proxmox host, identify GPUs
lspci | grep VGA
# Output: 
# 0b:00.0 VGA compatible controller: AMD/ATI Navi 14 [Radeon RX 5500/5500M]
# 0c:00.0 VGA compatible controller: AMD/ATI Navi 14 [Radeon RX 5500/5500M]
# 0d:00.0 VGA compatible controller: AMD/ATI Navi 14 [Radeon RX 5500/5500M]

# 2. Enable IOMMU in GRUB
nano /etc/default/grub
# Add to GRUB_CMDLINE_LINUX_DEFAULT:
# amd_iommu=on iommu=pt

update-grub
reboot

# 3. Verify IOMMU groups
find /sys/kernel/iommu_groups/ -type l

# 4. Blacklist AMD GPU driver on host
echo "blacklist amdgpu" >> /etc/modprobe.d/blacklist.conf
echo "blacklist radeon" >> /etc/modprobe.d/blacklist.conf

# 5. Load VFIO modules
echo "vfio" >> /etc/modules
echo "vfio_iommu_type1" >> /etc/modules
echo "vfio_pci" >> /etc/modules

# 6. Bind GPU to VFIO
echo "options vfio-pci ids=1002:7340,1002:ab38" > /etc/modprobe.d/vfio.conf

reboot
```

---

## GitHub Repository Structure

```
jol-devops/
├── README.md
├── LICENSE (MIT)
├── .github/
│   └── workflows/
│       ├── build-bitrix.yml
│       ├── deploy-k8s.yml
│       └── security-scan.yml
├── docs/
│   ├── week-01-proxmox.md
│   ├── week-02-kubernetes.md
│   ├── week-03-security.md
│   ├── week-04-cloudflare.md
│   ├── week-05-cicd.md
│   ├── week-06-bitrix.md
│   ├── week-07-bitrix24.md
│   ├── week-08-monitoring.md
│   └── gdpr-compliance.md
├── infrastructure/
│   ├── proxmox/
│   │   ├── lxc-templates/
│   │   └── scripts/
│   ├── kubernetes/
│   │   ├── base/
│   │   │   ├── namespaces.yaml
│   │   │   ├── rbac.yaml
│   │   │   └── network-policies.yaml
│   │   ├── apps/
│   │   │   ├── bitrix/
│   │   │   ├── monitoring/
│   │   │   └── ingress/
│   │   └── overlays/
│   │       ├── production/
│   │       └── staging/
│   └── cloudflare/
│       ├── tunnel-config.yml
│       └── waf-rules.json
├── apps/
│   ├── bitrix/
│   │   ├── Dockerfile
│   │   ├── docker-compose.yml
│   │   └── k8s/
│   └── bitrix24-integration/
│       ├── api_client.py
│       └── requirements.txt
├── monitoring/
│   ├── prometheus/
│   │   └── prometheus.yml
│   ├── grafana/
│   │   └── dashboards/
│   └── alertmanager/
│       └── alertmanager.yml
├── scripts/
│   ├── setup-proxmox.sh
│   ├── setup-k8s-node.sh
│   ├── backup-cluster.sh
│   └── gdpr-data-export.sh
└── tests/
    ├── integration/
    └── compliance/
        └── gdpr-audit.sh
```

---

## AI Prompts for Each Module

### Master Prompt (Use Daily)
```
You are a paranoid compliance-driven DevOps architect helping a 50-year-old 
intermediate Linux learner build production infrastructure.

Current context:
- Week: [1-8]
- Day: [1-7]
- Topic: [specific topic]
- Hardware: Proxmox on Ryzen 7 3700X (64GB RAM, 3x RX5500XT)
- Compliance: GDPR (Lithuanian/EU)
- Domain: gyvenimo-kelias.lt

Requirements:
1. Explain each step as if teaching someone who needs to learn fast
2. Include exact commands to copy-paste
3. Highlight security implications
4. Note GDPR compliance requirements
5. Provide verification steps after each action
6. Suggest troubleshooting for common errors

Today's task: [describe what you're working on]
```

### Week 1 Prompt: Proxmox
```
Help me set up Proxmox VE for a production home lab. I'm installing on:
- Asus ROG Crosshair VIII Hero
- AMD Ryzen 7 3700X
- 64GB DDR4-3600
- 3x RX5500XT GPUs (for future ML workloads)

Goals:
1. Install Proxmox VE 8.x
2. Configure ZFS storage
3. Set up network bridges for Kubernetes LXC containers
4. Prepare GPU passthrough (don't enable yet)

Provide step-by-step with exact commands. Explain what each command does.
I'm 50 and need to learn fast.
```

### Week 2 Prompt: Kubernetes
```
Help me set up a 3-node Kubernetes cluster using kubeadm on Proxmox LXC containers.

Environment:
- Proxmox VE 8.x (already running)
- LXC containers with AlmaLinux 9
- Network: 192.168.1.110-112
- Container runtime: containerd

I need:
1. Pre-flight checks for all nodes
2. kubeadm installation
3. Master initialization with specific pod CIDR
4. Worker join process
5. CNI (Calico) installation
6. Verification that cluster is healthy

Explain why each step matters. I'm building production infrastructure.
```

### Week 6 Prompt: 1C-Bitrix
```
Help me deploy 1C-Bitrix CMS on my Kubernetes cluster with GDPR compliance.

Requirements:
1. Dockerfile for Bitrix with all PHP extensions
2. MySQL 8.0 deployment on Kubernetes
3. Persistent volumes for data
4. Kubernetes secrets for credentials
5. Ingress configuration for bitrix.gyvenimo-kelias.lt
6. GDPR-compliant cookie and session settings
7. Backup CronJob

I'm in Lithuania (EU) so GDPR compliance is mandatory.
Explain each configuration choice.
```

---

## Compliance Checklists

### Pre-Deployment GDPR Checklist

```markdown
## GDPR Compliance Pre-Deployment Audit
### JOL Infrastructure - gyvenimo-kelias.lt

**Auditor:** JOL-learner
**Date:** ____________
**Environment:** Production / Staging

---

### 1. Data Inventory (Article 30)
- [ ] All personal data processing activities documented
- [ ] Data flow diagram created and reviewed
- [ ] Third-party processors identified (Cloudflare, Bitrix24 Cloud)
- [ ] Data Processing Agreements (DPAs) signed with all processors

### 2. Legal Basis (Article 6)
- [ ] Consent mechanism implemented for cookies
- [ ] Privacy policy published at /privacy
- [ ] Cookie banner with granular controls
- [ ] Legitimate interest assessment documented (if applicable)

### 3. Data Subject Rights (Articles 15-22)
- [ ] Data export functionality tested (Article 20)
- [ ] Data deletion functionality tested (Article 17)
- [ ] Access request workflow documented (Article 15)
- [ ] Rectification process documented (Article 16)

### 4. Security Measures (Article 32)
- [ ] TLS 1.3 enforced on all endpoints
- [ ] Encryption at rest enabled (etcd, databases)
- [ ] Access logs retained for 90 days minimum
- [ ] Penetration test scheduled/completed
- [ ] Vulnerability scanning automated in CI/CD

### 5. Breach Response (Articles 33-34)
- [ ] Incident response plan documented
- [ ] 72-hour notification process tested
- [ ] Contact information for Lithuanian DPA recorded:
      State Data Protection Inspectorate
      Address: A. Juozapavičiaus g. 6, LT-09310 Vilnius
      Email: ada@ada.lt
      Phone: +370 5 279 1445

### 6. Infrastructure Specific
- [ ] Cloudflare configured with EU-only data centers
- [ ] Bitrix24 DPA obtained from vendor
- [ ] Kubernetes audit logs enabled
- [ ] Pod security policies enforced
- [ ] Network policies restrict PII access

---

**Sign-off:**
Name: ________________________
Date: ________________________
```

---

## Troubleshooting Guide

### Common Issues & Solutions

#### Proxmox

**Problem:** LXC container won't start with nesting enabled
```bash
# Solution: Enable nesting features
pct set <CTID> -features nesting=1,keyctl=1
```

**Problem:** ZFS pool shows degraded
```bash
# Check status
zpool status
# Replace failed disk
zpool replace <pool> <old-disk> <new-disk>
```

#### Kubernetes

**Problem:** Nodes show NotReady status
```bash
# Check kubelet logs
journalctl -u kubelet -f

# Common fix: Install CNI
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
```

**Problem:** Pods stuck in Pending
```bash
# Check events
kubectl describe pod <pod-name>

# Common causes:
# - Insufficient resources → Add nodes or reduce requests
# - PVC not bound → Check storage class
# - Node selector mismatch → Check labels
```

#### Cloudflare Tunnel

**Problem:** Tunnel shows disconnected
```bash
# Check tunnel status
cloudflared tunnel info <tunnel-name>

# Restart service
systemctl restart cloudflared

# Check logs
journalctl -u cloudflared -f
```

#### 1C-Bitrix

**Problem:** Bitrix shows "MySQL connection error"
```bash
# Check MySQL pod
kubectl logs -n bitrix deployment/mysql

# Verify secrets
kubectl get secret mysql-secret -n bitrix -o yaml

# Test connection from Bitrix pod
kubectl exec -it -n bitrix deployment/bitrix -- mysql -h mysql -u bitrix -p
```

---

## Daily Progress Tracker

```markdown
## JOL Daily Log

### Week ___ Day ___
**Date:** ____________
**Topic:** ____________

#### Morning (4 hours)
- [ ] Review yesterday's notes
- [ ] Complete theory section
- [ ] Start hands-on lab

**Notes:**


#### Afternoon (4 hours)
- [ ] Complete hands-on lab
- [ ] Troubleshoot issues
- [ ] Document learnings
- [ ] Prepare tomorrow's materials

**Notes:**


#### Blockers:


#### Tomorrow's Plan:


#### GDPR Notes (if applicable):

```

---

## Quick Reference Commands

```bash
# Proxmox
pct list                          # List containers
pct start/stop <CTID>             # Start/stop container
qm list                           # List VMs
pveum user list                   # List users

# Kubernetes
kubectl get nodes -o wide         # Node status
kubectl get pods -A               # All pods
kubectl logs <pod> -f             # Follow logs
kubectl exec -it <pod> -- bash    # Shell into pod
kubectl apply -f <file>           # Apply manifest
kubectl delete -f <file>          # Delete resources

# Cloudflare
cloudflared tunnel list           # List tunnels
cloudflared tunnel info <name>    # Tunnel details
cloudflared tunnel run <name>     # Start tunnel

# Git
git add -A && git commit -m "msg" # Stage and commit
git push origin main              # Push to remote
git pull origin main              # Pull latest

# Docker
docker build -t <name> .          # Build image
docker push <registry>/<name>     # Push to registry
docker logs <container> -f        # Follow logs
```

---

**End of JOL DevOps Curriculum v1.0**

*Created for JOL-learner | GDPR Compliant | Lithuanian/EU Jurisdiction*
