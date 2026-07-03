# Cost Optimization

## Goal

Reduce daily development cost while preserving all data, images, IAM configuration, Terraform state, and backend resources.

## Primary Cost Drivers

- EKS cluster control plane.
- Managed node group EC2 instances.
- NAT gateway.
- Application load balancers.
- Orphan target groups, listener rules, and ENIs.
- Elastic IPs.
- EBS volumes and snapshots.

## Protected Resources

The following must not be destroyed by daily cost workflows:

- Amazon RDS PostgreSQL.
- PostgreSQL data, schema, and tables.
- Amazon ECR repositories and Docker images.
- Terraform S3 backend.
- Terraform DynamoDB lock tables.
- Terraform state.
- IAM roles and policies.
- GitHub OIDC.

## Daily Stop Strategy

The daily stop workflow should:

- Remove or scale down Kubernetes workloads.
- Destroy only platform and EKS compute resources when explicitly intended.
- Report orphaned load balancer resources.
- Delete orphaned ALB resources only when they are clearly associated with the development cluster.
- Avoid all database, ECR, IAM, backend, and stateful operations.

## Daily Start Strategy

The daily start workflow should:

- Apply the EKS infrastructure layer.
- Update kubeconfig.
- Apply the platform layer.
- Verify nodes, CoreDNS, AWS Load Balancer Controller, and ArgoCD.
- Print a readiness summary.

## Reporting

Use:

```bash
./infrastructure/scripts/04_check-cost.sh
./infrastructure/scripts/09_cleanup-report.sh
./infrastructure/scripts/10_daily-report.sh
```

Review cleanup reports before deleting resources.
