# ============================
# AWS Provider
# ============================
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
  default     = null
}

# ============================
# Common
# ============================
variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

# ============================
# Network
# ============================
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private app subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private db subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to create"
  type        = number
  default     = 2
}

# ============================
# Application
# ============================
variable "app_port" {
  description = "Application port"
  type        = number
  default     = 8000
}

variable "docker_image_name" {
  description = "Docker image name for application deployment"
  type        = string
}

variable "docker_image_tag" {
  description = "Docker image tag for application deployment"
  type        = string
  # Prefer an immutable tag or digest for production deployments.
  default = "latest"
}

variable "instance_type" {
  description = "EC2 instance type for app servers"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Root EBS volume size for app EC2 instances in GiB"
  type        = number
  default     = 30
}

# ============================
# GitHub Actions OIDC
# ============================
variable "github_actions_repository" {
  description = "GitHub repository allowed to assume the CD role in owner/name format"
  type        = string
}

variable "github_actions_branch" {
  description = "GitHub branch allowed to assume the CD role"
  type        = string
}

variable "github_actions_oidc_audience" {
  description = "Audience value for GitHub Actions OIDC tokens"
  type        = string
  default     = "sts.amazonaws.com"
}

variable "github_actions_oidc_provider_arn" {
  description = "Existing GitHub Actions OIDC provider ARN. When null, the security module creates the provider."
  type        = string
  default     = null
}

variable "github_actions_oidc_thumbprint_list" {
  description = "Thumbprint list for GitHub Actions OIDC provider"
  type        = list(string)
  default     = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

variable "github_actions_terraform_policy_arns" {
  description = "IAM policy ARNs attached to the GitHub Actions Terraform role"
  type        = list(string)
  # Replace with least-privilege policies before production use.
  default = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

# ============================
# Auto Scaling
# ============================
variable "asg_min_size" {
  description = "Minimum size of Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum size of Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "Desired capacity of Auto Scaling Group"
  type        = number
  default     = 1
}

# ============================
# Database
# ============================
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "db_name"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "db_username"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16.13"
}

variable "db_multi_az" {
  description = "Whether to enable Multi-AZ deployment for RDS"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection for RDS"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot when destroying RDS"
  type        = bool
  default     = false
}

# ============================
# Secrets Manager / KMS
# ============================
variable "secret_recovery_window_in_days" {
  description = "Recovery window in days for Secrets Manager secret deletion"
  type        = number
  default     = 30
}

variable "kms_deletion_window_in_days" {
  description = "Waiting period in days before KMS key deletion"
  type        = number
  default     = 30
}

# ============================
# ALB Access Logs
# ============================
variable "alb_logs_bucket_force_destroy" {
  description = "Whether to force destroy the ALB access logs S3 bucket even if it contains objects"
  type        = bool
  default     = false
}

# ============================
# DNS / HTTPS
# ============================
variable "domain_name" {
  description = "Root domain name managed by Route 53"
  type        = string
}

variable "app_domain_name" {
  description = "Application domain name"
  type        = string
}

# ============================
# Slack
# ============================
variable "slack_team_id" {
  description = "Slack team ID for AWS Chatbot"
  type        = string
}

variable "slack_critical_channel_id" {
  description = "Slack channel ID for critical AWS Chatbot notifications"
  type        = string
}

variable "slack_warning_channel_id" {
  description = "Slack channel ID for warning AWS Chatbot notifications"
  type        = string
}
