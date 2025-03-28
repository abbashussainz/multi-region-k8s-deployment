terraform {
  source = "../../../../modules/VPC"
}

include "parent" {
  path = find_in_parent_folders("env.hcl")
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  project_name = "machine-test-ap-southeast-1"
  region               = "ap-southeast-1"
  vpc_cidr             = "10.3.0.0/16"
  public_subnet_cidrs  = ["10.3.1.0/24", "10.3.2.0/24", "10.3.3.0/24"]
  private_subnet_cidrs = ["10.3.4.0/24", "10.3.5.0/24", "10.3.6.0/24"]
  availability_zones   = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]

  public_subnet_tags = {
    "karpenter.sh/discovery" = "k8s-cluster-ap-southeast-1"
    Tier                                     = "public"
    "kubernetes.io/cluster/kk8s-cluster-ap-southeast-1"  = "owned"
    "kubernetes.io/role/elb"                 = "1"
    "kubernetes.io/cluster/k8s-cluster-ap-southeast-1" = "shared"
    "karpenter.sh/discovery" = "true"
  }

  private_subnet_tags = {
    "karpenter.sh/discovery" = "k8s-cluster-ap-southeast-1"
    Tier                                     = "private"
    "kubernetes.io/cluster/k8s-cluster-ap-southeast-1"  = "owned"
    "kubernetes.io/role/internal-elb"        = "1"
    "kubernetes.io/cluster/k8s-cluster-ap-southeast-1" = "shared"
    "karpenter.sh/discovery" = "true"
  }
}