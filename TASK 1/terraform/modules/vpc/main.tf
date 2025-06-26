terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.95.0, < 6.0.0"
    }
  }
}

data "aws_availability_zones" "available" {}

module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "5.21.0"

    name = var.name
    cidr = var.cidr_block

    azs                 = var.azs
    private_subnets     = var.private_subnets
    public_subnets      = var.public_subnets

    private_subnet_names = var.private_subnet_names
    public_subnet_names  = var.public_subnet_names

    manage_default_network_acl    = true
    manage_default_route_table    = true
    manage_default_security_group = true

    enable_dns_hostnames = true
    enable_dns_support   = true

    enable_nat_gateway = var.enable_natgw
    single_nat_gateway = var.single_natgw

    public_subnet_tags = {
      "kubernetes.io/role/elb" = 1
    }

    private_subnet_tags = {
      "kubernetes.io/role/internal-elb" = 1
      # Tags subnets for Karpenter auto-discovery
      "karpenter.sh/discovery" = var.cluster_name
    }

    tags = var.tags
}