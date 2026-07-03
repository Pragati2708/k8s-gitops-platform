#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

main() {
  require_cmd kubectl

  section "Cluster"
  kubectl cluster-info
  kubectl get nodes -o wide

  section "CoreDNS"
  kubectl get deployment coredns -n kube-system
  kubectl get pods -n kube-system -l k8s-app=kube-dns

  section "AWS Load Balancer Controller"
  kubectl get deployment aws-load-balancer-controller -n kube-system
  kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

  section "ArgoCD"
  kubectl get namespace argocd
  kubectl get pods -n argocd
  kubectl get svc -n argocd

  section "Application pods and services"
  kubectl get pods -A
  kubectl get svc -A

  success "Platform health check completed."
}

main "$@"
