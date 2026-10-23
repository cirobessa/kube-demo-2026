resource "aws_ecs_cluster" "this" { name = var.name }
resource "aws_iam_role" "ecs_task" { name = "${var.name}-ecs-task" assume_role_policy = jsonencode({ Version="2012-10-17", Statement=[{Effect="Allow",Principal={Service="ecs-tasks.amazonaws.com"},Action="sts:AssumeRole"}] }) }
