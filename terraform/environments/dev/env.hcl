locals {
  environment = "dev"
}

inputs = {
  common_tags = {
    Environment = local.environment
    Terraform   = "true"
    Owner       = "DevOps Team"
    Application = "EKS"
  }
}