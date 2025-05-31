variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "my-app"
}

variable "alb_name" {
  description = "The ALB identifier (last part of ARN) for the metric dimension"
  type        = string
  # Example: "app/my-alb/50abc123def"
}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster to inspect"
  type        = string
  # Example: "my-ecs-cluster"
}

variable "email_receiver" {
  description = "Email address to receive incident findings"
  type        = string
  # Example: "devops-team@company.com"
}
