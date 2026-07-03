variable "region" {
  # Primary AWS region for all infrastructure in this Terraform module.
  default = "ap-south-1"
}

variable "cluster_name" {
  # Existing EKS cluster name. Keep stable to avoid resource replacement.
  default = "capstone-eks"
}
