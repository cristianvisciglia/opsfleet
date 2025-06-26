variable "name" {
    description = "VPC name"
}

variable "cidr_block" {
    description = "VPC Cidr range"
}

variable "azs" {
    description = "AZ List"
    type = list(string)
}

variable "private_subnets" {
    type = list(string)
    default = []
}

variable "public_subnets" {
    type = list(string)
    default = []
}

variable "enable_natgw" {
    type = bool
    default = false
}

variable "single_natgw" {
    type = bool
    default = false
}

variable "private_subnet_names" {
    type = list(string)
    default = []
}

variable "public_subnet_names" {
    type = list(string)
    default = []
}

variable "cluster_name" {
    type = string
    description = "Cluster Name"
}

variable "tags" {
    type = map(string)  
    default = {}
}