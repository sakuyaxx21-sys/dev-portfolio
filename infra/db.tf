# ============================
# DB Subnet Group
# ============================
resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.private_db[*].id

  tags = {
    Name = "${local.name_prefix}-db-subnet-group"
  }
}

# ============================
# RDS PostgreSQL
# ============================
resource "aws_db_instance" "main" {
  identifier = "${local.name_prefix}-rds-postgres"

  engine         = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.main.arn

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]

  multi_az            = false
  publicly_accessible = false

  backup_retention_period = 7
  deletion_protection     = false
  skip_final_snapshot     = true

  tags = {
    Name = "${local.name_prefix}-rds-postgres"
  }
}