data "kubernetes_service" "karmada_apiserver" {
  depends_on = [time_sleep.wait_for_lb,helm_release.karmada]
  metadata {
    name      = "karmada-apiserver"
    namespace = "karmada-system"
  }

  provider = kubernetes.karmada_host
}

locals {
  karmada_endpoint = "${data.kubernetes_service.karmada_apiserver.status[0].load_balancer[0].ingress[0].hostname}:5443"
}

data "kubernetes_secret" "karmada_kubeconfig" {
  depends_on = [helm_release.karmada]
  metadata {
    name      = "karmada-kubeconfig"
    namespace = "karmada-system"
  }

  provider = kubernetes.karmada_host

}

locals {
  kubeconfig_yaml = data.kubernetes_secret.karmada_kubeconfig.data["kubeconfig"]
}


provider "kubernetes" {
  alias = "karmada"

  host = local.karmada_endpoint

  client_certificate     = base64decode(yamldecode(local.kubeconfig_yaml)["users"][0]["user"]["client-certificate-data"])
  client_key             = base64decode(yamldecode(local.kubeconfig_yaml)["users"][0]["user"]["client-key-data"])
  cluster_ca_certificate = base64decode(yamldecode(local.kubeconfig_yaml)["clusters"][0]["cluster"]["certificate-authority-data"])
}

