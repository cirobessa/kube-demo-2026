output "efs_id" { value=aws_efs_file_system.this.id }
output "efs_dns_name" { value=aws_efs_file_system.this.dns_name }
output "security_group_id" { value=aws_security_group.efs.id }
