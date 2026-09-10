output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.web.name
}

output "task_definition_arn" {
  description = "Active task definition ARN"
  value       = aws_ecs_task_definition.svc.arn
}

output "alb_dns_name" {
  description = "Public DNS name of the ALB — open http://<this> in a browser"
  value       = aws_lb.main.dns_name
}

output "alb_url" {
  description = "Convenience URL for the demo service"
  value       = "http://${aws_lb.main.dns_name}"
}
