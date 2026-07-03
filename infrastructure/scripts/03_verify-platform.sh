#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

main() {
  require_cmd kubectl

  section "Nodes"
  kubectl get nodes -o wide

  section "Pods"
  kubectl get pods -A

  section "Services"
  kubectl get svc -A

  section "Ingress"
  kubectl get ingress -A || warn "Ingress resources could not be listed."

  section "AWS Load Balancer Controller"
  kubectl get deployment aws-load-balancer-controller -n kube-system

  section "ArgoCD"
  kubectl get namespace argocd
  kubectl get pods -n argocd
  kubectl get svc -n argocd

  success "Platform verification completed."
}

main "$@"
