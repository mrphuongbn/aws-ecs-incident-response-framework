variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., prod, staging, dev)"
  type        = string
  default     = "prod"
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "prodapp"
}

variable "alb_name" {
  description = "The ALB identifier (last part of ARN) for the metric dimension"
  type        = string
  # Example: "app/prodapp-alb/50abc123def"
}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster to inspect"
  type        = string
  # Example: "prodapp-ecs-cluster"
}

variable "ecs_service_names" {
  description = "List of specific ECS service names to monitor (optional)"
  type        = list(string)
  default     = ["web-service", "api-service", "worker-service"]
}

variable "email_receiver" {
  description = "Email address to receive incident findings"
  type        = string
  # Example: "devops-team@company.com"
}

variable "admin_email" {
  description = "Admin email for additional notifications"
  type        = string
  # Example: "admin@company.com"
}

variable "error_threshold" {
  description = "5XX count threshold for CloudWatch alarm"
  type        = number
  default     = 50
}

variable "evaluation_periods" {
  description = "Number of periods to evaluate for the alarm"
  type        = number
  default     = 3
}

variable "period" {
  description = "Duration in seconds for each evaluation period"
  type        = number
  default     = 300
}

variable "bedrock_model_id" {
  description = "ID of the Bedrock foundation model to invoke"
  type        = string
  default     = "anthropic.claude-3-sonnet-20240229-v1:0"
}

variable "create_existing_sns_topic" {
  description = "Whether to create an existing SNS topic for demonstration"
  type        = bool
  default     = true
}

variable "use_existing_sns_topic" {
  description = "Whether to use the existing SNS topic for findings"
  type        = bool
  default     = true
}
