data "aws_eks_cluster" "cluster" {
  name = "capstone-eks"
}


data "aws_eks_cluster_auth" "cluster" {
  name = "capstone-eks"
}


data "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}