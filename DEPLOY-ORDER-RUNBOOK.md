# Zero-to-Production Deployment Order Runbook (New 7-Hour AWS Account)

This document describes the **exact execution order** required to recreate the entire architecture from scratch when the 7-hour AWS sandbox account expires. Following this sequence guarantees that all network dependencies (VPC/Subnets), the EKS cluster, the RDS PostgreSQL database, the identity stack (Samba 4 AD + FreeRADIUS MFA + Keycloak), code quality/security (SonarQube), observability (Prometheus + Grafana), and sample applications come up cleanly without conflicts.

---

## Provisioning Order Overview

```mermaid
flowchart TD
    S0["Phase 0: Preparation (Optional SQL Dump Backup + Update AWS Secrets in GitHub)"] --> S1
    S1["Phase 1: Base Infrastructure, EKS Cluster & Prometheus (cirobessa/kube-demo-2026)"] --> S2
    S2["Phase 2: Local Kubeconfig Setup (aws eks update-kubeconfig)"] --> S3
    S3["Phase 3: DevEx Platform, RDS, ArgoCD, Backstage, SonarQube & Grafana (cirodasilvaj/backstage-infra)"] --> S4
    S4["Phase 4: IAM / Active Directory Samba 4 + FreeRADIUS MFA + Keycloak in EKS VPC (cirodasilvaj/samba-ad-keycloak)"] --> S5
    S5["Phase 5: Demo Web Apps (Python & .NET C#) + QA & SonarQube CI/CD Pipeline (cirodasilvaj/apps-demo-2026)"]
```

---

## Phase 0 — Before the Old Account Expires (Optional) & Updating AWS Credentials

1. **(Optional — If the previous AWS account is still active)** Download the latest live PostgreSQL SQL dump from the Backstage endpoint:
   ```bash
   curl -u admin:Backstage@2026 \
     -o /home/ciro/backstate-infra/db/schema.sql \
     http://<BACKSTAGE_ELB_HOSTNAME>/backstage-rds-dump.sql
   ```

2. **Update the new AWS account credentials** (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION=us-east-1`) locally and in the GitHub Actions Secrets of the repositories:
   ```bash
   export AWS_ACCESS_KEY_ID="YOUR_NEW_ACCESS_KEY_ID"
   export AWS_SECRET_ACCESS_KEY="YOUR_NEW_SECRET_ACCESS_KEY"
   export AWS_REGION="us-east-1"

   # 1. Update secrets in the EKS Cluster repository (cirobessa account)
   gh auth switch -u cirobessa
   gh secret set AWS_ACCESS_KEY_ID -b "$AWS_ACCESS_KEY_ID" -R cirobessa/kube-demo-2026
   gh secret set AWS_SECRET_ACCESS_KEY -b "$AWS_SECRET_ACCESS_KEY" -R cirobessa/kube-demo-2026
   gh secret set AWS_REGION -b "$AWS_REGION" -R cirobessa/kube-demo-2026

   # 2. Update secrets in the Platform and IAM repositories (cirodasilvaj account)
   gh auth switch -u cirodasilvaj
   for repo in cirodasilvaj/backstage-infra cirodasilvaj/samba-ad-keycloak; do
     gh secret set AWS_ACCESS_KEY_ID -b "$AWS_ACCESS_KEY_ID" -R "$repo"
     gh secret set AWS_SECRET_ACCESS_KEY -b "$AWS_SECRET_ACCESS_KEY" -R "$repo"
     gh secret set AWS_REGION -b "$AWS_REGION" -R "$repo"
   done
   ```

---

## Phase 1 — Base Infrastructure: VPC, Subnets, EKS Cluster, and Prometheus (`cirobessa/kube-demo-2026`)

```bash
gh auth switch -u cirobessa
gh workflow run eks.yml -R cirobessa/kube-demo-2026 -f action=apply
```

---

## Phase 2 — Configure Local `kubectl`

```bash
aws eks update-kubeconfig --name kube-demo-eks --region us-east-1
kubectl get nodes
```

---

## Phase 3 — DevEx Platform, RDS Database, ArgoCD, SonarQube, and Grafana (`cirodasilvaj/backstage-infra`)

```bash
gh auth switch -u cirodasilvaj
gh workflow run terraform.yml -R cirodasilvaj/backstage-infra -f action=apply
```

> **Note on Route 53 DNS Delegation:**
> Phase 3 automatically auto-discovers the ephemeral lab's Route 53 public hosted zone (`*realhandsonlabs.net`) via `terraform/dns.tf` and delegates friendly CNAME records:
> - `http://backstage.<lab-id>.realhandsonlabs.net`
> - `http://grafana.<lab-id>.realhandsonlabs.net`
> - `http://argocd.<lab-id>.realhandsonlabs.net`
> - `http://sonarqube.<lab-id>.realhandsonlabs.net`
> All URLs and credentials are automatically printed in the GitHub Actions Step Summary.


---

## Phase 4 — Active Directory (Samba 4 Multi-DC), FreeRADIUS MFA, and Keycloak (`cirodasilvaj/samba-ad-keycloak`)

```bash
gh auth switch -u cirodasilvaj
gh workflow run deploy.yml -R cirodasilvaj/samba-ad-keycloak -f action=apply
```

> **Note on Route 53 DNS & VPC Integration:**
> - Provisions EC2 instances (`samba_dc1`, `samba_dc2`, `keycloak`) directly inside the **EKS cluster VPC private subnets**.
> - Auto-discovers the lab's Route 53 hosted zone and registers:
>   - `ldap://ad.<lab-id>.realhandsonlabs.net:389` (Round-Robin DC1 & DC2)
>   - `http://sso.<lab-id>.realhandsonlabs.net` / `http://keycloak.<lab-id>.realhandsonlabs.net`
>   - `radius.<lab-id>.realhandsonlabs.net:1812` (MFA)
> - Outputs complete DNS connection strings and summary in the GitHub Actions step.

---

## Phase 5 — Demo Web Applications (Python & .NET C#) and QA/SonarQube CI/CD Pipeline (`cirodasilvaj/apps-demo-2026`)

```bash
gh auth switch -u cirodasilvaj
gh workflow run build.yml -R cirodasilvaj/apps-demo-2026
```

> **Note on Route 53 DNS & Backstage Integration:**
> - Builds and deploys the Python Flask & .NET 8 C# sample microservices to EKS.
> - Auto-discovers the lab's Route 53 zone and assigns friendly CNAME records:
>   - `http://python.<lab-id>.realhandsonlabs.net`
>   - `http://dotnet.<lab-id>.realhandsonlabs.net`
> - Automatically displays live URLs in the Step Summary and catalogs them in Backstage.

