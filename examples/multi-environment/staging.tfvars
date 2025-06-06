# Staging environment
environment = "staging"
aws_region  = "us-east-1"
app_name    = "myapp"

alb_configs = {
  dev = {
    alb_name         = "app/dev-myapp-alb/abc123"
    ecs_cluster_name = "dev-myapp-cluster"
    email_receiver   = "dev-team@company.com"
  }
  staging = {
    alb_name         = "app/staging-myapp-alb/def456"
    ecs_cluster_name = "staging-myapp-cluster"
    email_receiver   = "qa-team@company.com"
  }
  prod = {
    alb_name         = "app/prod-myapp-alb/ghi789"
    ecs_cluster_name = "prod-myapp-cluster"
    email_receiver   = "devops-team@company.com"
  }
}

ecs_service_names = ["api-service", "web-service", "worker-service"]
