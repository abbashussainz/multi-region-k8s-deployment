# Host cluster (Karmada)
data "aws_eks_cluster" "karmada_host" {
  name     = var.karmada_host_cluster_name
  provider = aws.karmada_host
}

data "aws_eks_cluster_auth" "karmada_host" {
  name     = var.karmada_host_cluster_name
  provider = aws.karmada_host
}

# Member Cluster 1
data "aws_eks_cluster" "member_1" {
  name     = var.member_clusters["member_1"].cluster_name
  provider = aws.member_1
}

data "aws_eks_cluster_auth" "member_1" {
  name     = var.member_clusters["member_1"].cluster_name
  provider = aws.member_1
}

# Member Cluster 2
data "aws_eks_cluster" "member_2" {
  name     = var.member_clusters["member_2"].cluster_name
  provider = aws.member_2
}

data "aws_eks_cluster_auth" "member_2" {
  name     = var.member_clusters["member_2"].cluster_name
  provider = aws.member_2
}

# Member Cluster 3
data "aws_eks_cluster" "member_3" {
  name     = var.member_clusters["member_3"].cluster_name
  provider = aws.member_3
}

data "aws_eks_cluster_auth" "member_3" {
  name     = var.member_clusters["member_3"].cluster_name
  provider = aws.member_3
}
