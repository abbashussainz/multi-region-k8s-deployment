resource "aws_eks_node_group" "this" {
  count = var.create_worker_nodes ? 1 : 0

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.worker_node_group_name # Customizable name
  node_role_arn   = aws_iam_role.eks_node_role[0].arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.worker_desired_size
    max_size     = var.worker_max_size
    min_size     = var.worker_min_size
  }

  instance_types = var.worker_instance_types
  ami_type       = var.worker_ami_type
  disk_size      = var.worker_disk_size

  tags = var.tags
}
