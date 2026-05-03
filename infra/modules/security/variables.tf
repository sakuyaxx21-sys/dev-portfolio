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