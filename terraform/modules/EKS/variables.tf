variable "aws_region" {
  description = "AWS region to deploy the EKS cluster"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.24"
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "Enable private access to the EKS API server"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public access to the EKS API server"
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks allowed to access the EKS API server"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to communicate with the EKS cluster"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "List of log types to enable for the EKS cluster"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Worker Node Variables
variable "create_worker_nodes" {
  description = "Whether to create worker nodes for the EKS cluster"
  type        = bool
  default     = true
}

variable "worker_node_group_name" {
  description = "Name of the EKS worker node group"
  type        = string
  default     = "default-worker-node-group"
}

variable "worker_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "worker_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "worker_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "worker_instance_types" {
  description = "Instance types for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "worker_ami_type" {
  description = "AMI type for worker nodes"
  type        = string
  default     = "AL2_x86_64" # Amazon Linux 2
}

variable "worker_disk_size" {
  description = "Disk size for worker nodes (in GB)"
  type        = number
  default     = 20
}

variable "enable_karpenter" {
  description = "Enable Karpenter auto-scaling"
  type        = bool
  default     = false
}

variable "karpenter_version" {
  description = "Karpenter Helm chart version"
  type        = string
  default     = "v0.36.0"
}

variable "install_argo_rollouts" {
  type    = bool
  default = true
}

variable "enable_ebs_csi_driver" {
  type    = bool
  default = true
}

variable "thanos_s3_bucket" {
  default = "thanos-log-store"
  type = string
}

variable "thanos_s3_region" {
  default = "us-east-1"
  type = string
}

variable "enable_thanos_integration" {
  type    = bool
  default = true
}