# ============================
# Database
# ============================
output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "RDS port"
  value       = aws_db_instance.main.port
}

output "db_master_secret_arn" {
  description = "RDS managed master user secret ARN"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
  sensitive   = true
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.main.name
}
