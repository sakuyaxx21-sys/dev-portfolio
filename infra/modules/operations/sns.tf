# ============================
# SNS Critical Alerts
# ============================
resource "aws_sns_topic" "critical_alerts" {
  name = "${local.name_prefix}-ops-sns-alerts-critical"

  tags = {
    Name = "${local.name_prefix}-ops-sns-alerts-critical"
  }
}

# ============================
# SNS Warning Alerts
# ============================
resource "aws_sns_topic" "warning_alerts" {
  name = "${local.name_prefix}-ops-sns-alerts-warning"

  tags = {
    Name = "${local.name_prefix}-ops-sns-alerts-warning"
  }
}
