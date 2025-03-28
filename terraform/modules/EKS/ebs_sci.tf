# Add this to your existing data blocks (if not already present)
data "aws_iam_openid_connect_provider" "this" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# Your EBS CSI driver code with slight improvements:
data "aws_iam_policy_document" "csi" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.this.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_ebs_csi_driver" {
  count              = var.enable_ebs_csi_driver ? 1 : 0
  name               = "${var.cluster_name}-ebs-csi-driver"
  assume_role_policy = data.aws_iam_policy_document.csi.json
  description        = "IAM role for EBS CSI Driver"
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "amazon_ebs_csi_driver" {
  count      = var.enable_ebs_csi_driver ? 1 : 0
  role       = aws_iam_role.eks_ebs_csi_driver[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "csi_driver" {
  count                    = var.enable_ebs_csi_driver ? 1 : 0
  cluster_name             = var.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.eks_ebs_csi_driver[0].arn
      
  depends_on = [
    aws_iam_role_policy_attachment.amazon_ebs_csi_driver,
    aws_iam_openid_connect_provider.this
  ]
}