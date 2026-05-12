# ============================
# Common
# ============================
variable "name_prefix" {
  description = "Name prefix for security resources"
  type        = string
}

# ============================
# Database
# ============================
variable "db_master_secret_arn" {
  description = "RDS managed master user secret ARN"
  type        = string
}

# ============================
# Secrets Manager / KMS
# ============================
variable "secret_recovery_window_in_days" {
  description = "Recovery window in days for Secrets Manager secret deletion"
  type        = number
}

variable "kms_deletion_window_in_days" {
  description = "Waiting period in days before KMS key deletion"
  type        = number
}
