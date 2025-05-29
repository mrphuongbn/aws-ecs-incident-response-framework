import os
import json
import boto3
import bedrock_helper
import cloudwatch_helper
import logs_helper
import xray_helper

# Environment variables
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']
MODEL_ID = os.environ['MODEL_ID']
ECS_CLUSTER_NAME = os.environ['ECS_CLUSTER_NAME']
ECS_SERVICE_NAMES = os.environ.get('ECS_SERVICE_NAMES', '').split(',') if os.environ.get('ECS_SERVICE_NAMES') else []

sns_client = boto3.client('sns')

def handler(event, context):
    # Extract alarm timestamp from CloudWatch alarm event
    alarm_time = extract_alarm_time(event)

    # Define time range for data retrieval (e.g., ±15 minutes)
    start_time, end_time = define_time_window(alarm_time, minutes=15)

    # Collect incident data with ECS context
    metrics = cloudwatch_helper.get_metrics(
        ECS_CLUSTER_NAME, 
        ECS_SERVICE_NAMES, 
        start_time, 
        end_time
    )
    logs = logs_helper.get_logs(
        ECS_CLUSTER_NAME, 
        ECS_SERVICE_NAMES, 
        start_time, 
        end_time
    )
    traces = xray_helper.get_traces(
        ECS_CLUSTER_NAME, 
        ECS_SERVICE_NAMES, 
        start_time, 
        end_time
    )

    # Prepare data for Bedrock
    incident_context = {
        "cluster": ECS_CLUSTER_NAME,
        "services": ECS_SERVICE_NAMES,
        "metrics": metrics,
        "logs": logs,
        "traces": traces
    }

    summary = bedrock_helper.invoke_bedrock_analysis(incident_context, MODEL_ID)

    # Publish result to SNS
    publish_summary_to_sns(summary)

def extract_alarm_time(event):
    # Extract alarm timestamp from event JSON
    alarm_time_str = event['Records'][0]['Sns']['Timestamp']
    return alarm_time_str

def define_time_window(alarm_time_str, minutes=15):
    from datetime import datetime, timedelta
    alarm_time = datetime.strptime(alarm_time_str, "%Y-%m-%dT%H:%M:%S.%fZ")
    start_time = alarm_time - timedelta(minutes=minutes)
    end_time = alarm_time + timedelta(minutes=minutes)
    return start_time, end_time

def publish_summary_to_sns(summary):
    sns_client.publish(
        TopicArn=SNS_TOPIC_ARN,
        Message=json.dumps(summary),
        Subject=f"Incident Summary - Cluster: {ECS_CLUSTER_NAME}"
    )
