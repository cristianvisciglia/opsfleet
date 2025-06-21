data "aws_availability_zones" "available" {}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "6.0.0"

    name = var.name
    cidr = var.cidr_block

    azs                 = var.azs
    private_subnets     = var.private_subnets
    public_subnets      = var.public_subnets

    private_subnet_names = var.private_subnet_names
    public_subnet_names = var.public_subnet_names

    manage_default_network_acl    = true
    manage_default_route_table    = true
    manage_default_security_group = true

    enable_dns_hostnames = true
    enable_dns_support   = true

    enable_nat_gateway = false

    tags = var.tags
}