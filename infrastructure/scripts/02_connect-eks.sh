#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

main() {
  require_cmd aws
  require_cmd kubectl
  check_aws_login

  section "Kubeconfig"
  update_kubeconfig

  section "Cluster"
  aws_cli eks describe-cluster --name "$CLUSTER_NAME" --query 'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint}' --output table

  section "Nodes"
  kubectl get nodes -o wide

  success "EKS connection verified."
}

main "$@"
