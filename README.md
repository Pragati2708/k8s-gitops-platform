# Banking DevOps Platform Monorepo

Enterprise monorepo for the banking platform application code, Docker build
inputs, local operations scripts, Terraform infrastructure, and documentation.

The GitOps repository remains separate at `k8s-gitops-config`. ArgoCD
deployment configuration and Kubernetes desired state are not merged into this
repository.

## Contents

- `apps/frontend/`: React/Vite frontend application.
- `apps/legacy-service/`: Legacy Node.js service.
- `apps/notification-service/`: Notification Node.js service.
- `apps/transaction-service/`: Transaction Node.js service.
- `infrastructure/terraform/terraform-infra/`: AWS VPC, EKS, RDS, ECR, IAM, and GitHub OIDC Terraform.
- `infrastructure/terraform/terraform-platform/`: AWS Load Balancer Controller and ArgoCD Terraform.
- `infrastructure/scripts/`: Operational scripts for environment, cost, health, start, and stop workflows.
- `docs/`: Architecture, operations, commands, cost, troubleshooting, and project context.
- `policies/`: Reserved for repository and platform policy documents.
- `gitops/helm/`: Reserved for platform-owned Helm references that are not ArgoCD desired state.
- `monitoring/`: Reserved for platform-owned monitoring references that are not GitOps deployment configuration.
- `docker-compose.yml`: Local multi-service development entrypoint.
- `.github/workflows/`: Build and publish workflow definitions.
- `Makefile`: Local convenience commands.

## Operating Notes

This repository owns application code and Docker build inputs. Kubernetes
deployment intent is managed separately in `k8s-gitops-config`.

Do not change service ports, Dockerfiles, workflow names, image names, Terraform
backend keys, Terraform outputs, provider constraints, IAM names, ECR names, RDS
settings, or API behavior as part of repository cleanup.

Generated dependencies, local Terraform working directories, local state copies,
build outputs, logs, and machine-specific files should stay out of future
commits unless there is an explicit reason to vendor them.
