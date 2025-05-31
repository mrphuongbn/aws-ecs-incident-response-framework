# Basic example of AWS ECS Incident Response Framework
# This example demonstrates the minimal configuration required

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

# Use the incident response framework module
module "ecs_incident_response" {
  source = "github.com/mrphuongbn/aws-ecs-incident-response-framework"

  # Required variables
  name_prefix      = var.name_prefix
  alb_name         = var.alb_name
  ecs_cluster_name = var.ecs_cluster_name
  email_receiver   = var.email_receiver

  # Optional variables with defaults
  error_threshold    = 10
  evaluation_periods = 2
  period            = 60
  bedrock_model_id  = "anthropic.claude-3-sonnet-20240229-v1:0"
}
