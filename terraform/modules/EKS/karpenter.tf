module "karpenter" {
  count  = var.enable_karpenter ? 1 : 0
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name           = aws_eks_cluster.this.name
  irsa_oidc_provider_arn = aws_iam_openid_connect_provider.this.arn

  enable_irsa = "true"
  
  node_iam_role_arn = aws_iam_role.eks_node_role[0].arn
  create_node_iam_role = false

  create_access_entry  = false
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}



resource "aws_security_group" "karpentersg" {
  name        = "karpenter-traffic"
  description = "Security group allowing inbound and outbound traffic"
  vpc_id      = var.vpc_id # Replace with your VPC ID

  # Allow all inbound traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "karpenter.sh/discovery" = "k8s"
  }
}



# Add to karpenter.tf
resource "helm_release" "karpenter" {
  count      = var.enable_karpenter ? 1 : 0
  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "0.16.3"
  namespace  = "karpenter"
  create_namespace = true

  set {
    name  = "serviceMonitor.enabled"
    value = "False"
  }

  set {
    name  = "clusterName"
    value = aws_eks_cluster.this.name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter[0].iam_role_arn
  }


  set {
    name  = "clusterEndpoint"
    value = aws_eks_cluster.this.endpoint
  }

  set {
    name  = "settings.interruptionQueueName"
    value = module.karpenter[0].queue_name
  }

  set {
    name  = "settings.featureGates.drift"
    value = "True"
  }

  depends_on = [module.karpenter[0]]
}