locals {
  service_repositories = [
    "frontend",
    "legacy-service",
    "transaction-service",
    "notification-service"
  ]
}

resource "aws_ecr_repository" "service" {
  for_each = toset(local.service_repositories)

  name                 = each.value
  image_tag_mutability = "MUTABLE"


  image_scanning_configuration {
    scan_on_push = true
  }


  lifecycle {
    prevent_destroy = true
  }


  tags = {
    Environment = "dev"
    Project     = "capstone"
    Service     = each.value
  }
}

resource "aws_ecr_lifecycle_policy" "service" {
  for_each = aws_ecr_repository.service

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep the last 20 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 20
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
