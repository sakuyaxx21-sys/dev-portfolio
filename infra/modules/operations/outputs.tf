# ============================
# SNS
# ============================
output "sns_alerts_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarm notifications"
  value       = aws_sns_topic.alerts.arn
}

# ============================
# Chatbot
# ============================
output "chatbot_slack_configuration_name" {
  description = "AWS Chatbot Slack channel configuration name"
  value       = aws_chatbot_slack_channel_configuration.alerts.configuration_name
}

# ============================
# ALB Logs S3 Bucket
# ============================
output "alb_logs_bucket_name" {
  description = "S3 bucket name for ALB access logs"
  value       = aws_s3_bucket.alb_logs.bucket
}

# ============================
# CloudWatch Logs
# ============================
output "cloudwatch_log_group_docker" {
  description = "CloudWatch log group name for Docker application logs"
  value       = aws_cloudwatch_log_group.docker_app.name
}

output "waf_log_group_name" {
  description = "CloudWatch log group name for WAF logs"
  value       = aws_cloudwatch_log_group.waf.name
}

output "waf_log_group_arn" {
  description = "CloudWatch log group ARN for WAF logs"
  value       = aws_cloudwatch_log_group.waf.arn
}

# ============================
# Terraform State
# ============================
output "tfstate_bucket_name" {
  description = "S3 bucket name for Terraform remote state"
  value       = aws_s3_bucket.tfstate.bucket
}