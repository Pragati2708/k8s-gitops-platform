# This file has intentionally been kept for backward compatibility.
#
# Infrastructure resources were split into focused files:
# - networking.tf: VPC, subnets, routing, NAT, DNS, and tags
# - eks.tf: EKS cluster and managed node group
#
# Terraform loads all *.tf files in this directory as one module, so resource
# addresses and state bindings remain unchanged.
