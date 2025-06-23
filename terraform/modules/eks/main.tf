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
    }

    eks_managed_node_groups = {
    karpenter = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["m5.large"]

      min_size     = 2
      max_size     = 3
      desired_size = 2

      labels = {
        # Used to ensure Karpenter runs on nodes that it does not manage
        "karpenter.sh/controller" = "true"
      }
    }
    # Create a default node group (can be disabled)
    # eks_managed_node_groups = var.create_node_group ? {
    #     default = {
    #     instance_types = ["t3.medium"]
    #     min_size       = 1
    #     max_size       = 3
    #     desired_size   = 1
    #     subnet_ids     = var.private_subnet_ids
    #     }
    # } : {}

    # tags = var.tags

    }
}
