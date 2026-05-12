# ============================
# Random Password
# ============================
resource "random_password" "app_secret_key" {
  length  = 64
  special = false
}

# ============================
# Secrets Manager
# ============================
resource "aws_secretsmanager_secret" "app" {
  name                    = "${local.name_prefix}-secret-app"
  description             = "Application credentials for ${local.name_prefix}"
  kms_key_id              = aws_kms_key.main.arn
  recovery_window_in_days = var.secret_recovery_window_in_days

  tags = {
    Name = "${local.name_prefix}-secret-app"
  }
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id

  secret_string = jsonencode({
    secret_key = random_password.app_secret_key.result
  })
}
