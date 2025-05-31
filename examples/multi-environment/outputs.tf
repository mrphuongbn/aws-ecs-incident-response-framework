output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "incident_handler_lambda_arn" {
  description = "The ARN of the Lambda function that processes incidents"
  value       = module.ecs_incident_response.incident_handler_lambda_arn
}

output "incident_handler_lambda_name" {
  description = "The name of the Lambda function that processes incidents"
  value       = module.ecs_incident_response.incident_handler_lambda_name
}

output "cloudwatch_alarm_arn" {
  description = "The ARN of the CloudWatch alarm monitoring ALB 5XX errors"
  value       = module.ecs_incident_response.cloudwatch_alarm_arn
}

output "alarm_topic_arn" {
  description = "The ARN of the SNS topic used for CloudWatch alarms"
  value       = module.ecs_incident_response.alarm_topic_arn
}

output "findings_topic_arn" {
  description = "The ARN of the SNS topic used for incident findings reports"
  value       = module.ecs_incident_response.findings_topic_arn
}

output "incident_frequency_alarm_arn" {
  description = "The ARN of the alarm monitoring incident frequency"
  value       = aws_cloudwatch_metric_alarm.high_incident_frequency.arn
}

output "log_group_name" {
  description = "The name of the CloudWatch log group for incident logs"
  value       = aws_cloudwatch_log_group.incident_logs.name
}

output "environment_config" {
  description = "Current environment configuration"
  value = {
    error_threshold    = local.current_env.error_threshold
    evaluation_periods = local.current_env.evaluation_periods
    period            = local.current_env.period
    bedrock_model_id  = local.current_env.bedrock_model_id
  }
}
