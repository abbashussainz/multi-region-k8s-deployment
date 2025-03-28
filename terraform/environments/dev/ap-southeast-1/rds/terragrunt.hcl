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

#   # Fetch required outputs
#   mock_outputs = {
#     vpc_id               = "vpc-12345678"
#     availability_zones   = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
#     private_subnet_ids   = ["subnet-111", "subnet-222", "subnet-333"]
#   }
# }

# # dependency "primary" {
# #   config_path = "../../us-east-1/rds"
# # }

# inputs = {
#   region           = "ap-southeast-1"
#   is_primary       = false
#   engine            = "aurora-postgresql"
#   engine_version    = "14.6"
#   instance_count   = 2
#   instance_class   = "db.r6g.large"
#   cluster_name     = "aurora-global"

#   publicly_accessible = true

#   # Use outputs from the VPC module
#   vpc_id             = dependency.vpc.outputs.vpc_id
#   availability_zones = dependency.vpc.outputs.availability_zones
#   subnets           = dependency.vpc.outputs.private_subnet_ids

#   tags = {
#     Environment = "dev"
#     Region      = "ap-southeast-1"
#   }
# }
