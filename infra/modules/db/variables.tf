# ============================
# Common
# ============================
variable "name_prefix" {
  description = "Name prefix for DB resources"
  type        = string
}

# ============================
# Network
# ============================
variable "private_db_subnet_ids" {
  description = "Private DB subnet IDs"
  type        = list(string)
}

variable "db_security_group_id" {
  description = "DB security group ID"
  type        = string
}

# ============================
# KMS
# ============================
variable "kms_key_arn" {
  description = "KMS key ARN for RDS encryption"
  type        = string
}

# ============================
# Database
# ============================
variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_allocated_storage" {
  description = "RDS allocated storage"
  type        = number
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
}

variable "db_multi_az" {
  description = "Whether to enable Multi-AZ deployment for RDS"
  type        = bool
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = number
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection for RDS"
  type        = bool
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot when destroying RDS"
  type        = bool
}
