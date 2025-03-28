resource "aws_iam_role" "thanos_s3_irsa" {
  count = var.enable_thanos_integration ? 1 : 0
  name  = "ThanosS3Role-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.this.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${trimprefix(aws_iam_openid_connect_provider.this.url, "https://")}:sub" = "system:serviceaccount:monitoring:thanos"
            "${trimprefix(aws_iam_openid_connect_provider.this.url, "https://")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "thanos_s3_policy_attach" {
  count      = var.enable_thanos_integration ? 1 : 0
  policy_arn = "arn:aws:iam::761018861446:policy/ThanosS3FullAccess"
  role       = aws_iam_role.thanos_s3_irsa[0].name
}

resource "kubernetes_service_account" "thanos" {
  count = var.enable_thanos_integration ? 1 : 0
  metadata {
    name      = "thanos"
    namespace = "monitoring"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.thanos_s3_irsa[0].arn
    }
  }
}

resource "kubernetes_secret" "thanos_objstore_config" {
  count = var.enable_thanos_integration ? 1 : 0
  metadata {
    name      = "thanos-objstore-config"
    namespace = "monitoring"
  }

  data = {
    "objstore.yml" = <<-EOT
      type: S3
      config:
        bucket: "${var.thanos_s3_bucket}"
        region: "${var.thanos_s3_region}"
        endpoint: "s3.us-east-1.amazonaws.com"
    EOT
  }

  type = "Opaque"
}

resource "helm_release" "prometheus" {
  count      = var.enable_thanos_integration ? 1 : 0
  name       = "prometheus"
  namespace  = "monitoring"
  chart      = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"

  values = [<<EOF
prometheus:
  thanosService:
    enabled: true
    type: LoadBalancer
    clusterIP: ""
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
  thanosServiceMonitor:
    enabled: true
  prometheusSpec:
    externalLabels:
      cluster: "${var.cluster_name}"
      env: "dev"
    serviceAccountName: "prometheus-irsa"
    thanos:
      baseImage: "quay.io/thanos/thanos"
      version: "v0.37.2"
      objectStorageConfig:
        existingSecret:
          key: "objstore.yml"
          name: "thanos-objstore-config"
    retention: "5d"
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: "20Gi"
EOF
  ]
}
