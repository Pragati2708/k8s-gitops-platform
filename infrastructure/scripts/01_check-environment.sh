#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

main() {
  section "Environment"
  print_kv "Repository" "$REPO_ROOT"
  print_kv "AWS region" "$AWS_REGION"
  print_kv "EKS cluster" "$CLUSTER_NAME"

  section "Required commands"
  for cmd in terraform aws kubectl docker helm; do
    require_cmd "$cmd"
    success "$cmd found at $(command -v "$cmd")"
  done

  section "Versions"
  terraform version | sed -n '1p'
  aws --version
  kubectl version --client=true
  docker --version
  helm version --short

  section "AWS login"
  check_aws_login
  aws sts get-caller-identity --query '{Account:Account,Arn:Arn,UserId:UserId}' --output table

  success "Environment check completed."
}

main "$@"
