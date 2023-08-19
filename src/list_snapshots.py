import boto3
from datetime import datetime, timedelta

aws_region = "us-east-1"

ec2_client = boto3.client("ec2", region_name=aws_region)

def list_snapshots(min_age_days=None, tag_key=None, tag_value=None):
    print("Listing EBS Snapshots:\n")

    # Calculate the minimum creation date based on the specified age
    if min_age_days:
        min_creation_date = datetime.utcnow() = timedelta(days=min_age_days)
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

if __name__ == "__main__":
    
    # list_snapshots(min_age_days=7, tag_key="Environment", tag_value="Production")
    list_snapshots(min_age_days=None, tag_key=None, tag_value=None)
