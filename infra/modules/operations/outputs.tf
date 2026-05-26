# ============================
# SNS
# ============================
output "sns_critical_alerts_topic_arn" {
  description = "SNS topic ARN for critical CloudWatch alarm notifications"
  value       = aws_sns_topic.critical_alerts.arn
}

output "sns_warning_alerts_topic_arn" {
  description = "SNS topic ARN for warning CloudWatch alarm notifications"
  value       = aws_sns_topic.warning_alerts.arn
}

# ============================
# Chatbot
# ============================
output "chatbot_critical_slack_configuration_name" {
  description = "AWS Chatbot Slack channel configuration name for critical alerts"
  value       = aws_chatbot_slack_channel_configuration.critical_alerts.configuration_name
}

output "chatbot_warning_slack_configuration_name" {
  description = "AWS Chatbot Slack channel configuration name for warning alerts"
  value       = aws_chatbot_slack_channel_configuration.warning_alerts.configuration_name
}

# ============================
# ALB Access Logs
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
