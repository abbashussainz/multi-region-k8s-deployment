# terraform {
#   source = "../../../../modules/RDS"
# }

# include "parent" {
#   path = find_in_parent_folders("env.hcl")
# }
# include "root" {
#   path = find_in_parent_folders("root.hcl")
# }

# # Dependency on VPC
# dependency "vpc" {
#   config_path = "../vpc"

#   # Mock outputs (used only if Terragrunt cannot fetch real outputs)
#   mock_outputs = {
#     vpc_id             = "vpc-12345678"
#     availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
#     private_subnet_ids = ["subnet-111", "subnet-222", "subnet-333"]
#   }
# }

# inputs = {
#   is_primary       = true
#   cluster_name     = "aurora-global"
#   instance_count   = 2
#   instance_class   = "db.r6g.large"
#   region               = "us-east-1"

#   publicly_accessible = true

#   vpc_id             = dependency.vpc.outputs.vpc_id
#   availability_zones = dependency.vpc.outputs.availability_zones
#   subnets            = dependency.vpc.outputs.private_subnet_ids

#   engine            = "aurora-postgresql"
#   engine_version    = "14.6"
#   master_username   = "user"
#   master_password   = ""

#   tags = {
#     Environment = "prod"
#     Region      = "us-east-1"
#   }
# }