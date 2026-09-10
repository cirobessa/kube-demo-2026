# storage-infra/

Standalone persistent-storage primitives, deployed into the account's **default VPC**.

## Deploys

- `aws_ebs_volume.data` — encrypted `gp3`, 20 GiB
- `aws_ebs_volume.logs` — encrypted `gp3`, 10 GiB
- `aws_ebs_snapshot.data` — a snapshot of the data volume (backup demo)
- `aws_efs_file_system.main` — encrypted EFS, one mount target per AZ
- `aws_security_group.efs` — allows NFS/2049 from the VPC CIDR
- `aws_efs_access_point.main` — POSIX access point at `/demo` (uid/gid 1000)

Applies in ~2-3 min.

## Key variables

| Variable              | Default     | Description                     |
|-----------------------|-------------|--------------------------------|
| `ebs_data_size`       | `20`        | Data volume size (GiB)          |
| `ebs_logs_size`       | `10`        | Logs volume size (GiB)          |
| `ebs_type`            | `gp3`       | EBS volume type                 |
| `efs_throughput_mode` | `bursting`  | `bursting` / `provisioned` / `elastic` |

## Outputs

`ebs_data_volume_id`, `ebs_logs_volume_id`, `ebs_data_snapshot_id`,
`efs_file_system_id`, `efs_access_point_id`, `efs_mount_target_ids`, `summary`.

## Attaching to EKS

With the AWS EFS CSI driver installed on the cluster, mount the filesystem
`ReadWriteMany` via the access point:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: efs-shared
spec:
  capacity: { storage: 5Gi }
  accessModes: ["ReadWriteMany"]
  csi:
    driver: efs.csi.aws.com
    volumeHandle: <efs_file_system_id>::<efs_access_point_id>
```

An `aws_ebs_volume` can likewise back a static `ReadWriteOnce` PV via
`csi.driver: ebs.csi.aws.com` and `volumeHandle: <ebs_data_volume_id>`
(the volume must be in the same AZ as the consuming node).
