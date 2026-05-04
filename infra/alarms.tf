# ============================
# Auto Scaling Group - InService Instance Count
# ============================
resource "aws_cloudwatch_metric_alarm" "asg_inservice" {
  alarm_name          = "${local.name_prefix}-ops-alarm-asg-capacity"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  threshold           = var.asg_desired_capacity

  alarm_description = "ASG InService instances are below desired capacity"

  alarm_actions = [module.operations.sns_alerts_topic_arn]
  ok_actions    = [module.operations.sns_alerts_topic_arn]

  metric_query {
    id = "inservice"

    metric {
      metric_name = "GroupInServiceInstances"
      namespace   = "AWS/AutoScaling"
      period      = 60
      stat        = "Average"

      dimensions = {
        AutoScalingGroupName = module.app.asg_name
      }
    }
  }

  metric_query {
    id = "desired"

    metric {
      metric_name = "GroupDesiredCapacity"
      namespace   = "AWS/AutoScaling"
      period      = 60
      stat        = "Average"

      dimensions = {
        AutoScalingGroupName = module.app.asg_name
      }
    }
  }

  metric_query {
    id          = "capacity_diff"
    expression  = "inservice - desired"
    label       = "InService minus Desired"
    return_data = true
  }
}

# ============================
# Auto Scaling Group - CPU Utilization
# ============================
resource "aws_cloudwatch_metric_alarm" "asg_cpu" {
  alarm_name          = "${local.name_prefix}-ops-alarm-asg-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  alarm_description = "EC2 CPU utilization in ASG is high"

  alarm_actions = [module.operations.sns_alerts_topic_arn]
  ok_actions    = [module.operations.sns_alerts_topic_arn]

  dimensions = {
    AutoScalingGroupName = module.app.asg_name
  }
}

# ============================
# Target Group - UnHealthy Host Count
# ============================
resource "aws_cloudwatch_metric_alarm" "target_unhealthy" {
  alarm_name          = "${local.name_prefix}-ops-alarm-target-unhealthy"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1

  alarm_description = "Unhealthy targets detected"

  alarm_actions = [module.operations.sns_alerts_topic_arn]
  ok_actions    = [module.operations.sns_alerts_topic_arn]

  dimensions = {
    LoadBalancer = module.app.alb_arn_suffix
    TargetGroup  = module.app.target_group_arn_suffix
  }
}

# ============================
# Target Group - HTTP 5XX
# ============================
resource "aws_cloudwatch_metric_alarm" "target_5xx" {
  alarm_name          = "${local.name_prefix}-ops-alarm-target-5xx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  alarm_description = "Target group 5XX errors detected"

  alarm_actions = [module.operations.sns_alerts_topic_arn]
  ok_actions    = [module.operations.sns_alerts_topic_arn]

  dimensions = {
    LoadBalancer = module.app.alb_arn_suffix
    TargetGroup  = module.app.target_group_arn_suffix
  }
}

# ============================
# ALB - HTTP 5XX
# ============================
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${local.name_prefix}-ops-alarm-alb-5xx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  alarm_description = "ALB 5XX errors detected"

  alarm_actions = [module.operations.sns_alerts_topic_arn]
  ok_actions    = [module.operations.sns_alerts_topic_arn]

  dimensions = {
    LoadBalancer = module.app.alb_arn_suffix
  }
}

# ============================
# RDS - CPU Utilization
# ============================
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${local.name_prefix}-ops-alarm-rds-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  alarm_description = "RDS CPU utilization is high"

  alarm_actions = [module.operations.sns_alerts_topic_arn]
  ok_actions    = [module.operations.sns_alerts_topic_arn]

  dimensions = {
    DBInstanceIdentifier = module.db.db_instance_id
  }
}

# ============================
# RDS - Free Storage Space
# ============================
resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "${local.name_prefix}-ops-alarm-rds-storage"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 2147483648 # 2GB

  alarm_description = "RDS free storage is low"

  alarm_actions = [module.operations.sns_alerts_topic_arn]
  ok_actions    = [module.operations.sns_alerts_topic_arn]

  dimensions = {
    DBInstanceIdentifier = module.db.db_instance_id
  }
}

# ============================
# RDS - Database Connections
# ============================
resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  alarm_name          = "${local.name_prefix}-ops-alarm-rds-connections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  alarm_description = "RDS database connections are high"

  alarm_actions = [module.operations.sns_alerts_topic_arn]
  ok_actions    = [module.operations.sns_alerts_topic_arn]

  dimensions = {
    DBInstanceIdentifier = module.db.db_instance_id
  }
}