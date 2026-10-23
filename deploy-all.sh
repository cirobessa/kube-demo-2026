#!/bin/bash
# Deploy all EKS modules - English (demo account)
set -e
echo "Network init..."
cd ~/kube-demo-2026/network && /tmp/terraform init -backend=false || true
echo "Network apply..."
cd ~/kube-demo-2026/network && /tmp/terraform apply -auto-approve -no-color -input=false || true
echo "EKS init..."
cd ~/kube-demo-2026/eks && /tmp/terraform init -backend=false || true
echo "EKS apply..."
cd ~/kube-demo-2026/eks && /tmp/terraform apply -auto-approve -no-color -input=false -var-file=terraform.tfvars || true
echo "Modules..."
for d in autoscaler cli-setup cluster-console conclusion ecr ecs iam-roles ingress-alb loadbalancer managed-fargate modules nodegroups storage-ebs-csi storage-efs storage-infra; do
  [ -d "$HOME/kube-demo-2026/$d" ] || continue
  echo "Module $d..."
  (cd "$HOME/kube-demo-2026/$d" && /tmp/terraform init -backend=false || true)
  (cd "$HOME/kube-demo-2026/$d" && /tmp/terraform apply -auto-approve -no-color -input=false -var-file=terraform.tfvars || true)
done
echo "Done."
