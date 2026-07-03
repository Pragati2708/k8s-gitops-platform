terraform {
  # Remote state is stored in the existing S3 backend and locked with DynamoDB.
  # Do not change these values unless intentionally migrating Terraform state.
  backend "s3" {

    bucket = "capstone-eks-terraform-state-2708"

    key = "eks/terraform.tfstate"

    region = "ap-south-1"

    dynamodb_table = "capstone-eks-terraform-lock"

    encrypt = true
  }
}
