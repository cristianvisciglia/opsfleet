variable "region" {
    default = "us-east-1"
    description = "AWS deploy region"
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnet CIDRs"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnet CIDRs"
}

variable "project" {
    type = string
    description = "Project Name"
}

variable "env" {
    type = string
    description = "Project Environment"
}

variable "tags" {
    type = map(string)
}
