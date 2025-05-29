variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "incident-handler" # Default prefix, can be overridden
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-1" # Default region, can be overridden
}
variable "alb_name" {
  description = "The ALB identifier (last part of ARN) for the metric dimension"
  type        = string

  validation {
    condition     = length(var.alb_name) > 0
    error_message = "The alb_name value must be provided."
  }
}

variable "error_threshold" {
  description = "5XX count threshold for CloudWatch alarm"
  type        = number
  default     = 5
}

variable "evaluation_periods" {
  description = "Number of periods to evaluate for the alarm"
  type        = number
  default     = 2
}

variable "period" {
  description = "Duration in seconds for each evaluation period"
  type        = number
  default     = 60 # 1 minutes
}

variable "bedrock_model_id" {
  description = "ID of the Bedrock foundation model to invoke"
  type        = string
  default     = "amazon.titan-text-express-v1" # Default model, can be overridden
}

variable "sns_topic_arn" {
  description = "Optional existing SNS topic ARN for notifications. If not provided, a new topic will be created"
  type        = Optional(string)
  default     = ""
}

variable "existing_findings_topic_arn" {
  description = "Optional existing SNS topic ARN for incident reports. If not provided, a new topic will be created."
  type        = string
  default     = ""
}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster to inspect"
  type        = string

  validation {
    condition     = length(var.ecs_cluster_name) > 0
    error_message = "The ecs_cluster_name value must be provided."
  }
}

variable "ecs_service_names" {
  description = "List of ECS service names to inspect (optional). If empty, inspect entire cluster."
  type        = list(string)
  default     = []
}
