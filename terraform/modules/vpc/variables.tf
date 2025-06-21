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

variable "private_subnet_names" {
    type = list(string)
    default = []
}

variable "public_subnet_names" {
    type = list(string)
    default = []
}

variable "tags" {
    type = map(string)  
    default = {}
}