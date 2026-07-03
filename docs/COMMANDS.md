# Commands

## Terraform Infrastructure

```bash
cd infrastructure/terraform/terraform-infra
terraform init
terraform plan
terraform apply
```

Use targeted operations only with care. Never target RDS, ECR, IAM, backend, or stateful resources for destruction.

## Terraform Platform

```bash
cd infrastructure/terraform/terraform-platform
terraform init
terraform plan
terraform apply
```

The platform layer requires the EKS cluster to exist.

## Kubernetes

```bash
aws eks update-kubeconfig --region ap-south-1 --name capstone-eks
kubectl get nodes
kubectl get pods -A
kubectl get svc -A
kubectl get ingress -A
```

## ArgoCD

```bash
kubectl get pods -n argocd
kubectl get svc -n argocd
```

## AWS Load Balancer Controller

```bash
kubectl get deployment aws-load-balancer-controller -n kube-system
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

## Cost Inspection

```bash
aws eks list-clusters --region ap-south-1
aws ec2 describe-instances --region ap-south-1 --filters Name=instance-state-name,Values=running
aws elbv2 describe-load-balancers --region ap-south-1
aws ec2 describe-nat-gateways --region ap-south-1
aws rds describe-db-instances --region ap-south-1
aws ecr describe-repositories --region ap-south-1
```

Prefer the repository scripts for repeatable checks.
