# Enterprise IAM: Active Directory, FreeRADIUS MFA & Keycloak SSO

This document describes the identity, directory services, multi-factor authentication, and single sign-on (SSO) architecture implemented in [`cirodasilvaj/samba-ad-keycloak`](https://github.com/cirodasilvaj/samba-ad-keycloak), deployed directly inside the EKS cluster VPC.

---

## 1. Identity Architecture Overview

The enterprise identity layer establishes a multi-tenant authentication and authorization infrastructure adhering to zero-trust principles:

```mermaid
flowchart TD
    subgraph VPC["EKS Cluster VPC (10.0.0.0/16)"]
        subgraph PRIVATE_SUBNET["Private Subnet (10.0.10.0/24)"]
            subgraph SAMBA["Samba 4 Active Directory Multi-DC"]
                DC1["samba_dc1 (EC2)\nIP: 10.0.10.50\nPrimary Domain Controller"]
                DC2["samba_dc2 (EC2)\nIP: 10.0.10.51\nReplica Domain Controller"]
            end
            
            subgraph RADIUS["Multi-Factor Authentication"]
                MFA["FreeRADIUS MFA Server\n(UDP Port 1812 - TOTP / OTP)"]
            end

            subgraph IAM_BROKER["Keycloak 24 IAM Gateway"]
                KC["Keycloak Server (Port 8080)\nUser Federation & Token Minting"]
            end
        end
    end

    subgraph CLIENTS["Platform & Application Consumers"]
        BS["Backstage Developer Portal\n(OIDC Authentication)"]
        ARGO["ArgoCD GitOps Control Plane\n(OIDC Authentication)"]
        APPS["Python & .NET Microservices\n(Bearer JWT Validation)"]
        USERS["Engineering & DevOps Users"]
    end

    DC1 <-->|DRS Directory Replication| DC2
    KC -->|LDAP 389 (Round-Robin)| DC1 & DC2
    KC -->|RADIUS 1812| MFA
    USERS -->|Single Sign-On| KC
    KC -. OIDC Tokens .-> BS
    KC -. OIDC Tokens .-> ARGO
    KC -. JWT Bearer .-> APPS
```

---

## 2. Samba 4 Active Directory Multi-DC Deployment

### 2.1 EKS VPC Integration
The Samba domain controllers are provisioned as EC2 instances inside the EKS cluster's private subnets (`10.0.10.0/24`). This provides:
- **Zero Peering Overhead:** Sub-millisecond latency between Kubernetes pods and Active Directory.
- **Enhanced Security:** Active Directory controllers are completely shielded from public internet ingress.

### 2.2 Dual Domain Controller Replication (DRS)
- **Primary Controller (`samba_dc1`):** Holds the Flexible Single Master Operation (FSMO) roles during initialization.
- **Secondary Controller (`samba_dc2`):** Joins the domain as an additional domain controller (`samba-tool domain join ... DC`).
- **Replication Protocol:** Active Directory Directory Replication Service (DRS) synchronizes objects, groups, and password hashes across both DCs.

### 2.3 DNS Conflict Prevention
Samba's built-in internal DNS server is explicitly disabled (`--dns-backend=NONE`) during provisioning. This design ensures that:
- AWS Route 53 remains the authoritative DNS service for external resolution.
- CoreDNS remains the authoritative DNS service for in-cluster Kubernetes pods.
- No port binding conflicts occur on port 53.

---

## 3. FreeRADIUS Multi-Factor Authentication (MFA)

- **Port & Protocol:** Runs on UDP port 1812.
- **Integration:** Acts as a secondary validation provider for Keycloak and VPN/bastion endpoints.
- **Token Support:** Pre-configured for Time-based One-Time Passwords (TOTP) and hardware OTP tokens.

---

## 4. Keycloak 24 IAM & SSO Gateway

### 4.1 User Federation with Active Directory
Keycloak connects to the Samba 4 domain controllers using its built-in LDAP user federation provider:
- **Connection URL:** `ldap://ad.<lab-id>.realhandsonlabs.net:389` (resolving via round-robin DNS to DC1 and DC2).
- **Sync Schedule:** Periodic synchronization of user attributes, department memberships, and role mappings.
- **Authentication Mode:** Direct Kerberos / LDAP bind authentication.

### 4.2 Single Sign-On (SSO) Protocols
- **OpenID Connect (OIDC):**
  - Mints JSON Web Tokens (JWT) containing user scopes, email addresses, and group memberships.
  - Used by Backstage and ArgoCD for developer login.
- **SAML 2.0:**
  - Supported for legacy enterprise tools and federated AWS IAM console access.

---

## 5. Dynamic Route 53 Endpoint Registration

The identity tier exports the following dynamic DNS records:

```hcl
# Round-Robin LDAP A Records
resource "aws_route53_record" "ldap_rr" {
  zone_id = local.zone_id
  name    = "ad.${local.base_fqdn}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.samba_dc1.private_ip, aws_instance.samba_dc2.private_ip]
}

# Keycloak SSO CNAME
resource "aws_route53_record" "keycloak" {
  zone_id = local.zone_id
  name    = "sso.${local.base_fqdn}"
  type    = "CNAME"
  ttl     = 60
  records = [data.kubernetes_service.keycloak.status[0].load_balancer[0].ingress[0].hostname]
}
```

---

## 6. Verification and Smoke Testing

```bash
# 1. Verify LDAP Round-Robin DNS
dig +short A ad.<lab-id>.realhandsonlabs.net

# 2. Test LDAP Search from inside the VPC
ldapsearch -x -H ldap://ad.<lab-id>.realhandsonlabs.net -b "dc=lab,dc=internal" -D "cn=Administrator,cn=Users,dc=lab,dc=internal" -W

# 3. Test Keycloak OIDC Discovery Endpoint
curl -s http://sso.<lab-id>.realhandsonlabs.net/realms/master/.well-known/openid-configuration | jq .issuer
```
