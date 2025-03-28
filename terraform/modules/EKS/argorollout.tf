resource "helm_release" "argo_rollouts" {
  count      = var.install_argo_rollouts ? 1 : 0
  name       = "argo-rollouts"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  namespace  = "argo-rollouts"
  version    = "2.39.0" # specify the latest version

  create_namespace = true

  set {
    name  = "controller.replicas"
    value = 2
  }

  set {
    name  = "controller.service.type"
    value = "ClusterIP"
  }
}
