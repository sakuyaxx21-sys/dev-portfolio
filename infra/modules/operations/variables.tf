# ============================
# Common
# ============================
variable "name_prefix" {
  description = "Name prefix for operations resources"
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

variable "aws_region" {
  description = "AWS region"
  type        = string
}

# ============================
# ALB / App
# ============================
variable "alb_arn" {
  description = "ALB ARN"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target Group ARN suffix"
  type        = string
}

variable "asg_name" {
  description = "Auto Scaling Group name"
  type        = string
}

# ============================
# Network
# ============================
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

# ============================
# Database
# ============================
variable "db_instance_identifier" {
  description = "RDS instance identifier"
  type        = string
}

# ============================
# WAF
# ============================
variable "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  type        = string
}

# ============================
# Slack
# ============================
variable "slack_team_id" {
  description = "Slack team ID for AWS Chatbot"
  type        = string
}

variable "slack_channel_id" {
  description = "Slack channel ID for AWS Chatbot"
  type        = string
}