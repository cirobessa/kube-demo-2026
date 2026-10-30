# Disaster Recovery
Repo: https://github.com/cirobessa/kube-demo-2026
EKS: kube-demo-eks
VPC: criada pelo próprio módulo eks/ (eks/network.tf) — ver `terraform output vpc_id` após o apply, não é mais um ID fixo.
Restaurar: terraform init/apply no módulo eks/ (cria VPC + subnets + cluster + node group do zero).
