# ============================
# Common
# ============================
variable "name_prefix" {
  description = "Name prefix for app resources"
  type        = string
}

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
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "private_app_subnet_ids" {
  description = "Private app subnet IDs for ASG"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB security group ID"
  type        = string
}

variable "app_security_group_id" {
  description = "App EC2 security group ID"
  type        = string
}

# ============================
# ALB Access Logs
# ============================
variable "alb_logs_bucket_name" {
  description = "S3 bucket name for ALB access logs"
  type        = string
}

# ============================
# Application
# ============================
variable "app_port" {
  description = "Application port"
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "github_repo_url" {
  description = "GitHub repository URL for application deployment"
  type        = string
}

# ============================
# Auto Scaling
# ============================
variable "asg_min_size" {
  description = "Auto Scaling Group minimum size"
  type        = number
}

variable "asg_max_size" {
  description = "Auto Scaling Group maximum size"
  type        = number
}

variable "asg_desired_capacity" {
  description = "Auto Scaling Group desired capacity"
  type        = number
}

# ============================
# Database
# ============================
variable "db_secret_name" {
  description = "Secrets Manager secret name for database credentials"
  type        = string
}

variable "db_host" {
  description = "RDS endpoint host"
  type        = string
}

# ============================
# IAM
# ============================
variable "app_ec2_instance_profile_name" {
  description = "App EC2 instance profile name"
  type        = string
}

# ============================
# WAF
# ============================
variable "web_acl_arn" {
  description = "WAF Web ACL ARN"
  type        = string
}

# ============================
# DNS / HTTPS
# ============================
variable "domain_name" {
  description = "Root domain name"
  type        = string
}

variable "app_domain_name" {
  description = "Application domain name"
  type        = string
}

# ============================
# AWS
# ============================
variable "aws_region" {
  description = "AWS region"
  type        = string
}

# ============================
# CloudWatch Agent
# ============================
variable "cloudwatch_agent_config" {
  description = "CloudWatch Agent configuration JSON"
  type        = string
}