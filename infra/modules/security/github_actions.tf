# ============================
# GitHub Actions OIDC Provider
# ============================
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  # Use an existing OIDC provider when supplied; otherwise create one here.
  github_actions_oidc_provider_arn = (
    var.github_actions_oidc_provider_arn != null
    ? var.github_actions_oidc_provider_arn
    : aws_iam_openid_connect_provider.github_actions[0].arn
  )
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  count = var.github_actions_oidc_provider_arn == null ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = [var.github_actions_oidc_audience]
  thumbprint_list = var.github_actions_oidc_thumbprint_list

  tags = {
    Name = "${var.name_prefix}-oidc-github-actions"
  }
}

# ============================
# GitHub Actions CD Role
# ============================
resource "aws_iam_role" "github_actions_cd" {
  name = "${var.name_prefix}-role-github-actions-cd"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.github_actions_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = var.github_actions_oidc_audience
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_actions_repository}:ref:refs/heads/${var.github_actions_branch}"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-role-github-actions-cd"
  }
}

# ============================
# GitHub Actions CD Policy
# ============================
resource "aws_iam_policy" "github_actions_cd" {
  name        = "${var.name_prefix}-policy-github-actions-cd"
  description = "Allow GitHub Actions CD workflow to deploy the app through SSM"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:SendCommand"
        ]
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.name}::document/AWS-RunShellScript",
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:instance/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:DescribeInstanceInformation",
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_cd" {
  role       = aws_iam_role.github_actions_cd.name
  policy_arn = aws_iam_policy.github_actions_cd.arn
}

# ============================
# GitHub Actions Terraform Role
# ============================
resource "aws_iam_role" "github_actions_terraform" {
  name = "${var.name_prefix}-role-github-actions-terraform"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.github_actions_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = var.github_actions_oidc_audience
          }
          StringLike = {
            # Terraform runs are scoped by GitHub Environment instead of branch.
            "token.actions.githubusercontent.com:sub" = [
              "repo:${var.github_actions_repository}:environment:dev",
              "repo:${var.github_actions_repository}:environment:prod"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-role-github-actions-terraform"
  }
}

# ============================
# GitHub Actions Terraform Policy
# ============================
resource "aws_iam_role_policy_attachment" "github_actions_terraform" {
  for_each = toset(var.github_actions_terraform_policy_arns)

  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = each.value
}
