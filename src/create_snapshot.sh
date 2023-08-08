#!/bin/bash

# AWS CLI Command to Create EBS Snapshot
volume_id="your_ebs_volume_id_here"
snapshot_description="Snapshot taken on $(date +'%Y-%m-%d %H:%M:%S')"
aws ec2 create-snapshot --volume-id "$volume_id" --description "$snapshot_description"
