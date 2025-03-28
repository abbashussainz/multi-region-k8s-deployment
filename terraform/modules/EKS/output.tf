output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS API server"
  value       = aws_eks_cluster.this.endpoint
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = aws_iam_openid_connect_provider.this.arn
}

output "worker_node_group_name" {
  description = "Name of the worker node group"
  value       = var.create_worker_nodes ? aws_eks_node_group.this[0].node_group_name : null
}

output "worker_node_role_arn" {
  description = "ARN of the worker node IAM role"
  value       = var.create_worker_nodes ? aws_iam_role.eks_node_role[0].arn : null
}