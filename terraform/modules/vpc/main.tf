module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "6.0.0"

    name = var.name
    cidr = var.cidr_block
}