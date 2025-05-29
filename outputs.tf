output "alarm_topic_arn" {
  description = "The ARN of the SNS topic used for CloudWatch alarms"
  value       = aws_sns_topic.alarm.arn
}

output "findings_topic_arn" {
  description = "The ARN of the SNS topic used for incident findings reports"
  value       = local.findings_topic_arn
}

output "cloudwatch_alarm_arn" {
  description = "The ARN of the CloudWatch alarm monitoring ALB 5XX errors"
  value       = aws_cloudwatch_metric_alarm.alb_5xx.arn
}

output "incident_handler_lambda_arn" {
  description = "The ARN of the Lambda function that processes incidents"
  value       = aws_lambda_function.incident_handler.arn
}

output "incident_handler_lambda_name" {
  description = "The name of the Lambda function that processes incidents"
  value       = aws_lambda_function.incident_handler.function_name
}

output "lambda_role_arn" {
  description = "The ARN of the IAM role used by the incident handler Lambda"
  value       = aws_iam_role.lambda.arn
}