variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "myapp"
}

variable "alb_configs" {
  description = "ALB configurations per environment"
  type = map(object({
    alb_name         = string
    ecs_cluster_name = string
    email_receiver   = string
  }))
  
  # Example structure:
  # {
  #   dev = {
  #     alb_name         = "app/dev-myapp-alb/abc123"
  #     ecs_cluster_name = "dev-myapp-cluster"
  #     email_receiver   = "dev-team@company.com"
  #   }
  #   staging = {
  #     alb_name         = "app/staging-myapp-alb/def456"
  #     ecs_cluster_name = "staging-myapp-cluster"
  #     email_receiver   = "qa-team@company.com"
  #   }
  #   prod = {
  #     alb_name         = "app/prod-myapp-alb/ghi789"
  #     ecs_cluster_name = "prod-myapp-cluster"
  #     email_receiver   = "devops-team@company.com"
  #   }
  # }
}

variable "ecs_service_names" {
  description = "List of ECS service names to monitor"
  type        = list(string)
  default     = []
}
