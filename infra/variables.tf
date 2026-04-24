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