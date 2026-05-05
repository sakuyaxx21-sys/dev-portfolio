# ============================
# ALB
# ============================
output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.app.arn
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix"
  value       = aws_lb.app.arn_suffix
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.app.dns_name
}

output "alb_zone_id" {
  description = "ALB zone ID"
  value       = aws_lb.app.zone_id
}

# ============================
# Target Group
# ============================
output "target_group_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.app.arn
}

output "target_group_arn_suffix" {
  description = "Target Group ARN suffix"
  value       = aws_lb_target_group.app.arn_suffix
}

# ============================
# Auto Scaling
# ============================
output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.app.name
}

# ============================
# ACM
# ============================
output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate.app.arn
}

# ============================
# DNS / HTTPS
# ============================
output "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = data.aws_route53_zone.main.zone_id
}

output "app_url" {
  description = "Application URL"
  value       = "https://${var.app_domain_name}"
}