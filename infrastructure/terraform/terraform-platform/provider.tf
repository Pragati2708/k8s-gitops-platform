terraform {

  # Required providers are scoped to the current platform add-ons:
  # AWS, Kubernetes, and Helm.
  required_version = ">= 1.3.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    helm = {
      source = "hashicorp/helm"
    }

  }
}


provider "aws" {
  # Platform resources are deployed into the existing Mumbai region.
  region = "ap-south-1"
}


provider "kubernetes" {

  # Kubernetes provider connects to the existing EKS cluster via AWS auth data.
  host = data.aws_eks_cluster.cluster.endpoint

  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.cluster.certificate_authority[0].data
  )

  token = data.aws_eks_cluster_auth.cluster.token

}


provider "helm" {

  # Helm provider uses the same EKS connection details as the Kubernetes provider.
  kubernetes = {

    host = data.aws_eks_cluster.cluster.endpoint

    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.cluster.certificate_authority[0].data
    )

    token = data.aws_eks_cluster_auth.cluster.token

  }

}
