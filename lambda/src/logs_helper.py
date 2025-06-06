"""CloudWatch Logs helper module for retrieving ECS incident logs.

This module provides functionality to fetch CloudWatch logs
related to ECS incidents.
"""

import boto3

logs = boto3.client("logs")


def get_logs(start_time, end_time):
    """Retrieve CloudWatch logs for the specified time range.

    Args:
        start_time: Start time for log retrieval
        end_time: End time for log retrieval

    Returns:
        list: List of log messages matching the filter pattern
    """
    response = logs.filter_log_events(
        logGroupName="/ecs/my-service",
        startTime=int(start_time.timestamp() * 1000),
        endTime=int(end_time.timestamp() * 1000),
        filterPattern="?ERROR ?Exception ?Timeout",
    )
    return [event["message"] for event in response["events"]]
