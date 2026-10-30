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
| [`eks/`](eks/) | Amazon EKS  | VPC-attached managed Kubernetes cluster, node group fixed at 2× `t3.medium` |

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
  this going forward (pre-existing tracked `terraform.tfstate*`/`*.tfvars`
  files under `eks/` predate the rule and were left as-is).
