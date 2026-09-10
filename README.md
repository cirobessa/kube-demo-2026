# kube-demo-2026

Kubernetes & container infrastructure on AWS, provisioned with Terraform.
Three self-contained modules, one per directory, each deployable on its own.

| Directory        | Technology          | What it deploys                                                        |
|------------------|---------------------|-----------------------------------------------------------------------|
| [`eks/`](eks/)                 | Amazon EKS          | VPC + managed Kubernetes cluster (`t3.medium` node group)             |
| [`storage-infra/`](storage-infra/) | Amazon EBS + EFS    | `gp3` block volumes (+ snapshot) and a shared EFS filesystem          |
| [`ecs/`](ecs/)                 | Amazon ECS (Fargate)| ECS cluster + Fargate service behind an internet-facing ALB          |

All code is **account-agnostic**: the target account is whatever the configured
AWS profile points at. `aws_account_id` is accepted as an optional variable for
tagging / policy scoping but is not required.

## Prerequisites

- Terraform >= 1.5
- AWS CLI v2, configured with a profile named `kube-demo`
- `kubectl` (for the EKS module)

## 1. Configure credentials

Credentials live only in `~/.aws/` and are never committed.

```bash
./credentials-setup.sh          # prompts for key/secret, writes the kube-demo profile
aws sts get-caller-identity --profile kube-demo
```

## 2. Deploy

Each module is independent. `storage-infra/` and `ecs/` are standalone;
`eks/` creates the cluster the storage volumes can later be attached to.

```bash
# Storage (fast, ~3 min)
cd storage-infra && terraform init && terraform apply -auto-approve && cd ..

# EKS cluster (slow, ~20-25 min)
cd eks && terraform init && terraform apply -auto-approve && cd ..
aws eks update-kubeconfig --name kube-demo-eks --region us-east-1 --profile kube-demo
kubectl get nodes

# ECS Fargate service (~5 min)
cd ecs && terraform init && terraform apply -auto-approve && cd ..
curl "http://$(terraform -chdir=ecs output -raw alb_dns_name)"
```

## 3. Tear down

Lab/demo accounts are time-limited and the EKS control plane + ALB bill by the
hour. Destroy in reverse order when done:

```bash
cd ecs && terraform destroy -auto-approve && cd ..
cd eks && terraform destroy -auto-approve && cd ..
cd storage-infra && terraform destroy -auto-approve && cd ..
```

## Global variables

| Variable         | Default       | Description                                    |
|------------------|---------------|-----------------------------------------------|
| `region`         | `us-east-1`   | AWS region                                     |
| `aws_profile`    | `kube-demo`   | Local AWS CLI profile to authenticate with     |
| `aws_account_id` | `""`          | Optional; account id for tags / policy scoping |
| `environment`    | `demo`        | Environment tag applied to every resource      |

See each module's `README.md` for module-specific variables and outputs.

## Security notes

- The EKS API endpoint and the ECS ALB are publicly reachable — demo only.
  In production use private endpoints / HTTPS + WAF.
- Never commit `~/.aws/`, `*.tfstate`, or `*.tfvars`. `.gitignore` enforces this.
