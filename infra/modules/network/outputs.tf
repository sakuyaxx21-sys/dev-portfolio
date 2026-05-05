# ============================
# VPC
# ============================
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

# ============================
# Subnets
# ============================
output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "Private app subnet IDs"
  value       = aws_subnet.private_app[*].id
}

output "private_db_subnet_ids" {
  description = "Private DB subnet IDs"
  value       = aws_subnet.private_db[*].id
}

# ============================
# Security Groups
# ============================
output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "App security group ID"
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "DB security group ID"
  value       = aws_security_group.db.id
}