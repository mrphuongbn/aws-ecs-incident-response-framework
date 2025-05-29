import boto3

logs = boto3.client('logs')

def get_logs(start_time, end_time):
    response = logs.filter_log_events(
        logGroupName='/ecs/my-service',
        startTime=int(start_time.timestamp() * 1000),
        endTime=int(end_time.timestamp() * 1000),
        filterPattern='?ERROR ?Exception ?Timeout'
    )
    return [event['message'] for event in response['events']]
