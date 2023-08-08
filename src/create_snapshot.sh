#!/bin/bash

# AWS CLI Command to Create EBS Snapshot
volume_id="your_ebs_volume_id_here"
snapshot_description="Snapshot taken on $(date +'%Y-%m-%d %H:%M:%S')"
log_file="snapshot_log.txt"

# function to create EBS snapshot
create_ebs_snapshot() {
    local volume_id="$1"
    local snapshot_description="$2"
    
    echo "Creating EBS snapshot for volume $volume_id..."
    aws ec2 create-snapshot --volume-id "$volume_id" --description "$snapshot_description"
}

# function to clean up old snapshots (keep only the latest N snapshots)
cleanup_snapshots() {
    local volume_id="$1"
    local num_snapshots_to_retain=5

    echo "Cleaning up old snapshots for volume $volume_id..."
    snapshot_ids=$(aws ec2 describe-snapshots --filters "Name=volume-id,Values=$volume_id" --query "Snapshots | sort_by(@, &StartTime) | [:-( $num_snapshots_to_retain )].SnapshotId" --output text)
    if [[ -n "$snapshot_ids" ]]; then
        for snapshot_id in $snapshot_ids; do
            echo "Deleting snapshot: $snapshot_id"
            aws ec2 delete-snapshot --snapshot-id "$snapshot_id"
        done
    else
        echo "No old snapshots found."
    fi
}