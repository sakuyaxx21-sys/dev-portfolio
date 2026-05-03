data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# ============================
# Network Module
# ============================
module "network" {
  source = "./modules/network"

  name_prefix              = local.name_prefix
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = var.availability_zones
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  app_port                 = var.app_port
}

# ============================
# Security Module
# ============================
module "security" {
  source = "./modules/security"

  name_prefix = local.name_prefix
  db_username = var.db_username
  db_name     = var.db_name
}