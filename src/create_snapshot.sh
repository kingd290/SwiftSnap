#!/bin/bash

# AWS CLI Command to Create EBS Snapshot
volume_id="your_ebs_volume_id_here"
snapshot_description="Snapshot taken on $(date +'%Y-%m-%d %H:%M:%S')"
log_file="snapshot_log.txt"
notification_email="your_email@example.com"
aws_region="us-east-1"
kms_key_id="your_kms_key_id_here"

# Function to create EBS snapshot
create_ebs_snapshot() {
    local volume_id="$1"
    local snapshot_description="$2"
    
    echo "Creating EBS snapshot for volume $volume_id..."
    aws ec2 create-snapshot --volume-id "$volume_id" --description "$snapshot_description" --region "$aws_region" --kms-key-id "$kms_key_id"
}

# Function to tag the snapshot
tag_snapshot() {
    local snapshot_id="$1"
    
    aws ec2 create-tags --resources "$snapshot_id" --tags "Key=Name,Value=EBS-Snapshot" "Key=CreatedBy,Value=EBS-Snapshot-Script" --region "$aws_region"
}

# Function to send notification email
send_notification() {
    local subject="$1"
    local message="$2"

    echo "$message" | mail -s "$subject" "$notification_email"
}

# Main script execution
if [[ -z "$volume_id" || "$volume_id" == "your_ebs_volume_id_here" ]]; then
    echo "ERROR: Please replace 'your_ebs_volume_id_here' with your actual EBS volume ID."
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "ERROR: AWS CLI is not installed. Please install it and configure with appropriate IAM credentials."
    exit 1
fi

# Create EBS snapshot
snapshot_id=$(create_ebs_snapshot "$volume_id" "$snapshot_description")

# Tag the snapshot
tag_snapshot "$snapshot_id"

# Log event
echo "$(date +'%Y-%m-%d %H:%M:%S') - EBS snapshot created: $snapshot_id" >> "$log_file"

# Send notification email
notification_subject="EBS Snapshot Created"
notification_message="An EBS snapshot has been created with ID: $snapshot_id"
send_notification "$notification_subject" "$notification_message"
