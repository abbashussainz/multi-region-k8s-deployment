terraform {
  backend "s3" {}
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-west-2"
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "my-eks-cluster"
}

variable "attach_karmada" {
  description = "Flag to enable or disable Karmada integration"
  type        = bool
  default     = false
}

provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

provider "kubernetes" {
  alias                  = "eks"
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  alias = "eks"
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

resource "helm_release" "argocd" {
  provider = helm.eks

  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.8.14"

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }
}

# Conditionally fetch Karmada API Server details if attach_karmada is true
data "kubernetes_service" "karmada_apiserver" {

  provider = kubernetes.eks

  count = var.attach_karmada ? 1 : 0

  metadata {
    name      = "karmada-apiserver"
    namespace = "karmada-system"
  }
}

locals {
  karmada_endpoint = var.attach_karmada ? "https://${data.kubernetes_service.karmada_apiserver[0].status[0].load_balancer[0].ingress[0].hostname}:5443" : ""
}

# Conditionally fetch Karmada kubeconfig if attach_karmada is true
data "kubernetes_secret" "karmada_kubeconfig" {

  provider = kubernetes.eks

  count = var.attach_karmada ? 1 : 0
  depends_on = [helm_release.argocd]

  metadata {
    name      = "karmada-kubeconfig"
    namespace = "karmada-system"
  }
}

locals {
  kubeconfig_yaml = var.attach_karmada ? data.kubernetes_secret.karmada_kubeconfig[0].data["kubeconfig"] : ""
  config = templatefile("${path.module}/config.tpl", {
    insecure = false
    caData   = yamldecode(local.kubeconfig_yaml)["clusters"][0]["cluster"]["certificate-authority-data"]
    certData = yamldecode(local.kubeconfig_yaml)["users"][0]["user"]["client-certificate-data"]
    keyData  = yamldecode(local.kubeconfig_yaml)["users"][0]["user"]["client-key-data"]
  })
}

# Conditionally create ArgoCD secret for Karmada if attach_karmada is true
resource "kubernetes_secret" "karmada_cluster" {
  count = var.attach_karmada ? 1 : 0
  provider = kubernetes.eks

  metadata {
    name      = "karmada-cluster"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
  }

  data = {
    name   = "karmada"
    server = local.karmada_endpoint
    config = local.config
  }
}
