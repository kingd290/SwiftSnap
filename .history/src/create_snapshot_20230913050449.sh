#!/usr/bin/env bash

declare -A volume_map
volume_map["vol-0b235e5983aae1aef"]="Project1"
volume_map["vol-050ec02d0a7d2288b"]="Project2"

log_file="snapshot_log.txt"
log_max_size_mb=10  # Max log file size in megabytes
log_max_files=5    # Max number of log files to retain
notification_email="bagsy9000@gmail.com"
aws_region="us-east-1"

# Function to rotate log files
rotate_logs() {
    local log_file="$1"
    local log_max_size="$2"
    local log_max_files="$3"

    if [ -e "$log_file" ] && [ "$(du -m "$log_file" | cut -f1)" -gt "$log_max_size" ]; then
        mv "$log_file" "${log_file}.1"
        for ((i=log_max_files; i>1; i--)); do
            if [ -e "${log_file}.$(($i-1))" ]; then
                mv "${log_file}.$(($i-1))" "${log_file}.$i"
            fi
        done
    fi
}

create_ebs_snapshot() {
    local volume_id="$1"
    local folder_name="$2"
    local snapshot_description="Snapshot of $volume_id in $folder_name on $(date +'%Y-%m-%d %H:%M:%S')"
    
    echo "Creating EBS snapshot for volume $volume_id..."
    aws ec2 create-snapshot --volume-id "$volume_id" --description "$snapshot_description" --region "$aws_region"
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