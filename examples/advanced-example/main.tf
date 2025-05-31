# Advanced example with custom configuration
# This example demonstrates advanced configuration options including
# existing SNS topics, specific ECS services, and custom thresholds

terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Existing SNS topic for notifications (optional)
resource "aws_sns_topic" "existing_notifications" {
  count = var.create_existing_sns_topic ? 1 : 0
  name  = "${var.name_prefix}-existing-notifications"
  
  tags = {
    Environment = var.environment
    Project     = "ECS-Incident-Response"
  }
}

resource "aws_sns_topic_subscription" "existing_notifications_email" {
  count     = var.create_existing_sns_topic ? 1 : 0
  topic_arn = aws_sns_topic.existing_notifications[0].arn
  protocol  = "email"
  endpoint  = var.admin_email
}

# Use the incident response framework module with advanced configuration
module "ecs_incident_response" {
  source = "github.com/mrphuongbn/aws-ecs-incident-response-framework"

  # Required variables
  name_prefix      = var.name_prefix
  alb_name         = var.alb_name
  ecs_cluster_name = var.ecs_cluster_name
  email_receiver   = var.email_receiver

  # Advanced configuration
  error_threshold           = var.error_threshold
  evaluation_periods        = var.evaluation_periods
  period                   = var.period
  bedrock_model_id         = var.bedrock_model_id
  ecs_service_names        = var.ecs_service_names
  existing_findings_topic_arn = var.use_existing_sns_topic ? aws_sns_topic.existing_notifications[0].arn : ""
  region                   = var.aws_region
}

# Additional CloudWatch dashboard for monitoring
resource "aws_cloudwatch_dashboard" "incident_monitoring" {
  dashboard_name = "${var.name_prefix}-incident-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", var.alb_name],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_name],
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ALB Error Metrics"
          period  = 300
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 24
        height = 6

        properties = {
          query   = "SOURCE '/aws/lambda/${module.ecs_incident_response.incident_handler_lambda_name}' | fields @timestamp, @message | sort @timestamp desc | limit 100"
          region  = var.aws_region
          title   = "Incident Handler Lambda Logs"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = "ECS-Incident-Response"
  }
}
