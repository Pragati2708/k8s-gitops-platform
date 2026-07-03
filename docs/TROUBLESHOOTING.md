# Troubleshooting

## AWS Authentication Fails

Run:

```bash
aws sts get-caller-identity
```

If this fails, refresh AWS credentials before running platform scripts.

## Cannot Connect to EKS

Run:

```bash
./infrastructure/scripts/02_connect-eks.sh
```

Then check:

```bash
kubectl get nodes
kubectl get pods -A
```

If the cluster is stopped, run the start workflow.

## Nodes Not Ready

Check:

```bash
kubectl describe nodes
kubectl get pods -n kube-system
```

Common causes include node group creation delays, networking issues, or image pull failures.

## AWS Load Balancer Controller Failing

Check:

```bash
kubectl get deployment aws-load-balancer-controller -n kube-system
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

Confirm the service account annotation references the expected IAM role.

## ArgoCD Not Ready

Check:

```bash
kubectl get pods -n argocd
kubectl describe pods -n argocd
```

If the namespace does not exist, the platform layer may not be applied.

## RDS Unreachable

Run:

```bash
./infrastructure/scripts/07_database-health.sh
```

Verify the DB instance status, VPC security group rules, and network path from the workload subnets.

## Unexpected AWS Cost

Run:

```bash
./infrastructure/scripts/04_check-cost.sh
./infrastructure/scripts/09_cleanup-report.sh
```

Look for running EC2 instances, ALBs, NAT gateways, Elastic IPs, unattached EBS volumes, and snapshots.
