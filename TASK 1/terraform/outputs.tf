output "node_role" {
    value = module.karpenter.node_iam_role_name  
    description = "Node's group IAM Name" 
}

output "cluster_name" {
    value = module.eks.cluster_name
    description = "EKS Cluster Name"
  
}

output "aws_region" {
    value = var.region
    description = "AWS Region"
}