# IAM Role for AWS Load Balancer Controller using IRSA

module "load_balancer_controller_irsa" {

  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  version = "~> 5.0"


  role_name = "capstone-alb-controller"


  attach_load_balancer_controller_policy = true


  oidc_providers = {

    main = {

      provider_arn = data.aws_iam_openid_connect_provider.eks.arn


      namespace_service_accounts = [

        "kube-system:aws-load-balancer-controller"

      ]

    }

  }

}



# Install AWS Load Balancer Controller using Helm

resource "helm_release" "aws_load_balancer_controller" {


  name = "aws-load-balancer-controller"


  repository = "https://aws.github.io/eks-charts"


  chart = "aws-load-balancer-controller"


  namespace = "kube-system"



  set = [

    {

      name = "clusterName"

      value = data.aws_eks_cluster.cluster.name

    },


    {

      name = "serviceAccount.create"

      value = "true"

    },


    {

      name = "serviceAccount.name"

      value = "aws-load-balancer-controller"

    },


    {

      name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"


      value = module.load_balancer_controller_irsa.iam_role_arn

    }

  ]


  depends_on = [

    module.load_balancer_controller_irsa

  ]

}