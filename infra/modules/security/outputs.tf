# ============================
# KMS
# ============================
output "kms_key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.main.arn
}

# ============================
# IAM
# ============================
output "app_ec2_instance_profile_name" {
  description = "App EC2 instance profile name"
  value       = aws_iam_instance_profile.app_ec2.name
}

output "github_actions_oidc_provider_arn" {
  description = "GitHub Actions OIDC provider ARN"
  value       = local.github_actions_oidc_provider_arn
}

output "github_actions_cd_role_arn" {
  description = "IAM Role ARN for GitHub Actions CD workflow"
  value       = aws_iam_role.github_actions_cd.arn
}

output "github_actions_terraform_role_arn" {
  description = "IAM Role ARN for GitHub Actions Terraform workflow"
  value       = aws_iam_role.github_actions_terraform.arn
}

# ============================
# Secrets Manager
# ============================
output "app_secret_name" {
  description = "Secrets Manager secret name for application credentials"
  value       = aws_secretsmanager_secret.app.name
}

output "app_secret_arn" {
  description = "Secrets Manager secret ARN for application credentials"
  value       = aws_secretsmanager_secret.app.arn
}

# ============================
# WAF
# ============================
output "waf_web_acl_name" {
  description = "WAF Web ACL name"
  value       = aws_wafv2_web_acl.main.name
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = aws_wafv2_web_acl.main.arn
}
