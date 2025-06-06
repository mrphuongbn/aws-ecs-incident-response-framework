"""AWS Bedrock helper module for ECS incident analysis.

This module provides functionality to analyze ECS incident data using AWS Bedrock
and store the analysis results in S3.
"""

import json
import os
from datetime import datetime

import boto3

bedrock = boto3.client("bedrock-runtime")
s3 = boto3.client("s3")

# Get bucket name from environment variable
BUCKET_NAME = os.environ.get("ANALYSIS_BUCKET_NAME")


def invoke_bedrock_analysis(context_data, model_id):
    """Analyze ECS incident data using AWS Bedrock and store results in S3.

    Args:
        context_data (dict): Dictionary containing incident metrics, logs, and traces
        model_id (str): AWS Bedrock model ID to use for analysis

    Returns:
        dict: Dictionary containing analysis results and S3 location
    """
    # Format prompt for plaintext response
    prompt = f"""
Analyze this AWS ECS incident and provide a detailed plaintext report:

METRICS:
{json.dumps(context_data["metrics"], indent=2)}

LOGS:
{json.dumps(context_data["logs"], indent=2)}

TRACES:
{json.dumps(context_data["traces"], indent=2)}

Please analyze the above data and provide:
1. A summary of the incident
2. The root cause analysis
3. Supporting evidence from the logs, metrics, and traces
4. Recommended immediate actions
5. Long-term preventive measures

Format your response as a plaintext report with clear section headers.
"""

    # Invoke Bedrock
    response = bedrock.invoke_model(
        modelId=model_id,
        contentType="application/json",
        accept="application/json",
        body=json.dumps({"prompt": prompt, "max_tokens": 2048, "temperature": 0.7}),
    )

    # Parse response - format depends on the model
    response_body = json.loads(response["body"].read())

    # Different models return different JSON structures
    if "completion" in response_body:
        analysis = response_body["completion"]
    elif "generation" in response_body:
        analysis = response_body["generation"]
    else:
        analysis = str(response_body)  # Fallback to string representation

    # Store in S3
    timestamp = datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
    cluster_name = context_data["cluster"]
    key = f"incidents/{cluster_name}/{timestamp}.txt"

    if BUCKET_NAME:
        try:
            s3.put_object(
                Bucket=BUCKET_NAME,
                Key=key,
                Body=analysis.encode("utf-8"),
                ContentType="text/plain",
            )
            s3_location = f"s3://{BUCKET_NAME}/{key}"
        except (
            s3.exceptions.NoSuchBucket,
            s3.exceptions.NoCredentialsError,
            s3.exceptions.BucketOperationError,
        ) as e:
            s3_location = f"Error storing in S3: {e!s}"
    else:
        s3_location = "No S3 bucket configured"

    return {"analysis": analysis, "s3_location": s3_location}
