# ============================
# Network Module
# ============================
module "network" {
  source = "../../modules/network"

  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs

  nat_gateway_count = var.nat_gateway_count
  app_port          = var.app_port
}

# ============================
# Security Module
# ============================
module "security" {
  source = "../../modules/security"

  name_prefix = local.name_prefix

  db_master_secret_arn = module.db.db_master_secret_arn

  secret_recovery_window_in_days = var.secret_recovery_window_in_days
  kms_deletion_window_in_days    = var.kms_deletion_window_in_days

  github_actions_repository            = var.github_actions_repository
  github_actions_branch                = var.github_actions_branch
  github_actions_oidc_audience         = var.github_actions_oidc_audience
  github_actions_oidc_provider_arn     = var.github_actions_oidc_provider_arn
  github_actions_oidc_thumbprint_list  = var.github_actions_oidc_thumbprint_list
  github_actions_terraform_policy_arns = var.github_actions_terraform_policy_arns
}

# ============================
# DB Module
# ============================
module "db" {
  source = "../../modules/db"

  name_prefix           = local.name_prefix
  private_db_subnet_ids = module.network.private_db_subnet_ids
  db_security_group_id  = module.network.db_security_group_id

  db_name              = var.db_name
  db_username          = var.db_username
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_engine_version    = var.db_engine_version
  db_multi_az          = var.db_multi_az

  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot

  kms_key_arn = module.security.kms_key_arn
}

# ============================
# App Module
# ============================
module "app" {
  source = "../../modules/app"

  name_prefix = local.name_prefix
  project     = var.project
  env         = var.env

  vpc_id                 = module.network.vpc_id
  public_subnet_ids      = module.network.public_subnet_ids
  private_app_subnet_ids = module.network.private_app_subnet_ids
  alb_security_group_id  = module.network.alb_security_group_id
  app_security_group_id  = module.network.app_security_group_id

  alb_logs_bucket_name = module.operations.alb_logs_bucket_name

  app_dir  = "/opt/${var.env}-${var.project}"
  app_name = "${var.env}-${var.project}"
  app_port = var.app_port

  docker_image_name = var.docker_image_name
  docker_image_tag  = var.docker_image_tag

  instance_type    = var.instance_type
  root_volume_size = var.root_volume_size

  asg_min_size         = var.asg_min_size
  asg_max_size         = var.asg_max_size
  asg_desired_capacity = var.asg_desired_capacity

  db_host     = module.db.db_endpoint
  db_port     = module.db.db_port
  db_name     = var.db_name
  db_username = var.db_username

  db_master_secret_arn = module.db.db_master_secret_arn
  app_secret_name      = module.security.app_secret_name

  app_ec2_instance_profile_name = module.security.app_ec2_instance_profile_name
  web_acl_arn                   = module.security.waf_web_acl_arn

  domain_name     = var.domain_name
  app_domain_name = var.app_domain_name

  aws_region = var.aws_region

  cloudwatch_agent_config = templatefile(
    "${path.module}/../../modules/operations/cloudwatch_agent_config.json",
    {
      env     = var.env
      project = var.project
    }
  )
}

# ============================
# Operations Module
# ============================
module "operations" {
  source = "../../modules/operations"

  name_prefix = local.name_prefix
  project     = var.project
  env         = var.env
  aws_region  = var.aws_region

  alb_arn                 = module.app.alb_arn
  alb_arn_suffix          = module.app.alb_arn_suffix
  target_group_arn_suffix = module.app.target_group_arn_suffix
  asg_name                = module.app.asg_name

  waf_web_acl_arn = module.security.waf_web_acl_arn

  vpc_id = module.network.vpc_id

  alb_logs_bucket_force_destroy = var.alb_logs_bucket_force_destroy

  db_instance_identifier = module.db.db_instance_id

  slack_team_id             = var.slack_team_id
  slack_critical_channel_id = var.slack_critical_channel_id
  slack_warning_channel_id  = var.slack_warning_channel_id
}

# ============================
# Monitoring Module
# ============================
module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix = local.name_prefix
  project     = var.project
  env         = var.env

  alb_arn_suffix          = module.app.alb_arn_suffix
  target_group_arn_suffix = module.app.target_group_arn_suffix
  asg_name                = module.app.asg_name
  asg_desired_capacity    = var.asg_desired_capacity

  db_instance_identifier = module.db.db_instance_id

  sns_critical_alerts_topic_arn = module.operations.sns_critical_alerts_topic_arn
  sns_warning_alerts_topic_arn  = module.operations.sns_warning_alerts_topic_arn
}
