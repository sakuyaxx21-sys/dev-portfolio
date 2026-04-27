# ============================
# Random Password
# ============================
resource "random_password" "db" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ============================
# Secrets Manager
# ============================
resource "aws_secretsmanager_secret" "db" {
  name        = "${local.name_prefix}-secret-db"
  description = "Database credentials for ${local.name_prefix}"
  kms_key_id  = aws_kms_key.main.arn

  tags = {
    Name = "${local.name_prefix}-secret-db"
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
    dbname   = var.db_name
  })
}