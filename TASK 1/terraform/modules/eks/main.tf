# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = ">= 5.95.0, < 6.0.0"
#     }
#   }
# }
module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 20.37.1"

    cluster_name    = var.cluster_name
    cluster_version = var.cluster_version

    # Gives Terraform identity admin access to cluster which will
    # allow deploying resources (Karpenter) into the cluster
    enable_cluster_creator_admin_permissions = true
    # For testing pouporses
    cluster_endpoint_public_access           = true

    vpc_id          = var.vpc_id
    subnet_ids      = var.private_subnet_ids

    enable_irsa     = true

    # IAM roles for cluster and nodes
    iam_role_name            = "${var.cluster_name}-eks-role"
    iam_role_use_name_prefix = false
    create_iam_role          = true

    # EKS Addons 
    cluster_addons = {
        kube-proxy = {
            most_recent = true
        }
        vpc-cni = {
            most_recent = true
        }
        coredns = {
            most_recent = true
        }
        eks-pod-identity-agent = {
            most_recent = true
        }
    }

    eks_managed_node_groups = {
    karpenter = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.large"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      
      taints = {
        # This Taint aims to keep just EKS Addons and Karpenter running on this MNG
        # The pods that do not tolerate this taint should run on nodes created by Karpenter
        addons = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        },
      }
    
      labels = {
        "karpenter.sh/controller" = "true"
      }
    }
  }
  node_security_group_tags = {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
       "karpenter.sh/discovery" = "${var.cluster_name}"
  }
 
  tags = var.tags
}