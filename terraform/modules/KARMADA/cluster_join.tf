resource "kubernetes_secret" "member_1_secret" {
  provider = kubernetes.karmada
  metadata {
    name      = "${var.member_clusters["member_1"].cluster_name}-credentials"
    namespace = "karmada-system"
  }
  data = {
    caBundle  = data.aws_eks_cluster.member_1.certificate_authority[0].data
    token   = data.aws_eks_cluster_auth.member_1.token
  }
}

resource "kubernetes_secret" "member_2_secret" {
  provider = kubernetes.karmada
  metadata {
    name      = "${var.member_clusters["member_2"].cluster_name}-credentials"
    namespace = "karmada-system"
  }
  data = {
    caBundle  = data.aws_eks_cluster.member_2.certificate_authority[0].data
    token   = data.aws_eks_cluster_auth.member_2.token
  }
}

resource "kubernetes_secret" "member_3_secret" {
  provider = kubernetes.karmada
  metadata {
    name      = "${var.member_clusters["member_3"].cluster_name}-credentials"
    namespace = "karmada-system"
  }
  data = {
    caBundle  = base64decode(data.aws_eks_cluster.member_3.certificate_authority[0].data)
    token   = data.aws_eks_cluster_auth.member_3.token
  }
}

resource "kubernetes_manifest" "member_1" {
  provider = kubernetes.karmada

  manifest = {
    apiVersion = "cluster.karmada.io/v1alpha1"
    kind       = "Cluster"
    metadata = {
      name = "${var.member_clusters["member_1"].cluster_name}"
    }
    spec = {
      apiEndpoint                  = data.aws_eks_cluster.member_1.endpoint
      secretRef = {
        name      = "${var.member_clusters["member_1"].cluster_name}-credentials"
        namespace = "karmada-system"
      }
      insecureSkipTLSVerification = true
      syncMode                     = "Push"
    }
  }
}

resource "kubernetes_manifest" "member_2" {
  provider = kubernetes.karmada

  manifest = {
    apiVersion = "cluster.karmada.io/v1alpha1"
    kind       = "Cluster"
    metadata = {
      name = "${var.member_clusters["member_2"].cluster_name}"
    }
    spec = {
      apiEndpoint                  = data.aws_eks_cluster.member_2.endpoint
      secretRef = {
        name      = "${var.member_clusters["member_2"].cluster_name}-credentials"
        namespace = "karmada-system"
      }
      insecureSkipTLSVerification = true
      syncMode                     = "Push"
    }
  }
}


resource "kubernetes_manifest" "member_3" {
  provider = kubernetes.karmada

  manifest = {
    apiVersion = "cluster.karmada.io/v1alpha1"
    kind       = "Cluster"
    metadata = {
      name = "${var.member_clusters["member_3"].cluster_name}"
    }
    spec = {
      apiEndpoint                  = data.aws_eks_cluster.member_3.endpoint
      secretRef = {
        name      = "${var.member_clusters["member_3"].cluster_name}-credentials"
        namespace = "karmada-system"
      }
      insecureSkipTLSVerification = true
      syncMode                     = "Push"
    }
  }
}