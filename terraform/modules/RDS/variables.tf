variable "is_primary" {
  type    = bool
  default = false
}

variable "cluster_name" {
  default = "aurora-global-db"
}

variable "engine" {
  default = "aurora-postgresql"
}

variable "engine_version" {
  default = "15.2"
}

variable "master_username" {
     default = ""
}
variable "master_password" {
     default = ""
}

variable "instance_class" {
  default = "db.r6g.large"
}

variable "instance_count" {
  default = 2
}

variable "availability_zones" {
  type = list(string)
}


variable "tags" {
  type    = map(string)
  default = {}
}


variable "subnets" {
  description = "List of subnet IDs where RDS should be deployed"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where Aurora is deployed"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "publicly_accessible" {
  type = bool
  default = true 
}