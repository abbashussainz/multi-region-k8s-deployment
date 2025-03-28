terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.region
}


resource "aws_rds_global_cluster" "aurora_global" {
  count                     = var.is_primary ? 1 : 0
  global_cluster_identifier = var.cluster_name
  engine                    = var.engine
  engine_version            = var.engine_version
}

# Aurora Primary Cluster
resource "aws_rds_cluster" "primary" {
  count                     = var.is_primary ? 1 : 0
  cluster_identifier        = "${var.cluster_name}-primary"
  engine                    = var.engine
  engine_version            = var.engine_version
  master_username           = var.master_username
  master_password           = var.master_password
  global_cluster_identifier = aws_rds_global_cluster.aurora_global[0].id
  vpc_security_group_ids    = [aws_security_group.aurora_sg.id]
  availability_zones        = var.availability_zones
  skip_final_snapshot       = true
  tags                      = var.tags
  db_subnet_group_name      = aws_db_subnet_group.aurora_subnet_group.name
}

resource "aws_rds_cluster_instance" "primary_instances" {
  count               = var.is_primary ? var.instance_count : 0
  cluster_identifier = aws_rds_cluster.primary[0].id
  instance_class     = var.instance_class
  engine            = aws_rds_cluster.primary[0].engine
  engine_version    = aws_rds_cluster.primary[0].engine_version
  tags              = var.tags
  publicly_accessible = var.publicly_accessible

}

# Aurora Read Replica Cluster (For Secondary Regions)
resource "aws_rds_cluster" "secondary" {
  count                     = var.is_primary ? 0 : 1
  cluster_identifier        = "${var.cluster_name}-replica"
  engine                    = var.engine
  engine_version            = var.engine_version
  global_cluster_identifier = var.cluster_name
  vpc_security_group_ids    = [aws_security_group.aurora_sg.id]
  availability_zones        = var.availability_zones
  skip_final_snapshot       = true
  tags                      = var.tags
  db_subnet_group_name      = aws_db_subnet_group.aurora_subnet_group.name
}

resource "aws_rds_cluster_instance" "secondary_instances" {
  count               = var.is_primary ? 0 : var.instance_count
  cluster_identifier = aws_rds_cluster.secondary[0].id
  instance_class     = var.instance_class
  engine            = aws_rds_cluster.secondary[0].engine
  engine_version    = aws_rds_cluster.secondary[0].engine_version
  tags              = var.tags
  publicly_accessible = var.publicly_accessible
}

# Security Group (Allowing All Traffic)
resource "aws_security_group" "aurora_sg" {
  name        = "aurora-sg-${var.region}"
  description = "Allow all traffic for Aurora"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "${var.cluster_name}-subnet-group"
  subnet_ids = var.subnets
  description = "Subnet group for Aurora RDS"
}
