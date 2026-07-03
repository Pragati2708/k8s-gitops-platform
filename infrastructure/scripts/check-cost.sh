#!/bin/bash

# Compatibility wrapper retained for earlier workflows.
# Prefer ./infrastructure/scripts/04_check-cost.sh for the maintained read-only cost report.

echo "========== EKS =========="
aws eks list-clusters

echo "========== EC2 =========="
aws ec2 describe-instances \
--filters "Name=instance-state-name,Values=running" \
--query "Reservations[].Instances[].InstanceId"

echo "========== RDS =========="
aws rds describe-db-instances \
--query "DBInstances[].DBInstanceIdentifier"

echo "========== ECR =========="
aws ecr describe-repositories \
--query "repositories[].repositoryName"

echo "========== Load Balancers =========="
aws elbv2 describe-load-balancers \
--query "LoadBalancers[].LoadBalancerName"

echo "========== NAT Gateway =========="
aws ec2 describe-nat-gateways \
--query "NatGateways[].NatGatewayId"
