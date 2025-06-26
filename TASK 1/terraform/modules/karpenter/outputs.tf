output "node_iam_role_name" {
  description = "Name of the Karpenter node IAM role"
  value       = module.karpenter.node_iam_role_name
}

output "node_iam_role_arn" {
  description = "ARN of the Karpenter node IAM role"
  value       = module.karpenter.node_iam_role_arn
}

output "instance_profile_name" {
  description = "Name of the Karpenter instance profile"
  value       = module.karpenter.instance_profile_name
}