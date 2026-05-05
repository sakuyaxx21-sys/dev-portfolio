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

# ============================
# Secrets Manager
# ============================
output "db_secret_name" {
  description = "Secrets Manager secret name for database credentials"
  value       = aws_secretsmanager_secret.db.name
}

output "db_secret_arn" {
  description = "Secrets Manager secret ARN for database credentials"
  value       = aws_secretsmanager_secret.db.arn
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