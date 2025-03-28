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
  project_name = "machine-test-eu-west-1"
  region               = "eu-west-1"
  vpc_cidr             = "10.2.0.0/16"
  public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
  private_subnet_cidrs = ["10.2.4.0/24", "10.2.5.0/24", "10.2.6.0/24"]
  availability_zones   = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  public_subnet_tags = {
    "karpenter.sh/discovery" = "k8s-cluster-eu-west-1"
    Tier                                     = "public"
    "kubernetes.io/cluster/kk8s-cluster-eu-west-1"  = "owned"
    "kubernetes.io/role/elb"                 = "1"
    "kubernetes.io/cluster/k8s-cluster-eu-west-1" = "shared"
    "karpenter.sh/discovery" = "true"
  }

  private_subnet_tags = {
    "karpenter.sh/discovery" = "k8s-cluster-eu-west-1"
    Tier                                     = "private"
    "kubernetes.io/cluster/k8s-cluster-eu-west-1"  = "owned"
    "kubernetes.io/role/internal-elb"        = "1"
    "kubernetes.io/cluster/k8s-cluster-eu-west-1" = "shared"
    "karpenter.sh/discovery" = "true"
  }
}
