#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

CONFIRM_VALUE="${CONFIRM:-}"
DELETE_PROJECT_ALBS="true"
STEP_RESULTS=()

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes)
        CONFIRM_VALUE="STOP_DEV"
        shift
        ;;
      --no-alb-delete)
        DELETE_PROJECT_ALBS="false"
        shift
        ;;
      --cleanup-orphans)
        DELETE_PROJECT_ALBS="true"
        shift
        ;;
      *)
        fail "Unknown argument: $1"
        ;;
    esac
  done
}

record_step() {
  STEP_RESULTS+=("$1|$2|$3")
}

run_recorded_step() {
  local title="$1"
  shift

  local started
  started="$(now_seconds)"
  if run_step "$title" "$@"; then
    record_step "$title" "Success" "$(elapsed_time "$started")"
  else
    local rc=$?
    record_step "$title" "Failure" "$(elapsed_time "$started")"
    return "$rc"
  fi
}

verify_prerequisites() {
  require_cmd terraform
  require_cmd aws
  check_aws_login
}

destroy_platform_layer() {
  local platform_dir
  platform_dir="$(repo_path infrastructure/terraform/terraform-platform)"

  log "Destroying Terraform platform layer only: ArgoCD and AWS Load Balancer Controller."
  terraform -chdir="$platform_dir" destroy -auto-approve
}

destroy_eks_compute() {
  local infra_dir
  infra_dir="$(repo_path infrastructure/terraform/terraform-infra)"

  log "Destroying only module.eks. RDS, ECR, IAM, S3, DynamoDB, backend state, database data, and Docker images are not targeted."
  terraform -chdir="$infra_dir" destroy -target=module.eks -auto-approve
}

verify_eks_removal() {
  local status
  local attempt

  for attempt in {1..60}; do
    status="$(aws_cli eks describe-cluster --name "$CLUSTER_NAME" --query 'cluster.status' --output text 2>/dev/null || true)"

    if [[ -z "$status" || "$status" == "None" ]]; then
      log "EKS cluster ${CLUSTER_NAME} is no longer describable."
      return 0
    fi

    printf 'EKS %s status: %s\n' "$CLUSTER_NAME" "$status"
    sleep 30
  done

  step_warning "EKS cluster ${CLUSTER_NAME} was still describable after waiting."
  return 1
}

project_alb_tag_match() {
  local lb_arn="$1"
  local cluster_tag
  local k8s_cluster_tag

  cluster_tag="$(aws_cli elbv2 describe-tags --resource-arns "$lb_arn" --query "TagDescriptions[0].Tags[?Key=='kubernetes.io/cluster/${CLUSTER_NAME}'].Value | [0]" --output text 2>/dev/null || true)"
  k8s_cluster_tag="$(aws_cli elbv2 describe-tags --resource-arns "$lb_arn" --query "TagDescriptions[0].Tags[?Key=='elbv2.k8s.aws/cluster'].Value | [0]" --output text 2>/dev/null || true)"

  [[ "$cluster_tag" == "owned" || "$cluster_tag" == "shared" || "$k8s_cluster_tag" == "$CLUSTER_NAME" ]]
}

detect_and_delete_project_albs() {
  local lbs
  local lb
  local deleted=0
  local skipped=0

  lbs="$(aws_cli elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerArn' --output text || true)"
  if [[ -z "$lbs" || "$lbs" == "None" ]]; then
    log "No load balancers detected."
    return 0
  fi

  for lb in $lbs; do
    if project_alb_tag_match "$lb"; then
      if [[ "$DELETE_PROJECT_ALBS" == "true" ]]; then
        log "Deleting project-owned orphan ALB: $lb"
        aws_cli elbv2 delete-load-balancer --load-balancer-arn "$lb"
        deleted=$((deleted + 1))
      else
        step_warning "Project-owned ALB detected but not deleted because --no-alb-delete was supplied: $lb"
        skipped=$((skipped + 1))
      fi
    else
      log "Skipping ALB without project ownership tags: $lb"
      skipped=$((skipped + 1))
    fi
  done

  print_kv "Project ALBs deleted" "$deleted"
  print_kv "ALBs skipped" "$skipped"
}

report_remaining_resources() {
  section "Target Groups"
  aws_cli elbv2 describe-target-groups --query 'TargetGroups[].{Name:TargetGroupName,Arn:TargetGroupArn,VpcId:VpcId,Port:Port,Protocol:Protocol,TargetType:TargetType}' --output json

  section "Security Groups"
  aws_cli ec2 describe-security-groups --query 'SecurityGroups[].{GroupId:GroupId,GroupName:GroupName,VpcId:VpcId,Description:Description}' --output json

  section "ENIs"
  aws_cli ec2 describe-network-interfaces --query 'NetworkInterfaces[].{Id:NetworkInterfaceId,Status:Status,Description:Description,VpcId:VpcId,SubnetId:SubnetId,PrivateIp:PrivateIpAddress}' --output json

  section "Elastic IPs"
  aws_cli ec2 describe-addresses --query 'Addresses[].{PublicIp:PublicIp,AllocationId:AllocationId,AssociationId:AssociationId,Domain:Domain}' --output json

  section "NAT Gateway"
  aws_cli ec2 describe-nat-gateways --query 'NatGateways[].{Id:NatGatewayId,State:State,VpcId:VpcId,SubnetId:SubnetId}' --output json

  step_warning "Report only: target groups, security groups, ENIs, Elastic IPs, and NAT gateways were not deleted."
}

print_summary() {
  section "Final summary"
  print_kv "Repository" "$REPO_ROOT"
  print_kv "AWS region" "$AWS_REGION"
  print_kv "EKS cluster" "$CLUSTER_NAME"
  print_kv "Protected resources" "RDS, ECR, IAM, S3, DynamoDB, Terraform backend, database data, Docker images"

  printf '\n%-38s %-10s %s\n' "Step" "Result" "Elapsed Time"
  printf '%-38s %-10s %s\n' "----" "------" "------------"

  local entry
  for entry in "${STEP_RESULTS[@]}"; do
    IFS='|' read -r title result elapsed <<<"$entry"
    printf '%-38s %-10s %s\n' "$title" "$result" "$elapsed"
  done

  success "Development stop workflow completed."
}

main() {
  parse_args "$@"

  section "Safety confirmation"
  warn "This stops development compute only."
  warn "It must never delete RDS, ECR, IAM, S3, DynamoDB, Terraform backend state, database data, or Docker images."
  confirm_or_exit "STOP_DEV" "Confirmation required before stopping development resources." "$CONFIRM_VALUE"

  run_recorded_step "Verify prerequisites and AWS authentication" verify_prerequisites
  run_recorded_step "Destroy terraform-platform" destroy_platform_layer
  run_recorded_step "Destroy EKS module" destroy_eks_compute
  run_recorded_step "Verify EKS removal" verify_eks_removal
  run_recorded_step "Detect and delete project orphan ALBs" detect_and_delete_project_albs
  run_recorded_step "Report remaining cost resources" report_remaining_resources
  print_summary
}

main "$@"
