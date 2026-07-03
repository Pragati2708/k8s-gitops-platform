output "cluster_name" {
  # EKS cluster name exported for operators and downstream platform tooling.
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  # Kubernetes API endpoint for the existing EKS cluster.
  value = module.eks.cluster_endpoint
}

output "ecr_repository_urls" {
  # Service-to-ECR repository URL map used by build and deployment workflows.
  value = {
    for name, repo in aws_ecr_repository.service : name => repo.repository_url
  }
}
output "github_actions_role_arn" {

  # IAM role ARN assumed by GitHub Actions through OIDC.
  value = aws_iam_role.github_actions.arn

}
output "rds_endpoint" {

  # RDS PostgreSQL endpoint consumed by application services.
  value = aws_db_instance.banking.endpoint
}

output "db_password" {

  # Generated database password. Sensitive output remains hidden by Terraform.
  value = random_password.db_password.result

  sensitive = true
}
