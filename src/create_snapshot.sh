#!/bin/bash

# AWS CLI Command to Create EBS Snapshot
volume_id="your_ebs_volume_id_here"
snapshot_description="Snapshot taken on $(date +'%Y-%m-%d %H:%M:%S')"
log_file="snapshot_log.txt"