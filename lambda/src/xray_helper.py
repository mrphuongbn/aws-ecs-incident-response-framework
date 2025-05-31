"""
X-Ray helper module for retrieving ECS incident traces.

This module provides functionality to fetch X-Ray traces
related to ECS incidents.
"""

import boto3

xray = boto3.client('xray')


def get_traces(start_time, end_time):
    """
    Retrieve X-Ray traces for the specified time range.
    
    Args:
        start_time: Start time for trace retrieval
        end_time: End time for trace retrieval
        
    Returns:
        list: List of trace data containing fault or error information
    """
    summaries = xray.get_trace_summaries(
        StartTime=start_time,
        EndTime=end_time,
        FilterExpression="fault = true OR error = true"
    )

    trace_ids = [summary['Id'] for summary in summaries['TraceSummaries']]

    traces = xray.batch_get_traces(TraceIds=trace_ids)
    return traces['Traces']
