locals {
  name_prefix = "${var.project}-${var.env}"
}

provider "aws" {
  region = var.region
 }

data "aws_availability_zones" "available" {
    #Exclude local azs
    filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source = "./modules/vpc"

  name       = "${local.name_prefix}-vpc"
  cidr_block = var.cidr_block
  
  azs        = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = var.private_subnets
  public_subnets = var.public_subnets

  enable_natgw = true
  single_natgw = true #Nonprod, testing
  
  private_subnet_names = ["${local.name_prefix}-private-subnet"]
  public_subnet_names = ["${local.name_prefix}-public-subnet"]

  cluster_name = "${var.env}-${var.project}-cluster"
  
}

module "eks" {
    source = "./modules/eks"

    cluster_name = "${var.env}-${var.project}-cluster"
    vpc_id = module.vpc.vpc_id
    private_subnet_ids = module.vpc.private_subnet_ids
    cluster_version = "1.32"

}

provider "kubernetes" {
  alias = "karpenter"
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "helm" {
  alias  = "karpenter"
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

module "karpenter" {
    source = "./modules/karpenter"
    cluster_name = module.eks.cluster_name
    cluster_endpoint = module.eks.cluster_endpoint
    iam_role_name = module.eks.iam_role_name

    providers = {
      kubernetes = kubernetes.karpenter
      helm = helm.karpenter
    }

}
