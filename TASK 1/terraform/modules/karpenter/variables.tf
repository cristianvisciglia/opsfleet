variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  type        = string
}

variable "iam_role_name" {
    description = "IAM Role Name"
    type = string
}

variable "tags" {
  description = "tags"
  type        = map(string)
  default     = {}
}
