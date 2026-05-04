# ============================
# Common
# ============================
variable "name_prefix" {
  description = "Name prefix for monitoring resources"
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
# App / ALB
# ============================
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

variable "asg_desired_capacity" {
  description = "Auto Scaling Group desired capacity"
  type        = number
}

# ============================
# Database
# ============================
variable "db_instance_identifier" {
  description = "RDS instance identifier"
  type        = string
}

# ============================
# SNS
# ============================
variable "sns_alerts_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  type        = string
}