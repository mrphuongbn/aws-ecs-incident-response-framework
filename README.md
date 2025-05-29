# Introduction

The module provides a repeatable incident response framework. When the ALB’s 5XX error count crosses the defined threshold, the system automatically gathers the context, leverages generative AI to diagnose the issue, and notifies teams with a concise report – turning raw alarms into actionable insights

## Why is this project useful?

We set up an ECS cluster with turning on observability features like CloudWatch Container Insights, enabling detailed monitoring and logging. Then what?

When an issue arises, we still need to check the logs, analyze the situation, and figure out the root cause. This can be time-consuming and error-prone, especially in complex environments.

Instead, we can leverage the power of automation and AI. By integrating AWS Lambda with CloudWatch alarms, we can automatically trigger a investigation process whenever a 5XX error is detected. The Lambda function collects relevant logs, metrics, and traces, then uses generative AI to analyze the data and generate a concise report.

This project is useful for organizations that want to automate their incident response processes, especially in environments like AWS ECS. It helps teams quickly identify and respond to issues, reducing downtime and improving overall system reliability.

## Getting started

### Architecture flows

![](https://raw.githubusercontent.com/mrphuongbn/aws-ecs-incident-response-framework/main/docs/incident-response-framework-flow.png)

### Prerequisites

- AWS Account with necessary permissions to create resources like IAM role, IAM policy, CloudWatch, SNS, Lambda, and Bedrock.
- Enable logs, X-Ray on ECS services.
- Enable AWS Bedrock service and the model you want to use for analysis (e.g., Anthropic Claude) in your AWS region.
- Ensure the connectivity from the AWS public services like the Lambda function, Cloudwatch, X-ray to the ECS cluster. The air-gapped environment need to have the VPC endpoints configured for the AWS services.

### Example Terraform Module Usage

```hcl
module "alb_incident_response" {
  source            = "github.com/mrphuongbn/aws-ecs-incident-response-framework"
  name_prefix       = "prodapp"
  alb_name          = "app/prodapp-alb/50abc123def"
  error_threshold   = 50
  evaluation_periods = 5
  period            = 60
  bedrock_model_id  = "anthropic.claude-3-sonnet-20240229-v1:0"

  ecs_cluster_name  = "prodapp-ecs-cluster"
  ecs_service_names = ["service1", "service2", "service3"] # or empty for all services
  # (Optionally existing SNS ARNs or other configs)
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.alb_5xx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_role.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_function.incident_handler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.allow_sns_invoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket.analysis_results](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_sns_topic.alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.findings](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [null_resource.lambda_build](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | The ALB identifier (last part of ARN) for the metric dimension | `string` | n/a | yes |
| <a name="input_bedrock_model_id"></a> [bedrock\_model\_id](#input\_bedrock\_model\_id) | ID of the Bedrock foundation model to invoke | `string` | `"amazon.titan-text-express-v1"` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | The name of the ECS cluster to inspect | `string` | n/a | yes |
| <a name="input_ecs_service_names"></a> [ecs\_service\_names](#input\_ecs\_service\_names) | List of ECS service names to inspect (optional). If empty, inspect entire cluster. | `list(string)` | `[]` | no |
| <a name="input_error_threshold"></a> [error\_threshold](#input\_error\_threshold) | 5XX count threshold for CloudWatch alarm | `number` | `5` | no |
| <a name="input_evaluation_periods"></a> [evaluation\_periods](#input\_evaluation\_periods) | Number of periods to evaluate for the alarm | `number` | `2` | no |
| <a name="input_existing_findings_topic_arn"></a> [existing\_findings\_topic\_arn](#input\_existing\_findings\_topic\_arn) | Optional existing SNS topic ARN for incident reports. If not provided, a new topic will be created. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for naming resources | `string` | `"incident-handler"` | no |
| <a name="input_period"></a> [period](#input\_period) | Duration in seconds for each evaluation period | `number` | `60` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy resources | `string` | `"ap-southeast-1"` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | Optional existing SNS topic ARN for notifications. If not provided, a new topic will be created | `Optional(string)` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alarm_topic_arn"></a> [alarm\_topic\_arn](#output\_alarm\_topic\_arn) | The ARN of the SNS topic used for CloudWatch alarms |
| <a name="output_cloudwatch_alarm_arn"></a> [cloudwatch\_alarm\_arn](#output\_cloudwatch\_alarm\_arn) | The ARN of the CloudWatch alarm monitoring ALB 5XX errors |
| <a name="output_findings_topic_arn"></a> [findings\_topic\_arn](#output\_findings\_topic\_arn) | The ARN of the SNS topic used for incident findings reports |
| <a name="output_incident_handler_lambda_arn"></a> [incident\_handler\_lambda\_arn](#output\_incident\_handler\_lambda\_arn) | The ARN of the Lambda function that processes incidents |
| <a name="output_incident_handler_lambda_name"></a> [incident\_handler\_lambda\_name](#output\_incident\_handler\_lambda\_name) | The name of the Lambda function that processes incidents |
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | The ARN of the IAM role used by the incident handler Lambda |
<!-- END_TF_DOCS -->

### What's next?

After setting up the incident response framework, you can extend its capabilities by integrating with other AWS services like SNS for notifications, or even third-party tools for enhanced observability, or triggering workflows to remediate some common issues automatically.

You can also explore using more advanced AI models or custom logic in the Lambda function to improve the analysis and reporting process.
