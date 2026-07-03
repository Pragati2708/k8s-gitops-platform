#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

main() {
  require_cmd aws
  check_aws_login

  section "Database status"
  aws_cli rds describe-db-instances --db-instance-identifier banking-db --query 'DBInstances[0].{Identifier:DBInstanceIdentifier,Status:DBInstanceStatus,Engine:Engine,Version:EngineVersion,Class:DBInstanceClass,Endpoint:Endpoint.Address,Port:Endpoint.Port,Public:PubliclyAccessible,StorageEncrypted:StorageEncrypted,BackupRetention:BackupRetentionPeriod}' --output table

  section "Database security groups"
  local sg_ids
  sg_ids="$(aws_cli rds describe-db-instances --db-instance-identifier banking-db --query 'DBInstances[0].VpcSecurityGroups[].VpcSecurityGroupId' --output text)"
  if [[ -z "$sg_ids" || "$sg_ids" == "None" ]]; then
    fail "No RDS security groups found."
  fi
  aws_cli ec2 describe-security-groups --group-ids $sg_ids --query 'SecurityGroups[].{GroupId:GroupId,GroupName:GroupName,Ingress:IpPermissions,Egress:IpPermissionsEgress}' --output json

  section "Database reachability signal"
  local endpoint
  endpoint="$(aws_cli rds describe-db-instances --db-instance-identifier banking-db --query 'DBInstances[0].Endpoint.Address' --output text)"
  print_kv "Endpoint" "$endpoint"
  print_kv "Port" "5432"
  warn "This script does not connect to PostgreSQL or read/write database data."

  success "Database health check completed."
}

main "$@"
