# ============================
# S3 Bucket for ALB Access Logs
# ============================
resource "aws_s3_bucket" "alb_logs" {
  bucket = "${local.name_prefix}-ops-alb-logs-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${local.name_prefix}-ops-alb-logs"
  }
}

# ============================
# Block Public Access
# ============================
resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================
# Server Side Encryption
# ============================
resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ============================
# Lifecycle Rule
# ============================
resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    id     = "delete-alb-logs-after-30-days"
    status = "Enabled"

    filter {
      prefix = "alb-logs/"
    }

    expiration {
      days = 30
    }
  }
}

# ============================
# Bucket Policy for ALB Logs
# ============================
resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/alb-logs/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      }
    ]
  })
}