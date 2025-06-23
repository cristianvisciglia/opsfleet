variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "cluster_version" {
  description = "Cluster Version"
  type        = string
  default     = "1.32"
}

variable "vpc_id" {
  description = "Vpc ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "EKS private subnet list"
  type        = list(string)
}

variable "create_node_group" {
  description = "Create default Nodegroup"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Resources Tags"
  type        = map(string)
  default     = {}
}