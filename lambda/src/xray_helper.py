import boto3

xray = boto3.client('xray')

def get_traces(start_time, end_time):
    summaries = xray.get_trace_summaries(
        StartTime=start_time,
        EndTime=end_time,
        FilterExpression="fault = true OR error = true"
    )

    trace_ids = [summary['Id'] for summary in summaries['TraceSummaries']]
    
    traces = xray.batch_get_traces(TraceIds=trace_ids)
    return traces['Traces']
