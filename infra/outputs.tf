output "current_account_id" {
  description = "Current AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "current_region" {
  description = "Current AWS region"
  value       = data.aws_region.current.name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Private app subnet IDs"
  value       = module.network.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "Private DB subnet IDs"
  value       = module.network.private_db_subnet_ids
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.app.dns_name
}

output "alb_zone_id" {
  description = "ALB Zone ID"
  value       = aws_lb.app.zone_id
}

output "app_target_group_arn" {
  description = "App target group ARN"
  value       = aws_lb_target_group.app.arn
}

output "app_asg_name" {
  description = "App Auto Scaling Group name"
  value       = aws_autoscaling_group.app.name
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_secret_name" {
  description = "Secrets Manager secret name"
  value       = module.security.db_secret_name
}

output "waf_web_acl_name" {
  description = "WAF Web ACL name"
  value       = module.security.waf_web_acl_name
}

output "app_url" {
  description = "Application URL"
  value       = "https://${var.app_domain_name}"
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate.app.arn
}

output "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = data.aws_route53_zone.main.zone_id
}

output "route53_app_record" {
  description = "Route 53 app record"
  value       = aws_route53_record.app.fqdn
}

output "sns_alerts_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarm notifications"
  value       = aws_sns_topic.alerts.arn
}

output "chatbot_slack_configuration" {
  description = "AWS Chatbot Slack channel configuration name"
  value       = aws_chatbot_slack_channel_configuration.alerts.configuration_name
}

output "alb_logs_bucket_name" {
  description = "S3 bucket name for ALB access logs"
  value       = aws_s3_bucket.alb_logs.bucket
}

output "cloudwatch_log_group_docker" {
  description = "CloudWatch log group name for Docker application logs"
  value       = aws_cloudwatch_log_group.docker_app.name
}

output "waf_log_group_name" {
  description = "CloudWatch log group name for WAF logs"
  value       = aws_cloudwatch_log_group.waf.name
}