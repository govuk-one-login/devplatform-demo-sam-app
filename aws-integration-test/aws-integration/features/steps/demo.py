import calendar
import time
from datetime import datetime
import json

import boto3
from behave import given, when, then


@given("I have an event handler deployed")
def step_impl(context):  # noqa: F811
    client = boto3.client('lambda')
    client.get_function(
        FunctionName=context.config.userdata['EventHandlerLambdaArn']
    )


@when("I invoke with an audit message \"{text}\"")
def step_impl(context, text):  # noqa: F811
    client = boto3.client('lambda')
    result = client.invoke(
        FunctionName=context.config.userdata['EventHandlerLambdaArn'],
        InvocationType='Event',
        Payload=json.dumps({
            "Message": text
        })
    )
    assert result['StatusCode'] == 202


@then("The audit message \"{text}\" is emitted to a CloudWatch Log")
def step_impl(context, text):
    client = boto3.client('logs')
    now = calendar.timegm(datetime.utcnow().timetuple())
    results = {}
    for queries in range(0, 5):
        query_id = client.start_query(
            logGroupName=context.config.userdata['EventHandlerLambdaLogGroup'],
            startTime=now - (20 * 1000),
            endTime=now,
            queryString=f'''
    fields @timestamp, Message
        | filter Message = "{text}"
        | sort @timestamp desc
        | limit 10
    '''
        )
        for tries in range(0, 5):
            results = client.get_query_results(
                queryId=query_id['queryId']
            )
            print(f'Query {queries}; Try {tries}')
            if results['status'] == "Complete":
                break
            time.sleep(2)
        if len(results['results']) > 0:
            break
        time.sleep(5)

    assert len(results['results']) > 0


def get_last_modified_date(client, bucket_name):
    # get last modified date
    now = datetime.utcnow()

    result = client.list_objects_v2(
        Bucket=bucket_name,
        Prefix=f'{now.year}/{now.month:02d}/{now.day:02d}/'
    )

    last_modified = None
    for obj in result['Contents']:
        if last_modified is None or last_modified < obj['LastModified']:
            last_modified = obj['LastModified']

    return last_modified


@then("The audit message is written to an S3 bucket")
def step_impl(context):
    bucket_name = context.config.userdata['AuditBucket']
    client = boto3.client('s3')

    last_modified = get_last_modified_date(client, bucket_name)

    updated = False
    for tries in range(0, 18):
        time.sleep(5)
        new_last_modified = get_last_modified_date(client, bucket_name)
        if new_last_modified is not None and new_last_modified != last_modified:
            updated = True
            break

    assert updated
