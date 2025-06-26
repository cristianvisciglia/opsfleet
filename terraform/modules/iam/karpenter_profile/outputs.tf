output "role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.karpenter_nodes.arn
}

output "instance_profile_name" {
  description = "Instance profile name"
  value       = aws_iam_instance_profile.karpenter.name
}
