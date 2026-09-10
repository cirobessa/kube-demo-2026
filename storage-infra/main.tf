# =============================================================================
# storage-infra module — persistent storage primitives for container workloads.
#   * two encrypted gp3 EBS volumes (data + logs) and a snapshot of the data one
#   * an EFS filesystem with one mount target per AZ and a POSIX access point
# Deploys into the account's default VPC.
# =============================================================================

locals {
  tags = {
    Project     = "kube-demo-2026"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Module      = "storage-infra"
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "default" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

locals {
  # First default subnet found in each AZ — EFS allows exactly one mount target per AZ.
  subnet_by_az = { for s in data.aws_subnet.default : s.availability_zone => s.id... }
  efs_subnets  = { for az, ids in local.subnet_by_az : az => sort(ids)[0] }
}

# ---------------------------------------------------------------------------
# EBS volumes
# ---------------------------------------------------------------------------
resource "aws_ebs_volume" "data" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = var.ebs_data_size
  type              = var.ebs_type
  throughput        = var.ebs_type == "gp3" ? var.ebs_throughput : null
  encrypted         = true

  tags = { Name = "${var.environment}-data", Role = "data" }
}

resource "aws_ebs_volume" "logs" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = var.ebs_logs_size
  type              = var.ebs_type
  throughput        = var.ebs_type == "gp3" ? var.ebs_throughput : null
  encrypted         = true

  tags = { Name = "${var.environment}-logs", Role = "logs" }
}

resource "aws_ebs_snapshot" "data" {
  volume_id   = aws_ebs_volume.data.id
  description = "Demo snapshot of the ${var.environment} data volume"

  tags = { Name = "${var.environment}-data-snapshot" }
}

# ---------------------------------------------------------------------------
# EFS filesystem
# ---------------------------------------------------------------------------
resource "aws_security_group" "efs" {
  name_prefix = "${var.environment}-efs-"
  description = "Allow NFS (2049) from within the default VPC"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "NFS from the VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.environment}-efs-sg" }
}

resource "aws_efs_file_system" "main" {
  creation_token  = "${var.environment}-shared-storage"
  throughput_mode = var.efs_throughput_mode
  encrypted       = true

  tags = { Name = "${var.environment}-shared-storage" }
}

resource "aws_efs_mount_target" "main" {
  for_each        = local.efs_subnets
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_access_point" "main" {
  file_system_id = aws_efs_file_system.main.id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/demo"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "755"
    }
  }

  tags = { Name = "${var.environment}-efs-access-point" }
}
