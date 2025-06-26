output "cluster_name" {
  description = "Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes api endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Kubernetes CA (base64)"
  value       = module.eks.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  description = "OIDC ARN cluster provider"
  value       = module.eks.oidc_provider_arn
}

output "worker_iam_role_arn" {
  description = "Node's group IAM ARN"
  value       = try(module.eks.eks_managed_node_groups["default"].iam_role_arn, null)
}

output "iam_role_name" {
  description = "value"
  value = module.eks.eks_managed_node_groups["karpenter"].iam_role_name
}