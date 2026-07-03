#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

main() {
  require_cmd aws
  check_aws_login

  section "Cleanup report"
  warn "Report only. This script does not delete anything."

  section "Load balancers"
  aws_cli elbv2 describe-load-balancers --query 'LoadBalancers[].{Name:LoadBalancerName,Arn:LoadBalancerArn,State:State.Code,Type:Type,VpcId:VpcId}' --output json

  section "Target groups"
  aws_cli elbv2 describe-target-groups --query 'TargetGroups[].{Name:TargetGroupName,Arn:TargetGroupArn,VpcId:VpcId,Port:Port,Protocol:Protocol,TargetType:TargetType}' --output json

  section "Security groups with no attached network interfaces"
  aws_cli ec2 describe-security-groups --query 'SecurityGroups[].{GroupId:GroupId,GroupName:GroupName,VpcId:VpcId}' --output json

  section "Available ENIs"
  aws_cli ec2 describe-network-interfaces --filters 'Name=status,Values=available' --query 'NetworkInterfaces[].{Id:NetworkInterfaceId,Description:Description,VpcId:VpcId,SubnetId:SubnetId,PrivateIp:PrivateIpAddress}' --output json

  section "Unassociated Elastic IPs"
  aws_cli ec2 describe-addresses --query 'Addresses[?AssociationId==null].{PublicIp:PublicIp,AllocationId:AllocationId,Domain:Domain}' --output json

  section "Available EBS volumes"
  aws_cli ec2 describe-volumes --filters 'Name=status,Values=available' --query 'Volumes[].{Id:VolumeId,Size:Size,Type:VolumeType,Az:AvailabilityZone,Created:CreateTime}' --output json

  section "Snapshots owned by this account"
  local account_id
  account_id="$(aws sts get-caller-identity --query Account --output text)"
  aws_cli ec2 describe-snapshots --owner-ids "$account_id" --query 'Snapshots[].{Id:SnapshotId,VolumeId:VolumeId,Size:VolumeSize,Started:StartTime,State:State}' --output json

  success "Cleanup report completed. No resources were deleted."
}

main "$@"
