# ecs/

ECS on **Fargate** — an nginx service behind an internet-facing ALB, in the
account's default VPC. A lighter-weight alternative to the `eks/` module.

## Deploys

- `aws_ecs_cluster.main` with Container Insights + FARGATE / FARGATE_SPOT providers
- Task execution IAM role (`AmazonECSTaskExecutionRolePolicy`)
- Task definition: `public.ecr.aws/nginx/nginx:stable-alpine`, 256 CPU / 512 MiB, awslogs
- ALB + HTTP:80 listener + `ip` target group (health check `/`)
- Security groups: public→ALB:80, ALB→tasks:80
- ECS service: 2 Fargate tasks in public subnets (`assign_public_ip` — no NAT needed)

Applies in ~4-6 min. Tasks take another ~1-2 min to pass ALB health checks.

## Usage

```bash
terraform init -backend-config=...   # the CI workflow does this
terraform apply -auto-approve
curl "$(terraform output -raw alb_url)"
```

## Key variables

| Variable          | Default                                      | Description            |
|-------------------|----------------------------------------------|-----------------------|
| `container_image` | `public.ecr.aws/nginx/nginx:stable-alpine`   | Image to run           |
| `container_port`  | `80`                                         | Container port         |
| `desired_count`   | `2`                                          | Number of tasks        |
| `task_cpu`        | `256`                                        | Fargate CPU units      |
| `task_memory`     | `512`                                        | Fargate memory (MiB)   |

## Outputs

`cluster_name`, `cluster_arn`, `service_name`, `task_definition_arn`,
`alb_dns_name`, `alb_url`.

## Notes

- The ALB listens on plain HTTP for demo purposes — add an HTTPS listener with
  an ACM certificate for anything real.
- `desired_count` changes are ignored after creation so an external autoscaler
  can manage it without Terraform drift.
