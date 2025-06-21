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
  
  private_subnet_names = ["${local.name_prefix}-private-subnet"]
  public_subnet_names = ["${local.name_prefix}-public-subnet"]
  
  
}