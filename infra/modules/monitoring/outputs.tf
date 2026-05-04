# ============================
# CloudWatch Alarms
# ============================
output "alarm_names" {
  description = "CloudWatch alarm names"
  value = [
    aws_cloudwatch_metric_alarm.asg_inservice.alarm_name,
    aws_cloudwatch_metric_alarm.asg_cpu.alarm_name,
    aws_cloudwatch_metric_alarm.target_unhealthy.alarm_name,
    aws_cloudwatch_metric_alarm.target_5xx.alarm_name,
    aws_cloudwatch_metric_alarm.alb_5xx.alarm_name,
    aws_cloudwatch_metric_alarm.rds_cpu.alarm_name,
    aws_cloudwatch_metric_alarm.rds_storage.alarm_name,
    aws_cloudwatch_metric_alarm.rds_connections.alarm_name
  ]
}