# ============================
# Latest Amazon Linux 2023 AMI
# ============================
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# ============================
# Application Load Balancer
# ============================
resource "aws_lb" "app" {
  name               = "${local.name_prefix}-alb-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.network.alb_security_group_id]
  subnets            = module.network.public_subnet_ids

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    prefix  = "alb-logs"
    enabled = true
  }

  tags = {
    Name = "${local.name_prefix}-alb-app"
  }
}

# ============================
# Target Group
# ============================
resource "aws_lb_target_group" "app" {
  name        = "${local.name_prefix}-tg-app"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = module.network.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/api/v1/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${local.name_prefix}-tg-app"
  }
}

# ============================
# ALB HTTP Listener
# ============================
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ============================
# ALB HTTPS Listener
# ============================
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
  certificate_arn   = aws_acm_certificate_validation.app.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ============================
# Launch Template
# ============================
resource "aws_launch_template" "app" {
  name_prefix   = "${local.name_prefix}-lt-app-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.app_ec2.name
  }

  vpc_security_group_ids = [module.network.app_security_group_id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    github_repo_url         = var.github_repo_url
    db_secret_name          = aws_secretsmanager_secret.db.name
    db_host                 = aws_db_instance.main.address
    aws_region              = var.aws_region
    cloudwatch_agent_config = file("${path.module}/cloudwatch_agent_config.json")
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.name_prefix}-ec2-app"
    }
  }

  tags = {
    Name = "${local.name_prefix}-lt-app"
  }
}

# ============================
# Auto Scaling Group
# ============================
resource "aws_autoscaling_group" "app" {
  name                = "${local.name_prefix}-asg-app"
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = module.network.private_app_subnet_ids
  target_group_arns   = [aws_lb_target_group.app.arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-ec2-app"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }

  tag {
    key                 = "Env"
    value               = var.env
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }
}