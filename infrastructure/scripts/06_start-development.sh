#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

STEP_RESULTS=()

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
  local cmd
  for cmd in aws terraform kubectl helm docker; do
    require_cmd "$cmd"
    log "$cmd found at $(command -v "$cmd")"
  done

  terraform version | sed -n '1p'
  aws --version
  kubectl version --client=true
  helm version --short
  docker --version
}

verify_aws_authentication() {
  check_aws_login
  aws sts get-caller-identity --query '{Account:Account,Arn:Arn,UserId:UserId}' --output table
}

rds_status() {
  aws_cli rds describe-db-instances \
    --db-instance-identifier "$RDS_INSTANCE_ID" \
    --query 'DBInstances[0].DBInstanceStatus' \
    --output text 2>/dev/null
}

wait_for_rds_status() {
  local desired="$1"
  local status

  while true; do
    status="$(rds_status || true)"
    printf 'RDS %s status: %s\n' "$RDS_INSTANCE_ID" "${status:-not-found}"

    if [[ "$status" == "$desired" ]]; then
      return 0
    fi

    sleep 30
  done
}

detect_and_start_rds() {
  local status
  status="$(rds_status || true)"

  if [[ -z "$status" || "$status" == "None" ]]; then
    step_warning "RDS instance ${RDS_INSTANCE_ID} was not found. Continuing without changing database resources."
    return 0
  fi

  print_kv "RDS instance" "$RDS_INSTANCE_ID"
  print_kv "Current status" "$status"

  case "$status" in
    available)
      log "RDS is already available."
      ;;
    stopped)
      log "Starting stopped RDS instance ${RDS_INSTANCE_ID}."
      aws_cli rds start-db-instance --db-instance-identifier "$RDS_INSTANCE_ID" >/dev/null
      wait_for_rds_status "available"
      ;;
    starting|backing-up|modifying|configuring-enhanced-monitoring)
      step_warning "RDS is already transitioning; waiting until it becomes available."
      wait_for_rds_status "available"
      ;;
    stopping)
      step_warning "RDS is stopping; waiting for stopped, then starting it again."
      wait_for_rds_status "stopped"
      aws_cli rds start-db-instance --db-instance-identifier "$RDS_INSTANCE_ID" >/dev/null
      wait_for_rds_status "available"
      ;;
    *)
      step_warning "RDS status is ${status}. No start action was taken."
      ;;
  esac
}

eks_status() {
  aws_cli eks describe-cluster \
    --name "$CLUSTER_NAME" \
    --query 'cluster.status' \
    --output text 2>/dev/null
}

apply_eks_if_required() {
  local status
  local infra_dir

  infra_dir="$(repo_path infrastructure/terraform/terraform-infra)"
  status="$(eks_status || true)"

  if [[ "$status" == "ACTIVE" ]]; then
    log "EKS cluster ${CLUSTER_NAME} is already ACTIVE. Skipping terraform-infra apply."
    return 0
  fi

  if [[ -z "$status" || "$status" == "None" ]]; then
    step_warning "EKS cluster ${CLUSTER_NAME} is not present. Applying terraform-infra target module.eks."
  else
    step_warning "EKS cluster ${CLUSTER_NAME} status is ${status}. Applying terraform-infra target module.eks."
  fi

  terraform -chdir="$infra_dir" apply -target=module.eks -auto-approve
}

wait_for_ready_nodes() {
  kubectl wait --for=condition=Ready nodes --all --timeout=600s
  kubectl get nodes -o wide
}

deploy_platform() {
  terraform -chdir="$(repo_path infrastructure/terraform/terraform-platform)" apply -auto-approve
}

verify_alb_controller() {
  kubectl rollout status deployment/aws-load-balancer-controller -n kube-system --timeout=300s
  kubectl get deployment aws-load-balancer-controller -n kube-system
}

verify_argocd() {
  kubectl rollout status deployment/argocd-server -n argocd --timeout=300s
  kubectl get pods -n argocd
}

verify_coredns() {
  kubectl rollout status deployment/coredns -n kube-system --timeout=300s
  kubectl get deployment coredns -n kube-system
}

print_summary() {
  section "Final summary"
  print_kv "Repository" "$REPO_ROOT"
  print_kv "AWS region" "$AWS_REGION"
  print_kv "EKS cluster" "$CLUSTER_NAME"
  print_kv "RDS instance" "$RDS_INSTANCE_ID"

  printf '\n%-38s %-10s %s\n' "Step" "Result" "Elapsed Time"
  printf '%-38s %-10s %s\n' "----" "------" "------------"

  local entry
  for entry in "${STEP_RESULTS[@]}"; do
    IFS='|' read -r title result elapsed <<<"$entry"
    printf '%-38s %-10s %s\n' "$title" "$result" "$elapsed"
  done

  success "Development platform start workflow completed."
}

main() {
  run_recorded_step "Verify prerequisites" verify_prerequisites
  run_recorded_step "Verify AWS authentication" verify_aws_authentication
  run_recorded_step "Detect and start RDS if stopped" detect_and_start_rds
  run_recorded_step "Apply terraform-infra for EKS if required" apply_eks_if_required
  run_recorded_step "Update kubeconfig" update_kubeconfig
  run_recorded_step "Verify nodes Ready" wait_for_ready_nodes
  run_recorded_step "Deploy terraform-platform" deploy_platform
  run_recorded_step "Verify ALB Controller" verify_alb_controller
  run_recorded_step "Verify ArgoCD" verify_argocd
  run_recorded_step "Verify CoreDNS" verify_coredns
  print_summary
}

main "$@"
