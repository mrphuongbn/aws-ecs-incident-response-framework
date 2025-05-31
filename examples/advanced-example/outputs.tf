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

output "lambda_role_arn" {
  description = "The ARN of the IAM role used by the incident handler Lambda"
  value       = module.ecs_incident_response.lambda_role_arn
}

output "dashboard_url" {
  description = "URL to the CloudWatch dashboard for incident monitoring"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.incident_monitoring.dashboard_name}"
}

output "existing_sns_topic_arn" {
  description = "ARN of the existing SNS topic (if created)"
  value       = var.create_existing_sns_topic ? aws_sns_topic.existing_notifications[0].arn : null
}
