"""
CloudWatch helper module for retrieving ECS incident metrics.

This module provides functionality to fetch CloudWatch metrics
related to ECS incidents.
"""

import boto3

cloudwatch = boto3.client('cloudwatch')


def get_metrics(start_time, end_time):
    """
    Retrieve CloudWatch metrics for the specified time range.
    
    Args:
        start_time: Start time for metric retrieval
        end_time: End time for metric retrieval
        
    Returns:
        list: List of metric data results from CloudWatch
    """
    response = cloudwatch.get_metric_data(
        MetricDataQueries=[
            {
                'Id': 'elb5xx',
                'MetricStat': {
                    'Metric': {
                        'Namespace': 'AWS/ApplicationELB',
                        'MetricName': 'HTTPCode_ELB_5XX_Count',
                        'Dimensions': [
                            {'Name': 'LoadBalancer', 'Value': '<alb_identifier>'}
                        ]
                    },
                    'Period': 60,
                    'Stat': 'Sum',
                },
                'ReturnData': True
            },
        ],
        StartTime=start_time,
        EndTime=end_time
    )
    return response['MetricDataResults']
