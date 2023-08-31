# EBS Snapshot Backup

This repository contains a bash script to create EBS snapshots for point-in-time backups. There is an independent python script that uses the AWS Boto3 library to retrieve information about EBS snapshots, including their tags and other metadata. This script will allow you to query and display details about your snapshots

The `list_snapshots` function in the python script accepts three optional parameters:

- `min_age_days`: Filters snapshots based on their age in days
- `tag_key`: Filters snapshots based on a specific tag key
- `tag_value`: Filters snapshots based on a specific tag value

## Requirements

- AWS CLI installed and configured with appropriate IAM credentials.
- Replace `your_ebs_volume_id_here` in `create_snapshot.sh` with your actual EBS volume ID.

## Features

- Creates an EBS snapshot with a timestamp-based descriaa   0 .
- Creates snapshot of Multiple EBS Volumes
- Retains only the latest N snapshots (controlled by `num_snapshots_to_retain` in the script).
- Logs events to a file (`snapshot_log.txt`).
- Tagging the snapshots with useful metadata
- Send notifications via email after snapshot creation
- Error handling

**Features added to `list_snapshots.py`**
- Deleting Snapshots: Added a function that allows to delete snapshots based on certain criteria, such as age or specific tags
- Copying Snapshots: Added a function that enables you to copy snapshots to another AWS region, helping with cross-region disaster recovery

## Usage

1. Clone the repository:

```bash
git clone https://github.com/kd9s0/ebs-snapshot-backup.git
cd ebs-snapshot-backup
```

2. Run the following command in your command-line terminal to install the packages listed in the `requirements.txt` file:
```
pip install -r requirements.txt
```

3. Make create_snapshot.sh executable:
```
chmod +x create_snapshot.sh
```

4. Run the script to create an EBS snapshot:
```
./create_snapshot.sh
```

5. Query information about EBS snapshot by run command:
```
python list_snapshots.py
```
