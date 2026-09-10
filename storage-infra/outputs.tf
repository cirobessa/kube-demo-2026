output "ebs_data_volume_id" {
  description = "Id of the data EBS volume"
  value       = aws_ebs_volume.data.id
}

output "ebs_logs_volume_id" {
  description = "Id of the logs EBS volume"
  value       = aws_ebs_volume.logs.id
}

output "ebs_data_snapshot_id" {
  description = "Id of the data volume snapshot"
  value       = aws_ebs_snapshot.data.id
}

output "efs_file_system_id" {
  description = "Id of the EFS filesystem"
  value       = aws_efs_file_system.main.id
}

output "efs_access_point_id" {
  description = "Id of the EFS access point"
  value       = aws_efs_access_point.main.id
}

output "efs_mount_target_ids" {
  description = "EFS mount target ids (one per AZ)"
  value       = [for mt in aws_efs_mount_target.main : mt.id]
}

output "summary" {
  description = "Human-readable summary of the storage that was created"
  value       = <<-EOT
    EBS data   : ${aws_ebs_volume.data.id} (${var.ebs_data_size} GiB ${var.ebs_type})
    EBS logs   : ${aws_ebs_volume.logs.id} (${var.ebs_logs_size} GiB ${var.ebs_type})
    EBS snap   : ${aws_ebs_snapshot.data.id}
    EFS        : ${aws_efs_file_system.main.id} (${length(aws_efs_mount_target.main)} mount targets)
    EFS AP     : ${aws_efs_access_point.main.id}
  EOT
}
