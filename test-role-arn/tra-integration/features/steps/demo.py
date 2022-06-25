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
            startTime=now - (15 * 1000),
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
            print(results)
            if results['status'] == "Complete":
                break
            time.sleep(2)
        if len(results['results']) > 0:
            break
        time.sleep(5)

    assert len(results['results']) > 0
