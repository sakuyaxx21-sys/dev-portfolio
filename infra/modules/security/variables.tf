# ============================
# Common
# ============================
variable "name_prefix" {
  description = "Name prefix for security resources"
  type        = string
}

# ============================
# Secrets Manager
# ============================
variable "db_username" {
  description = "Database master username"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "secret_recovery_window_in_days" {
  description = "Recovery window in days for Secrets Manager secret deletion"
  type        = number
}

variable "kms_deletion_window_in_days" {
  description = "Waiting period in days before KMS key deletion"
  type        = number
}