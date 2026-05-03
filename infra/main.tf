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

# ============================
# DB Module
# ============================
module "db" {
  source = "./modules/db"

  name_prefix           = local.name_prefix
  private_db_subnet_ids = module.network.private_db_subnet_ids
  db_security_group_id  = module.network.db_security_group_id
  kms_key_arn           = module.security.kms_key_arn

  db_name              = var.db_name
  db_username          = var.db_username
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_engine_version    = var.db_engine_version
}