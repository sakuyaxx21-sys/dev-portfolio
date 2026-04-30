# ============================
# CloudWatch Logs
# ============================

resource "aws_cloudwatch_log_group" "cloudinit" {
  name              = "/dev/portfolio/ec2/cloud-init"
  retention_in_days = 7

  tags = {
    Name = "/dev/portfolio/ec2/cloud-init"
  }
}

resource "aws_cloudwatch_log_group" "cloudinit_output" {
  name              = "/dev/portfolio/ec2/cloud-init-output"
  retention_in_days = 7

  tags = {
    Name = "/dev/portfolio/ec2/cloud-init-output"
  }
}

resource "aws_cloudwatch_log_group" "docker_app" {
  name              = "/dev/portfolio/app/docker"
  retention_in_days = 30

  tags = {
    Name = "/dev/portfolio/app/docker"
  }
}

resource "aws_cloudwatch_log_group" "ssm" {
  name              = "/dev/portfolio/ec2/ssm"
  retention_in_days = 7

  tags = {
    Name = "/dev/portfolio/ec2/ssm"
  }
}

resource "aws_cloudwatch_log_group" "waf" {
  name              = "aws-waf-logs-dev-portfolio-ops"
  retention_in_days = 30

  tags = {
    Name = "aws-waf-logs-dev-portfolio-ops"
  }
}