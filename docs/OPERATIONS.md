# Operations

## Operating Model

This project supports a daily development mode:

- Start infrastructure in the morning.
- Work against EKS, ArgoCD, and application workloads.
- Stop expensive compute resources in the evening.
- Preserve all stateful systems.

## Golden Rules

- Do not run `terraform destroy` broadly.
- Do not modify Terraform backend configuration.
- Do not delete RDS, ECR, IAM, S3 backend, DynamoDB lock tables, or Terraform state.
- Do not delete PostgreSQL data, schema, or tables.
- Do not delete Docker images.
- Do not change cluster, database, repository, role, or resource names.

## Environment Check

```bash
./infrastructure/scripts/01_check-environment.sh
```

This verifies required tools and AWS authentication before operational commands.

## Connect to EKS

```bash
./infrastructure/scripts/02_connect-eks.sh
```

This updates kubeconfig for the configured cluster and verifies connectivity.

## Verify Platform

```bash
./infrastructure/scripts/03_verify-platform.sh
./infrastructure/scripts/08_platform-health.sh
```

These checks inspect nodes, pods, services, ingress, ArgoCD, and the AWS Load Balancer Controller.

## Check Costs

```bash
./infrastructure/scripts/04_check-cost.sh
./infrastructure/scripts/10_daily-report.sh
```

These scripts report active AWS resources and likely cost drivers.

## Stop Development Resources

```bash
./infrastructure/scripts/05_stop-development.sh
```

This workflow is intended to reduce compute cost. It must preserve RDS, ECR, IAM, backend state, and database data.

## Start Development Resources

```bash
./infrastructure/scripts/06_start-development.sh
```

This recreates the EKS/platform layer required for development and verifies readiness.

## Database Health

```bash
./infrastructure/scripts/07_database-health.sh
```

This checks database status and network reachability signals without modifying database data.
