import boto3

cloudwatch = boto3.client('cloudwatch')

def get_metrics(start_time, end_time):
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
