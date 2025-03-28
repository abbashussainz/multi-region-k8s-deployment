terraform {
  source = "../../../../modules/EKS"
}

include "parent" {
  path = find_in_parent_folders("env.hcl")
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id             = "vpc-12345678"
    availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    private_subnet_ids = ["subnet-111", "subnet-222", "subnet-333"]
    public_subnet_ids = ["subnet-111", "subnet-222", "subnet-333"]
  }
}

inputs = {
  aws_region               = "ap-southeast-1"
  cluster_name             = "k8s-cluster-ap-southeast-1"
  cluster_version          = "1.25"
  vpc_id                   = dependency.vpc.outputs.vpc_id
  subnet_ids               = dependency.vpc.outputs.public_subnet_ids
  endpoint_private_access  = false
  endpoint_public_access   = true
  public_access_cidrs      = ["0.0.0.0/0"]
  allowed_cidr_blocks      = ["0.0.0.0/0"]
  enabled_cluster_log_types = ["api", "audit"]

  # Worker Node Configuration
  create_worker_nodes     = true
  worker_node_group_name  = "worker"
  worker_desired_size     = 3
  worker_max_size         = 3
  worker_min_size         = 3
  worker_instance_types   = ["t3.medium"]
  worker_ami_type         = "AL2_x86_64"
  worker_disk_size        = 20

  enable_karpenter = true
  install_argo_rollouts = true
  install_ingress = true
  enable_ebs_csi_driver = true
  enable_thanos_integration = true



  tags = {
    Environment = "dev"
  }
}