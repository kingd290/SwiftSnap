#!/bin/bash
+
declare -A volume_map
volume_map["vol-1"]="Folder1"
volume_map["vol-2"]="Folder2"

log_file="snapshot_log.txt"
notification_email="your_email@example.com"
aws_region="us-east-1"
kms_key_id="your_kms_key_id_here"

create_ebs_snapshot() {
    local volume_id="$1"
    local folder_name="$2"
    local snapshot_description="Snapshot of $volume_id in $folder_name on $(date +'%Y-%m-%d %H:%M:%S')"
    
    echo "Creating EBS snapshot for volume $volume_id..."
    aws ec2 create-snapshot --volume-id "$volume_id" --description "$snapshot_description" --region "$aws_region" --kms-key-id "$kms_key_id"
}

# Function to tag the snapshot
tag_snapshot() {
    local snapshot_id="$1"
    local folder_name="$2"
    
    aws ec2 create-tags --resources "$snapshot_id" --tags "Key=Name,Value=EBS-Snapshot" "Key=CreatedBy,Value=EBS-Snapshot-Script" "Key=Folder,Value=$folder_name" --region "$aws_region"
}

send_notification() {
    local subject="$1"
    local message="$2"

    echo "$message" | mail -s "$subject" "$notification_email"
}

if ! command -v aws &> /dev/null; then
    echo "ERROR: AWS CLI is not installed. Please install it and configure with appropriate IAM credentials."
    exit 1
fi

# Iterate through volume_map and create snapshots for each volume
for volume_id in "${!volume_map[@]}"; do
    folder_name="${volume_map[$volume_id]}"
    
    snapshot_id=$(create_ebs_snapshot "$volume_id" "$folder_name")

    tag_snapshot "$snapshot_id" "$folder_name"

    echo "$(date +'%Y-%m-%d %H:%M:%S') - EBS snapshot created: $snapshot_id" >> "$log_file"
done

notification_subject="EBS Snapshots Created"
notification_message="EBS snapshots have been created for the specified volumes."
send_notification "$notification_subject" "$notification_message"
