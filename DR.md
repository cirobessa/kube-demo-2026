# Disaster Recovery & State Continuity Summary

- **Primary Repository:** [`cirobessa/kube-demo-2026`](https://github.com/cirobessa/kube-demo-2026)
- **VPC Engine:** Fully codified in [`eks/vpc.tf`](file:///home/ciro/kube-demo-2026/eks/vpc.tf) — zero hardcoded VPC IDs; auto-provisions across 2 AZs.
- **EKS Cluster:** `kube-demo-eks` (Kubernetes 1.30 managed control plane with 2x `t3.medium` workers).
- **Target RTO:** Under 20 minutes from a blank AWS sandbox account to a fully hydrated, production-ready platform.
- **Target RPO:** 0 seconds for infrastructure and microservices (100% Git-backed); periodic database rehydration via Backstage SQL exports.

---

## Detailed Playbooks & References

- 📘 **Complete Disaster Recovery Guide:** See [`docs/DISASTER-RECOVERY.md`](file:///home/ciro/kube-demo-2026/docs/DISASTER-RECOVERY.md) for full backup endpoints, state locking, and restore protocols.
- 🚀 **Zero-to-Production Runbook:** Follow [`DEPLOY-ORDER-RUNBOOK.md`](file:///home/ciro/kube-demo-2026/DEPLOY-ORDER-RUNBOOK.md) for the deterministic 6-phase recreation order.
- 🌐 **Route 53 Dynamic DNS:** See [`docs/ROUTE53-DYNAMIC-DNS.md`](file:///home/ciro/kube-demo-2026/docs/ROUTE53-DYNAMIC-DNS.md) for automated CNAME discovery and delegation across rotating accounts.
