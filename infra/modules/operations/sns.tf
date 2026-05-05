# ============================
# SNS Alerts
# ============================
resource "aws_sns_topic" "alerts" {
  name = "${local.name_prefix}-ops-sns-alerts"

  tags = {
    Name = "${local.name_prefix}-ops-sns-alerts"
  }
}