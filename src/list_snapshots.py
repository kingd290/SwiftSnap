import boto3

aws_region = "us-east-1"

ec2_client = boto3.client("ec2", region_name=aws_region)

def list_snapshots():
    print("Listing EBS Snapshots:\n")
    
    response = ec2_client.describe_snapshots(OwnerIds=["self"])

    for snapshot in response["Snapshots"]:
        snapshot_id = snapshot["SnapshotId"]
        volume_id = snapshot["VolumeId"]
        start_time = snapshot["StartTime"].strftime("%Y-%m-%d %H:%M:%S")
        state = snapshot["State"]
        description = snapshot["Description"]
        
        print(f"Snapshot ID: {snapshot_id}")
        print(f"Volume ID: {volume_id}")
        print(f"Start Time: {start_time}")
        print(f"State: {state}")
        print(f"Description: {description}")
        
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
    list_snapshots()
