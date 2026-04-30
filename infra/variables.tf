variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
  default     = "terraform-dev"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "portfolio"
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
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

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 8000
}

variable "instance_type" {
  description = "EC2 instance type for app servers"
  type        = string
  default     = "t3.micro"
}

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

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "app_db"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "app_user"
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

variable "github_repo_url" {
  description = "GitHub repository URL for application deployment"
  type        = string
  default     = "https://github.com/sakuyaxx21-sys/dev-portfolio.git"
}

variable "domain_name" {
  description = "Root domain name managed by Route 53"
  type        = string
}

variable "app_domain_name" {
  description = "Application domain name"
  type        = string
}

variable "slack_team_id" {
  description = "Slack team ID for AWS Chatbot"
  type        = string
}

variable "slack_channel_id" {
  description = "Slack channel ID for AWS Chatbot notifications"
  type        = string
}
