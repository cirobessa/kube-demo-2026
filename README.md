# kube-demo-2026

Minimal Amazon EKS cluster on AWS, provisioned with Terraform.

Reduced to the essential module: just the EKS cluster. All course-exercise
scaffolding (ECR, ECS, storage, cli-setup, cluster-console, load balancer,
samba/keycloak, managed Fargate, and other incomplete fragments) was removed
because it was unsafe (CI triggered on every push with `-backend=false`,
meaning no persisted state) and/or non-functional (broken resource
references, missing files).

| Directory   | Technology  | What it deploys                                            |
|-------------|-------------|-------------------------------------------------------------|
| [`eks/`](eks/) | Amazon EKS  | Own VPC (2 public + 2 private subnets, NAT, IGW) + managed Kubernetes cluster + node group (1-3× `t3.medium`, desired 2) |

The `eks/` module owns its own networking (`eks/network.tf`): the cluster
control plane and node group no longer point at hardcoded subnet IDs from an
external/deleted module — those IDs went stale (one no longer existed in
AWS) and broke `terraform apply`. The module also enables control-plane
encryption (KMS), the 5 standard log types, and an IAM OIDC provider for
IRSA (so add-ons like cluster-autoscaler/external-dns can use scoped
IAM roles instead of node-instance-profile-wide permissions).

## Prerequisites

- Terraform >= 1.5
- AWS CLI v2, configured with a profile named `kube-demo`
- `kubectl`
- `eksctl` (optional, for quick add-on/plugin management — e.g. cluster-autoscaler, external-dns — once the cluster is up)

## 1. Configure credentials

Credentials live only in `~/.aws/` and are never committed.

```bash
aws sts get-caller-identity --profile kube-demo
```

## 2. Deploy

```bash
cd eks && terraform init && terraform apply -auto-approve && cd ..
aws eks update-kubeconfig --name kube-demo-eks --region us-east-1 --profile kube-demo
kubectl get nodes
```

CI deploys the same module via `.github/workflows/eks.yml`, which calls the
reusable `.github/workflows/_terraform.yml` (S3 backend with native locking,
`terraform fmt`/`validate`, and `plan`/`apply`/`destroy` via
`workflow_dispatch`).

## 3. Add necessary plugins

With the cluster up, install only what's needed on top of it, e.g.:

```bash
# cluster-autoscaler (via Helm, once IRSA role/policy exist)
helm install cluster-autoscaler autoscaler/cluster-autoscaler -n kube-system ...

# external-dns (via Helm, once IRSA role/policy exist)
helm install external-dns external-dns/external-dns -n kube-system ...
```

These are intentionally not pre-baked as Terraform modules here — add them
when actually needed, scoped to the specific IAM/IRSA permissions required.

## 4. Tear down

```bash
cd eks && terraform destroy -auto-approve && cd ..
```

## Security notes

- The EKS API endpoint is publicly reachable — demo only. In production use
  private endpoints / HTTPS + WAF.
- Never commit `~/.aws/`, `*.tfstate`, or `*.tfvars`. `.gitignore` enforces
  this going forward; the stale `eks/terraform.tfstate` that was previously
  tracked (leaking the AWS account ID in a public repo) has been removed
  from version control — the S3 backend is the only state CI ever reads.
