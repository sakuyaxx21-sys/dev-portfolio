# ============================
# AWS Chatbot IAM Role
# ============================
resource "aws_iam_role" "chatbot" {
  name = "${local.name_prefix}-role-chatbot-slack"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-role-chatbot-slack"
  }
}

resource "aws_iam_role_policy_attachment" "chatbot_readonly" {
  role       = aws_iam_role.chatbot.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# ============================
# AWS Chatbot Slack Channel
# ============================
resource "aws_chatbot_slack_channel_configuration" "alerts" {
  configuration_name = "${local.name_prefix}-chatbot-slack-alerts"
  iam_role_arn       = aws_iam_role.chatbot.arn
  slack_team_id      = var.slack_team_id
  slack_channel_id   = var.slack_channel_id
  sns_topic_arns     = [aws_sns_topic.alerts.arn]

  logging_level = "ERROR"

  tags = {
    Name = "${local.name_prefix}-chatbot-slack-alerts"
  }
}