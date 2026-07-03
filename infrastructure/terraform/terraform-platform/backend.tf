terraform {

  # Platform add-ons use the existing S3 backend and DynamoDB lock table.
  # Keep these values stable unless intentionally migrating Terraform state.
  backend "s3" {

    bucket = "capstone-eks-terraform-state-2708"

    key = "platform/terraform.tfstate"

    region = "ap-south-1"

    dynamodb_table = "terraform-lock-table"

  }

}
