resource "aws_lb" "this" { name = var.name internal = false load_balancer_type = "network" subnets = var.subnet_ids security_groups = [aws_security_group.lb.id] }
resource "aws_security_group" "lb" { name = "${var.name}-lb" vpc_id = var.vpc_id ingress { from_port = 80 to_port = 80 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] } }
