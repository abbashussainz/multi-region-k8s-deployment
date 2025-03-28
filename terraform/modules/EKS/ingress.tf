variable "install_ingress" {
  description = "Whether to install NGINX Ingress Controller"
  type        = bool
  default     = true
}

resource "helm_release" "nginx_ingress" {

  depends_on = [ helm_release.prometheus ]
  
  count      = var.install_ingress ? 1 : 0
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true

  values = [<<EOF
controller:
  service:
    type: LoadBalancer
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
      service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
      service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
  metrics:
    enabled: true
    serviceMonitor:
     enabled: true
     additionalLabels:
       release: prometheus
EOF
  ]
}
