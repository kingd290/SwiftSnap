import boto3
import logging
from datetime import datetime, timedelta

logging.basicConfig(filename='snapshot_manager.log', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


aws_region = "us-east-1"

ec2_client = boto3.client("ec2", region_name=aws_region)

def list_snapshots(min_age_days=None, tag_key=None, tag_value=None):
    logging.info("Listing EBS Snapshots:\n")
    print("Listing EBS Snapshots:\n")

    # Calculate the minimum creation date based on the specified age
    if min_age_days:
        min_creation_date = datetime.utcnow() - timedelta(days=min_age_days)
    else:
        min_creation_date = None

    # Retrieve snapshots
    response = ec2_client.describe_snapshots(OwnerIds=["self"])

    # Display snapshot details
    for snapshot in response["Snapshots"]:
        snapshot_id = snapshot["SnapshotId"]
        volume_id = snapshot["VolumeId"]
        start_time = snapshot["StartTime"].strftime("%Y-%m-%d %H:%M:%S")
        state = snapshot["State"]
        description = snapshot["Description"]
        creation_date = snapshot["StartTime"]

        # Check if the snapshot meets the age criteria
        if min_creation_date and creation_date < min_creation_date:
            continue
        
        # Check if the snapshot has the specified tag
        if tag_key and tag_value:
            tags_response = ec2_client.describe_tags(Filters=[{"Name": "resource-id", "Values": [snapshot_id]}])
            tags = tags_response.get("Tags", [])
            tag_found = False
            for tag in tags:
                if tag["Key"] == tag_key and tag["Value"] == tag_value:
                    tag_found = True
                    break
            if not tag_found:
                continue

        print(f"Snapshot ID: {snapshot_id}")
        print(f"Volume ID: {volume_id}")
        print(f"Start Time: {start_time}")
        print(f"State: {state}")
        print(f"Description: {description}")
        print(f"Creation Date: {creation_date}")
        
        # Display tags
        tags_response = ec2_client.describe_tags(Filters=[{"Name": "resource-id", "Values": [snapshot_id]}])
        tags = tags_response.get("Tags", [])
        if tags:
            print("Tags:")
            for tag in tags:
                key = tag["Key"]
                value = tag["Value"]
                print(f"  {key}: {value}")
        
        print("\n")
        
def delete_snapshots_by_age(max_age_days):
    print("Deleting Snapshots by Age:\n")
    
    max_creation_date = datetime.utcnow() - timedelta(days=max_age_days)
    response = ec2_client.describe_snapshots(OwnerIds=["self"])
    
    for snapshot in response["Snapshots"]:
        snapshot_id = snapshot["SnapshotId"]
        creation_date = snapshot["StartTime"]
        
    if creation_date < max_creation_date:
            print(f"Deleting snapshot {snapshot_id} created on {creation_date}")
            ec2_client.delete_snapshot(SnapshotId=snapshot_id)
            print("Snapshot deleted.\n")
            
def copy_snapshots_to_region(source_region, destination_region):
    print("Copying Snapshots to Another Region:\n")
    
    source_ec2_client = boto3.client("ec2", region_name=source_region)
    source_response = source_ec2_client.describe_snapshots(OwnerIds=["self"])
    
    for snapshot in source_response["Snapshots"]:
        snapshot_id = snapshot["SnapshotId"]
        print(f"Copying snapshot {snapshot_id} from {source_region} to {destination_region}")
        
        destination_ec2_client = boto3.client("ec2", region_name=destination_region)
        copy_response = destination_ec2_client.copy_snapshot(SourceRegion=source_region, SourceSnapshotId=snapshot_id)
        
        new_snapshot_id = copy_response["SnapshotId"]
        105102

if __name__ == "__main__":
    
    delete_snapshots_by_age(max_age_days=30)

