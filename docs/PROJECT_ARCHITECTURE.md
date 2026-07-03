# Project Architecture

## Overview

The platform runs containerized banking services on Amazon EKS. Terraform manages AWS infrastructure, Helm installs platform components, and ArgoCD manages application delivery through GitOps.

## Infrastructure Layers

### Foundational Infrastructure

Directory: `infrastructure/terraform/terraform-infra/`

Responsibilities:

- VPC, subnets, route tables, internet gateway, NAT gateway, DNS support, and tags.
- Amazon EKS cluster and managed node group.
- Amazon RDS PostgreSQL database.
- Amazon ECR repositories.
- GitHub OIDC provider and IAM role for CI/CD.
- Terraform outputs and variables.

The Terraform backend is S3 with DynamoDB locking. Backend configuration must not be changed without an explicit migration plan.

### Platform Add-ons

Directory: `infrastructure/terraform/terraform-platform/`

Responsibilities:

- AWS Load Balancer Controller IAM role for service accounts.
- AWS Load Balancer Controller Helm release.
- ArgoCD namespace.
- ArgoCD Helm release.

This layer depends on the EKS cluster already existing.

### Application Delivery

Directories:

- `apps/`
- Separate repository: `k8s-gitops-config`

Responsibilities:

- Application source and Docker images live in this monorepo.
- Kubernetes application configuration, Helm chart values, and ArgoCD
  application definitions remain in the separate GitOps repository.

## Stateful Systems

The following resources are stateful and must be protected:

- PostgreSQL RDS instance and database contents.
- Amazon ECR repositories and images.
- Terraform state and lock tables.
- IAM and GitHub OIDC integration.

## Compute Systems

The following resources are cost drivers and may be stopped during daily development:

- EKS control plane and node group.
- Worker EC2 instances.
- Kubernetes workloads.
- AWS Load Balancer Controller resources.
- ArgoCD.
- Application load balancers created for development workloads.

## Terraform Organization

`infrastructure/terraform/terraform-infra/main.tf` is an entrypoint placeholder. Active infrastructure is split by responsibility:

- `networking.tf`: VPC, subnet, routing, NAT, DNS, and tags.
- `eks.tf`: EKS cluster and managed node group.
- `rds.tf`: PostgreSQL database, DB subnet group, and RDS security group.
- `ecr.tf`: ECR repositories and lifecycle policy.
- `github-oidc.tf`: GitHub OIDC and CI/CD IAM role.
- `random.tf`: Random password resource.
- `output.tf`: Existing outputs.
- `variables.tf`: Existing variables.
