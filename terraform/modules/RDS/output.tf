output "cluster_id" {
  description = "The ID of the Aurora cluster"
  value       = var.is_primary ? aws_rds_cluster.primary[0].id : aws_rds_cluster.secondary[0].id
}

output "cluster_endpoint" {
  description = "The endpoint of the Aurora cluster"
  value       = var.is_primary ? aws_rds_cluster.primary[0].endpoint : aws_rds_cluster.secondary[0].endpoint
}

output "reader_endpoint" {
  description = "The reader endpoint of the Aurora cluster"
  value       = var.is_primary ? aws_rds_cluster.primary[0].reader_endpoint : aws_rds_cluster.secondary[0].reader_endpoint
}

output "instance_endpoints" {
  description = "Endpoints of all instances in the Aurora cluster"
  value       = var.is_primary ? aws_rds_cluster_instance.primary_instances[*].endpoint : aws_rds_cluster_instance.secondary_instances[*].endpoint
}
