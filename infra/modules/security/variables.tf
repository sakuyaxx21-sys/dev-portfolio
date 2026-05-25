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
}

variable "github_actions_oidc_provider_arn" {
  description = "Existing GitHub Actions OIDC provider ARN. When null, this module creates the provider."
  type        = string
  nullable    = true
}

variable "github_actions_oidc_thumbprint_list" {
  description = "Thumbprint list for GitHub Actions OIDC provider"
  type        = list(string)
}

variable "github_actions_terraform_policy_arns" {
  description = "IAM policy ARNs attached to the GitHub Actions Terraform role"
  type        = list(string)
}
