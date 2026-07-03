#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

main() {
  require_cmd aws
  require_cmd terraform
  check_aws_login

  section "Daily report"
  print_kv "Date UTC" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  print_kv "Region" "$AWS_REGION"
  print_kv "Cluster" "$CLUSTER_NAME"
  print_kv "Terraform" "$(terraform version | sed -n '1p')"
  if optional_cmd kubectl; then
    print_kv "Kubectl" "$(kubectl version --client=true 2>/dev/null | sed -n '1p')"
  else
    warn "kubectl not found."
  fi

  section "Running resources"
  "$(repo_path infrastructure/scripts/04_check-cost.sh)"

  section "Platform status"
  if optional_cmd kubectl && kubectl cluster-info >/dev/null 2>&1; then
    kubectl get nodes
    kubectl get pods -A
  else
    warn "Kubernetes API is not reachable from current kubeconfig."
  fi

  section "Estimated cost drivers"
  warn "Review EKS, EC2 nodes, NAT gateway, ALBs, Elastic IPs, unattached EBS volumes, and snapshots."

  success "Daily report completed."
}

main "$@"
