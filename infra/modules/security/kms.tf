# ============================
# KMS Key
# ============================
resource "aws_kms_key" "main" {
  description             = "KMS key for ${local.name_prefix}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "${local.name_prefix}-kms-main"
  }
}

resource "aws_kms_alias" "main" {
  name          = "alias/${local.name_prefix}-kms-main"
  target_key_id = aws_kms_key.main.key_id
}