terraform {
  source = "../../../../modules/ARGOCD"
}

include "parent" {
  path = find_in_parent_folders("env.hcl")
}
include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  aws_region       = "us-east-1"
  eks_cluster_name = "k8s-cluster-us-east-1"
  attach_karmada   = true
}
