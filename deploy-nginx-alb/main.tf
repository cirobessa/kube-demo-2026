resource "aws_lb_target_group" "nginx" {
  name        = "nginx-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}
resource "aws_lb_listener_rule" "nginx" {
  listener_arn = var.alb_listener_arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }
  conditions {
    field  = "path-pattern"
    values = ["/*"]
  }
}
variable "vpc_id" { type = string }
variable "alb_listener_arn" { type = string }
variable "subnet_ids" { type = list(string) }
