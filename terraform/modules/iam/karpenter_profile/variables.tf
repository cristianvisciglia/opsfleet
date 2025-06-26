variable "role_name" {
  description = "IAM Role name for Nodes managed by Karpenter"
  type        = string
  default     = "KarpenterNodeRole"
}

variable "tags" {
  description = "tags"
  type        = map(string)
  default     = {}
}
