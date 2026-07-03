# Banking DevOps Platform Workspace Notes

This document was migrated from the previous local workspace root.

The enterprise monorepo now lives in `k8s-gitops-platform` and owns:

- Application source under `apps/`
- Docker build inputs
- GitHub Actions workflows
- Terraform infrastructure under `infrastructure/terraform/`
- Operational scripts under `infrastructure/scripts/`
- Documentation under `docs/`

The separate `k8s-gitops-config` repository remains outside this monorepo and
continues to own ArgoCD Applications, Helm deployment configuration, and
Kubernetes desired state.

## Safety Principles

- Preserve PostgreSQL data, schema, and tables.
- Preserve ECR repositories and Docker images.
- Preserve Terraform state, backend S3 bucket, and DynamoDB lock tables.
- Preserve IAM roles, policies, and GitHub OIDC.
- Stop only development compute resources when reducing cost.
- Avoid broad destructive commands.

## Daily Development Workflow

Use the scripts in `infrastructure/scripts/` for normal operations:

```bash
./infrastructure/scripts/01_check-environment.sh
./infrastructure/scripts/04_check-cost.sh
./infrastructure/scripts/05_stop-development.sh
./infrastructure/scripts/06_start-development.sh
```

The stop workflow is intentionally conservative. It targets platform and compute
resources while protecting RDS, ECR, IAM, backend state, and database data.
