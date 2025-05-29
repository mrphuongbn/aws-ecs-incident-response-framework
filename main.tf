locals {
  # Local value to determine which SNS topic ARN to use
  findings_topic_arn = var.existing_findings_topic_arn != "" ? var.existing_findings_topic_arn : aws_sns_topic.findings[0].arn
}

# CloudWatch Metric Alarm for ALB 5XX errors
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.name_prefix}-${var.alb_name}-5xx-alarm"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  statistic           = "Sum"                  # Sum is appropriate for count metrics:contentReference[oaicite:10]{index=10}:contentReference[oaicite:11]{index=11}
  period              = var.period             # e.g. 60 seconds
  evaluation_periods  = var.evaluation_periods # e.g. 5
  threshold           = var.error_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching" # avoid alarms when no data (missing data means zero errors):contentReference[oaicite:12]{index=12}
  alarm_description   = "ALB 5XX error count exceeds threshold"

  # Action: send to SNS topic (or Lambda ARN for direct invoke)
  alarm_actions = [aws_sns_topic.alarm.arn]

  # Dimension must match the ALB’s identifier (e.g. "app/my-alb/50abc..."):contentReference[oaicite:13]{index=13}
  dimensions = {
    LoadBalancer = var.alb_name
  }
}

# SNS topic resource for the 5XX error alarm to trigger incident handling 
resource "aws_sns_topic" "alarm" {
  name = "${var.name_prefix}-alarm-topic"
}

# Permission for SNS to invoke the Lambda
resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowInvokeFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.incident_handler.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alarm.arn
}

# Subscribe the Lambda to the SNS topic
resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.alarm.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.incident_handler.arn
}


# IAM Role for Lambda
resource "aws_iam_role" "lambda" {
  name               = "${var.name_prefix}-lambda-role"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }
  EOF
}

# IAM Policy for Lambda (attached inline)
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "${var.name_prefix}-lambda-policy"
  role   = aws_iam_role.lambda.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:GetMetricData",
        "cloudwatch:GetMetricStatistics",
        "logs:FilterLogEvents",
        "logs:GetLogEvents",
        "logs:DescribeLogStreams",
        "xray:GetTraceSummaries",
        "xray:BatchGetTraces"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:ListFoundationModels"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "sns:Publish",
      "Resource": local.findings_topic_arn
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": "${aws_s3_bucket.analysis_results.arn}/*"
    }
  ]
}
EOF
}

# SNS topic for receiving a formatted incident report
# Optional existing SNS topic ARN for notifications. If not provided, a new topic will be created
resource "aws_sns_topic" "findings" {
  count = var.existing_findings_topic_arn == "" ? 1 : 0
  name  = "${var.name_prefix}-findings-topic"
}

# S3 bucket for storing incident analysis results
resource "aws_s3_bucket" "analysis_results" {
  bucket_prefix = "${var.name_prefix}-incident-analysis-"
  force_destroy = true # Allow terraform to delete the bucket with content
}

## Build the Lambda function package
resource "null_resource" "lambda_build" {
  provisioner "local-exec" {
    command = "cd ${path.module}/lambda && ./build_lambda_zip.sh"
  }

  triggers = {
    lambda_source = filesha256("${path.module}/lambda/src/handler.py")
    requirements  = filesha256("${path.module}/lambda/requirements.txt")
  }
}

resource "aws_lambda_function" "incident_handler" {
  function_name = "${var.name_prefix}-incident-handler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.handler"
  runtime       = "python3.9"
  timeout       = 60
  memory_size   = 512

  filename         = "${path.module}/lambda/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/lambda_function.zip")

  environment {
    variables = {
      SNS_TOPIC_ARN        = local.findings_topic_arn
      MODEL_ID             = var.bedrock_model_id
      ECS_CLUSTER_NAME     = var.ecs_cluster_name
      ECS_SERVICE_NAMES    = join(",", var.ecs_service_names) # comma-separated list
      ANALYSIS_BUCKET_NAME = aws_s3_bucket.analysis_results.id
    }
  }

  tracing_config {
    mode = "Active"
  }
}
