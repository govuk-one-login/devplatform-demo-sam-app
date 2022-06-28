import os
import boto3


def lambda_handler(event, context):
    client = boto3.client("firehose")

    client.put_record(
        DeliveryStreamName=os.environ.get("DELIVERY_STREAM"),
        Record=event,
    )
