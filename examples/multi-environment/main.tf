# Multi-environment example
# This example demonstrates deploying the incident response framework
# across multiple environments (dev, staging, prod) with different configurations

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

# Local values for environment-specific configuration
locals {
  environments = {
    dev = {
      error_threshold    = 5
      evaluation_periods = 1
      period            = 60
      bedrock_model_id  = "amazon.titan-text-express-v1"
    }
    staging = {
      error_threshold    = 10
      evaluation_periods = 2
      period            = 120
      bedrock_model_id  = "anthropic.claude-3-haiku-20240307-v1:0"
    }
    prod = {
      error_threshold    = 50
      evaluation_periods = 3
      period            = 300
      bedrock_model_id  = "anthropic.claude-3-sonnet-20240229-v1:0"
    }
  }

  current_env = local.environments[var.environment]
}

# Deploy incident response framework for each environment
module "ecs_incident_response" {
  source = "github.com/mrphuongbn/aws-ecs-incident-response-framework"

  # Environment-specific naming
  name_prefix      = "${var.environment}-${var.app_name}"
  alb_name         = var.alb_configs[var.environment].alb_name
  ecs_cluster_name = var.alb_configs[var.environment].ecs_cluster_name
  email_receiver   = var.alb_configs[var.environment].email_receiver

  # Environment-specific thresholds
  error_threshold    = local.current_env.error_threshold
  evaluation_periods = local.current_env.evaluation_periods
  period            = local.current_env.period
  bedrock_model_id  = local.current_env.bedrock_model_id

  # Service configuration
  ecs_service_names = var.ecs_service_names
  region           = var.aws_region
}

# CloudWatch Log Group for centralized logging
resource "aws_cloudwatch_log_group" "incident_logs" {
  name              = "/aws/incident-response/${var.environment}-${var.app_name}"
  retention_in_days = var.environment == "prod" ? 90 : 30

  tags = {
    Environment = var.environment
    Application = var.app_name
    ManagedBy   = "terraform"
  }
}

# CloudWatch Metric Filter for tracking incident frequency
resource "aws_cloudwatch_log_metric_filter" "incident_frequency" {
  name           = "${var.environment}-${var.app_name}-incident-frequency"
  log_group_name = aws_cloudwatch_log_group.incident_logs.name
  pattern        = "[timestamp, request_id, level=\"ERROR\", message]"

  metric_transformation {
    name      = "IncidentCount"
    namespace = "ECS/IncidentResponse"
    value     = "1"
    
    default_value = 0
    
    dimensions = {
      Environment = var.environment
      Application = var.app_name
    }
  }
}

# Additional alarm for incident frequency monitoring
resource "aws_cloudwatch_metric_alarm" "high_incident_frequency" {
  alarm_name          = "${var.environment}-${var.app_name}-high-incident-frequency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "IncidentCount"
  namespace           = "ECS/IncidentResponse"
  period              = "3600"
  statistic           = "Sum"
  threshold           = var.environment == "prod" ? "5" : "3"
  alarm_description   = "This metric monitors incident frequency"
  alarm_actions       = [module.ecs_incident_response.alarm_topic_arn]

  dimensions = {
    Environment = var.environment
    Application = var.app_name
  }

  tags = {
    Environment = var.environment
    Application = var.app_name
    ManagedBy   = "terraform"
  }
}
