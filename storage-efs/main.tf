resource "aws_efs_file_system" "this" {
  creation_token = var.name
  encrypted      = var.encrypted
  tags = merge({ Name = var.name }, var.tags)
}

resource "aws_security_group" "efs" {
  name        = "${var.name}-efs-sg"
  description = "SG for EFS ${var.name}"
  vpc_id      = var.vpc_id
  ingress {
    description = "NFS access"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
    security_groups = var.allowed_security_group_ids
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge({ Name = "${var.name}-efs-sg" }, var.tags)
}

resource "aws_efs_mount_target" "this" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}
