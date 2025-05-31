# Basic Example

This example demonstrates the minimal configuration required to deploy the AWS ECS Incident Response Framework.

## What this example creates

- CloudWatch alarm monitoring ALB 5XX errors
- Lambda function for incident analysis
- SNS topics for notifications
- S3 bucket for storing analysis results
- IAM roles and policies

## Usage

1. Update the `terraform.tfvars` file with your values:

```hcl
aws_region       = "us-east-1"
name_prefix      = "my-app"
alb_name         = "app/my-alb/50abc123def"
ecs_cluster_name = "my-ecs-cluster"
email_receiver   = "devops-team@company.com"
```

2. Initialize and apply Terraform:

```bash
terraform init
terraform plan
terraform apply
```

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.3 installed
- ECS cluster with ALB already deployed
- AWS Bedrock enabled in your region

## Configuration Details

This example uses:
- Error threshold: 10 (will trigger when ALB returns 10+ 5XX errors)
- Evaluation periods: 2 (alarm triggers after 2 consecutive periods above threshold)
- Period: 60 seconds (each evaluation period is 1 minute)
- Bedrock model: Anthropic Claude 3 Sonnet for AI analysis
