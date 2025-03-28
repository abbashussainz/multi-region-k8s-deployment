resource "helm_release" "karmada" {
  name             = "karmada"
  namespace        = "karmada-system"
  create_namespace = true

  repository = "https://raw.githubusercontent.com/karmada-io/karmada/master/charts"
  chart      = "karmada"

  set {
    name  = "installMode"
    value = "host"
  }
  set {
    name  = "apiServer.serviceType"
    value = "LoadBalancer"
  }
  set {
    name  = "apiServer.serviceAnnotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }
  set {
    name  = "certs.auto.hosts[0]"
    value = "kubernetes.default.svc"
  }
  set {
    name  = "certs.auto.hosts[1]"
    value = "*.etcd.karmada-system.svc.cluster.local"
  }
  set {
    name  = "certs.auto.hosts[2]"
    value = "*.karmada-system.svc.cluster.local"
  }
  set {
    name  = "certs.auto.hosts[3]"
    value = "*.karmada-system.svc"
  }
  set {
    name  = "certs.auto.hosts[4]"
    value = "localhost"
  }
  set {
    name  = "certs.auto.hosts[5]"
    value = "127.0.0.1"
  }
  set {
    name  = "certs.auto.hosts[6]"
    value = "*.elb.${var.karmada_host_cluster_region}.amazonaws.com"
  }
}

resource "time_sleep" "wait_for_lb" {
  depends_on      = [helm_release.karmada]
  create_duration = "30s"
}
