terraform {
  # Terraform and provider constraints are intentionally conservative for the
  # existing production-style EKS infrastructure.

  required_version = ">= 1.3.0"


  required_providers {

    aws = {

      source = "hashicorp/aws"

      version = "~> 5.0"

    }

  }

}


provider "aws" {

  # Region is supplied by variables.tf to keep the deployment location explicit.
  region = var.region

}
