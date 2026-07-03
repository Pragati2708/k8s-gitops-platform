#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

count_query() {
  local service="$1"
  local operation="$2"
  local query="$3"
  shift 3
  aws_cli "$service" "$operation" "$@" --query "$query" --output json
}

main() {
  require_cmd aws
  check_aws_login

  section "Scope"
  print_kv "Date" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  print_kv "Region" "$AWS_REGION"
  print_kv "Cluster" "$CLUSTER_NAME"

  section "Running EC2 instances"
  count_query ec2 describe-instances 'Reservations[].Instances[].{Id:InstanceId,Type:InstanceType,State:State.Name,Name:Tags[?Key==`Name`]|[0].Value}' --filters 'Name=instance-state-name,Values=running'

  section "RDS instances"
  count_query rds describe-db-instances 'DBInstances[].{Id:DBInstanceIdentifier,Status:DBInstanceStatus,Class:DBInstanceClass,Endpoint:Endpoint.Address}'

  section "NAT gateways"
  count_query ec2 describe-nat-gateways 'NatGateways[].{Id:NatGatewayId,State:State,VpcId:VpcId,SubnetId:SubnetId}'

  section "Application/load balancers"
  count_query elbv2 describe-load-balancers 'LoadBalancers[].{Name:LoadBalancerName,Type:Type,State:State.Code,DNS:DNSName,VpcId:VpcId}'

  section "EKS clusters"
  count_query eks list-clusters 'clusters'

  section "ECR repositories"
  count_query ecr describe-repositories 'repositories[].{Name:repositoryName,Uri:repositoryUri}'

  section "Elastic IPs"
  count_query ec2 describe-addresses 'Addresses[].{PublicIp:PublicIp,AllocationId:AllocationId,AssociationId:AssociationId,InstanceId:InstanceId}'

  section "VPCs"
  count_query ec2 describe-vpcs 'Vpcs[].{VpcId:VpcId,Cidr:CidrBlock,Default:IsDefault}'

  section "Internet gateways"
  count_query ec2 describe-internet-gateways 'InternetGateways[].{Id:InternetGatewayId,Attachments:Attachments}'

  section "Estimated expensive resources"
  warn "Likely cost drivers: running EC2 nodes, EKS control plane, NAT gateway, ALBs, Elastic IPs, unattached EBS volumes, snapshots."
  success "Cost check completed. This script is read-only."
}

main "$@"
