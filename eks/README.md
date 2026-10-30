# eks/

VPC + managed Amazon EKS cluster.

## Deploys

- A `/16` VPC with 2 public + 2 private subnets across 2 AZs, single NAT gateway
- An EKS cluster (Kubernetes `1.30` by default), public API endpoint
- Core add-ons: CoreDNS, kube-proxy, VPC CNI
- One managed node group: fixed at 2× `t3.medium`, AL2023 AMI
- IRSA OIDC provider, and cluster-admin for whoever runs `terraform apply`

## Usage

```bash
terraform init -backend-config=... # see repo README; the CI workflow does this
terraform apply -auto-approve
aws eks update-kubeconfig --name kube-demo-eks --region us-east-1 --profile kube-demo
kubectl get nodes
```

Apply takes ~20-25 min (control plane provisioning dominates).

## Key variables

| Variable            | Default          | Description                         |
|---------------------|------------------|------------------------------------|
| `cluster_name`      | `kube-demo-eks`  | Cluster name                        |
| `cluster_version`   | `1.30`           | Kubernetes version                  |
| `instance_types`    | `["t3.medium"]`  | Node group instance types           |
| `node_desired_size` | `2`              | Desired node count (fixed at 2)     |
| `vpc_cidr`          | `10.0.0.0/16`    | VPC CIDR                            |

## Outputs

`cluster_name`, `cluster_endpoint`, `cluster_arn`, `cluster_security_group_id`,
`oidc_provider_arn`, `vpc_id`, `kubeconfig_command`.

## Notes

- `cluster_endpoint_public_access = true` is for demo convenience — set it to
  `false` and use private access / VPC endpoints in production.
- The NAT gateway, control plane and nodes bill by the hour. Run
  `terraform destroy` when finished.
