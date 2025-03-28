terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

variable "thanos_host_cluster" {
  type = object({
    name   = string
    region = string
  })
  default = {
    name   = "k8s-cluster-us-east-1"
    region = "us-east-1"
  }
}

variable "member_clusters" {
  type = map(object({
    cluster_name = string
    region       = string
  }))
  default = {
    member_1 = { cluster_name = "k8s-cluster-us-east-1", region = "us-east-1" }
    member_2 = { cluster_name = "k8s-cluster-eu-west-1", region = "eu-west-1" }
    member_3 = { cluster_name = "k8s-cluster-ap-southeast-1", region = "ap-southeast-1" }
  }
}

provider "aws" {
  alias  = "host_region"
  region = var.thanos_host_cluster.region
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "thanos_storage" {
  provider = aws.host_region
  bucket   = "thanos-storage-${data.aws_caller_identity.current.account_id}"
  force_destroy = false

  tags = {
    Name = "Thanos Storage"
  }
}

resource "aws_s3_bucket_versioning" "thanos_versioning" {
  provider = aws.host_region
  bucket   = aws_s3_bucket.thanos_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_eks_cluster" "host" {
  provider = aws.host_region
  name     = var.thanos_host_cluster.name
}

data "aws_eks_cluster_auth" "host" {
  provider = aws.host_region
  name     = var.thanos_host_cluster.name
}

resource "aws_iam_role" "thanos_s3_access" {
  provider = aws.host_region
  name     = "thanos-s3-access-${var.thanos_host_cluster.name}"

  assume_role_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.host.identity[0].oidc[0].issuer, "https://", "")}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
    }
  ]
  })

}

resource "aws_iam_role_policy_attachment" "thanos_s3_policy" {
  provider   = aws.host_region
  role       = aws_iam_role.thanos_s3_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

provider "kubernetes" {
  alias                  = "host"
  host                   = data.aws_eks_cluster.host.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.host.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.host.token
}

provider "helm" {
  alias = "host"
  kubernetes {
    host                   = data.aws_eks_cluster.host.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.host.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.host.token
  }
}

resource "helm_release" "thanos" {
  provider   = helm.host
  name       = "thanos"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "thanos"
  version    = "12.7.0"
  namespace  = "monitoring"
  create_namespace = true

  set {
    name  = "receiver.enabled"
    value = "true"
  }

  set {
    name  = "query.enabled"
    value = "true"
  }

  set {
    name  = "storeGateway.enabled"
    value = "true"
  }

  set {
    name  = "compactor.enabled"
    value = "false"
  }

  set {
    name  = "receiver.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "objstoreConfig"
    value = <<EOT
      type: S3
      config:
        bucket: ${aws_s3_bucket.thanos_storage.bucket}
        endpoint: s3.${var.thanos_host_cluster.region}.amazonaws.com
    EOT
  }

  set {
  name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  value = "arn:aws:iam::761018861446:role/thanos-s3-access-k8s-cluster-us-east-1"
  }

}

data "kubernetes_service" "thanos_receiver" {
  provider = kubernetes.host
  metadata {
    name      = "thanos-receiver"
    namespace = "monitoring"
  }
  depends_on = [helm_release.thanos]
}

# locals {
#   receiver_endpoint = "http://${data.kubernetes_service.thanos_receiver.status.0.load_balancer.0.ingress.0.hostname}:10908/api/v1/receive"
# }

# output "thanos_query_endpoint" {
#   value = "http://${helm_release.thanos.name}-query.monitoring:9090"
# }

# output "thanos_receiver_endpoint" {
#   value = local.receiver_endpoint
# }

# output "s3_bucket_name" {
#   value = aws_s3_bucket.thanos_storage.bucket
# }
