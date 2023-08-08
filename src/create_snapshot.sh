#!/bin/bash

# AWS CLI Command to Create EBS Snapshot
volume_id="your_ebs_volume_id_here"
snapshot_description="Snapshot taken on $(date +'%Y-%m-%d %H:%M:%S')"
log_file="snapshot_log.txt"

# Function to create EBS snapshot
create_ebs_snapshot() {
    local volume_id="$1"
    local snapshot_description="$2"
    
    echo "Creating EBS snapshot for volume $volume_id..."
    aws ec2 create-snapshot --volume-id "$volume_id" --description "$snapshot_description"
}
