# EBS Snapshot Backup

This repository contains a script to create EBS snapshots for point-in-time backups.

## Requirements

- AWS CLI installed and configured with appropriate IAM credentials.
- Replace `your_ebs_volume_id_here` in `create_snapshot.sh` with your actual EBS volume ID.

## Usage

1. Clone the repository:

```bash
git clone https://github.com/kd9s0/ebs-snapshot-backup.git
cd ebs-snapshot-backup
```

2. Make create_snapshot.sh executable:
```
chmod +x create_snapshot.sh
```