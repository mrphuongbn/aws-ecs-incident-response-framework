# Advanced Example

This example demonstrates advanced configuration options for the AWS ECS Incident Response Framework, including custom alarm thresholds, specific ECS service monitoring, existing SNS topic integration, and additional CloudWatch dashboard.

## What this example creates

- All resources from the basic example
- Custom CloudWatch dashboard for monitoring
- Integration with existing SNS topics
- Monitoring specific ECS services
- Production-ready configuration with higher thresholds

## Features Demonstrated

1. **Custom Alarm Configuration**: Higher error thresholds suitable for production
2. **Service-Specific Monitoring**: Monitor only specified ECS services
3. **Existing SNS Integration**: Use existing SNS topics for notifications
4. **CloudWatch Dashboard**: Additional monitoring dashboard
5. **Environment Tagging**: Proper resource tagging for production environments

## Usage

1. Update the `terraform.tfvars` file with your values:

```hcl
aws_region         = "us-east-1"
environment        = "prod"
name_prefix        = "prodapp"
alb_name          = "app/prodapp-alb/50abc123def"
ecs_cluster_name  = "prodapp-ecs-cluster"
ecs_service_names = ["web-service", "api-service", "worker-service"]
email_receiver    = "devops-team@company.com"
admin_email       = "admin@company.com"
```

2. Initialize and apply Terraform:

```bash
terraform init
terraform plan
terraform apply
```

## Configuration Details

This example uses:
- **Error threshold**: 50 (suitable for high-traffic production environments)
- **Evaluation periods**: 3 (requires 3 consecutive periods above threshold)
- **Period**: 300 seconds (5-minute evaluation periods)
- **Specific services**: Only monitors specified ECS services instead of entire cluster
- **Bedrock model**: Anthropic Claude 3 Sonnet for comprehensive AI analysis

## CloudWatch Dashboard

The example creates a CloudWatch dashboard that includes:
- ALB error metrics visualization
- Request count trends
- Lambda function logs for troubleshooting

Access the dashboard through the AWS Console or use the `dashboard_url` output.

## SNS Integration

This example demonstrates how to:
- Create and use existing SNS topics
- Send notifications to multiple email addresses
- Integrate with existing notification systems

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.3 installed
- ECS cluster with ALB already deployed
- AWS Bedrock enabled in your region
- Higher IAM permissions for CloudWatch dashboard creation
