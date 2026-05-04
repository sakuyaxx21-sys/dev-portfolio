# ============================
# CloudWatch Logs
# ============================

resource "aws_cloudwatch_log_group" "cloudinit" {
  name              = "/${var.env}/${var.project}/ec2/cloud-init"
  retention_in_days = 7

  tags = {
    Name = "/${var.env}/${var.project}/ec2/cloud-init"
  }
}

resource "aws_cloudwatch_log_group" "cloudinit_output" {
  name              = "/${var.env}/${var.project}/ec2/cloud-init-output"
  retention_in_days = 7

  tags = {
    Name = "/${var.env}/${var.project}/ec2/cloud-init-output"
  }
}

resource "aws_cloudwatch_log_group" "docker_app" {
  name              = "/${var.env}/${var.project}/app/docker"
  retention_in_days = 30

  tags = {
    Name = "/${var.env}/${var.project}/app/docker"
  }
}

resource "aws_cloudwatch_log_group" "ssm" {
  name              = "/${var.env}/${var.project}/ec2/ssm"
  retention_in_days = 7

  tags = {
    Name = "/${var.env}/${var.project}/ec2/ssm"
  }
}

resource "aws_cloudwatch_log_group" "waf" {
  name              = "aws-waf-logs-${local.name_prefix}-ops"
  retention_in_days = 30

  tags = {
    Name = "aws-waf-logs-${local.name_prefix}-ops"
  }
}

# ============================
# WAF Logging Configuration
# ============================
resource "aws_wafv2_web_acl_logging_configuration" "main" {
  resource_arn            = var.waf_web_acl_arn
  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]
}