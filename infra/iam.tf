# ============================
# EC2 IAM Role
# ============================
resource "aws_iam_role" "app_ec2" {
  name = "${local.name_prefix}-role-app-ec2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-role-app-ec2"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.app_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app_ec2" {
  name = "${local.name_prefix}-instance-profile-app-ec2"
  role = aws_iam_role.app_ec2.name
}

# ============================
# EC2 Policy for Secrets Manager
# ============================
resource "aws_iam_policy" "app_secrets" {
  name        = "${local.name_prefix}-policy-app-secrets"
  description = "Allow app EC2 to read DB secret"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.db.arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = aws_kms_key.main.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_secrets" {
  role       = aws_iam_role.app_ec2.name
  policy_arn = aws_iam_policy.app_secrets.arn
}

# ============================
# EC2 Policy for CloudWatch Agent
# ============================

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_server" {
  role       = aws_iam_role.app_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}