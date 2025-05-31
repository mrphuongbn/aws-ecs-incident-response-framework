output "incident_handler_lambda_arn" {
  description = "The ARN of the Lambda function that processes incidents"
  value       = module.ecs_incident_response.incident_handler_lambda_arn
}

output "cloudwatch_alarm_arn" {
  description = "The ARN of the CloudWatch alarm monitoring ALB 5XX errors"
  value       = module.ecs_incident_response.cloudwatch_alarm_arn
}

output "findings_topic_arn" {
  description = "The ARN of the SNS topic used for incident findings reports"
  value       = module.ecs_incident_response.findings_topic_arn
}
