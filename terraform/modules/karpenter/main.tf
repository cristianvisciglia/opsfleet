terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37"
    }
  }
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.37.1"

  cluster_name                    = var.cluster_name
  enable_v1_permissions           = true

  node_iam_role_use_name_prefix   = false
  create_iam_role = true
  node_iam_role_name              = "KarpenterNodeRole-${var.cluster_name}"
  create_instance_profile = true
  create_pod_identity_association = true

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = var.tags
}

resource "aws_iam_policy" "karpenter_controller_pass_role" {
  name        = "KarpenterControllerPassRole-${var.cluster_name}"
  description = "Additional policy for Karpenter Controller to pass roles"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          module.karpenter.node_iam_role_arn,
          "arn:aws:iam::*:role/KarpenterNodeRole-*"
        ]
      }
    ]
  })

  tags = var.tags
}

# Adjuntar la política adicional al rol del controlador de Karpenter
resource "aws_iam_role_policy_attachment" "karpenter_controller_pass_role" {
  policy_arn = aws_iam_policy.karpenter_controller_pass_role.arn
  role       = module.karpenter.iam_role_name
}


resource "helm_release" "karpenter" {
  namespace        = "kube-system"
  create_namespace = false

  name                       = "karpenter"
  repository                 = "oci://public.ecr.aws/karpenter"
  repository_username        = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password        = data.aws_ecrpublic_authorization_token.token.password
  chart                      = "karpenter"
  disable_openapi_validation = true
  wait                       = false
  skip_crds                  = false

  values = [
    <<-EOT
    serviceAccount:
      name: ${module.karpenter.service_account}
      annotations: {
        eks.amazonaws.com/role-arn: ${module.karpenter.iam_role_arn}
      }
    settings:
      clusterName: ${var.cluster_name}
      clusterEndpoint: ${var.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
      aws:
        defaultInstanceProfile: ${module.karpenter.instance_profile_name}
    EOT
  ]
  
  depends_on = [module.karpenter]

}