#!/bin/bash
# Deploy all EKS modules - English (demo account)
set -e
echo "Network..."
cd network && /tmp/terraform apply -auto-approve || true
echo "EKS..."
cd ../eks && /tmp/terraform apply -auto-approve -var-file=terraform.tfvars || true
echo "Modules..."
for d in ../autoscaler ../cli-setup ../nodegroups ../iam-roles ../loadbalancer ../ingress-alb ../storage-ebs-csi ../storage-efs ../ecr ../ecs ../managed-fargate ../cluster-console ../conclusion; do
  [ -d "$d" ] && (cd "$d" && /tmp/terraform apply -auto-approve || true)
done
echo "Done."
