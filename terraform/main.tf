provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"

  name       = var.name
  cidr_block = var.vpc_cidr
  azs        = var.azs
  ...
}