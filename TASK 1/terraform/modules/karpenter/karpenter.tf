# resource "kubernetes_manifest" "nodeclass_x86" {
#   manifest = yamldecode(templatefile("${path.module}/templates/x86-nodeclass.yaml.tmpl", {
#     cluster_name       = var.cluster_name
#     node_iam_role_name = module.karpenter.node_iam_role_name
#   }))
  
#   depends_on = [helm_release.karpenter]
# }

# resource "kubernetes_manifest" "nodeclass_arm64" {
#   manifest = yamldecode(templatefile("${path.module}/templates/graviton-nodeclass.yaml.tmpl", {
#     cluster_name       = var.cluster_name
#     node_iam_role_name = module.karpenter.node_iam_role_name
#   }))
  
#   depends_on = [helm_release.karpenter]
# }

# # Luego crear los NodePools que dependen de las NodeClasses
# resource "kubernetes_manifest" "nodepool_x86" {
#   manifest = yamldecode(templatefile("${path.module}/templates/x86-nodepool.yaml.tmpl", {
#     cluster_name = var.cluster_name
#   }))
  
#   depends_on = [kubernetes_manifest.nodeclass_x86]
# }

# resource "kubernetes_manifest" "nodepool_arm64" {
#   manifest = yamldecode(templatefile("${path.module}/templates/graviton-nodepool.yaml.tmpl", {
#     cluster_name = var.cluster_name
#   }))
  
#   depends_on = [kubernetes_manifest.nodeclass_arm64]
# }