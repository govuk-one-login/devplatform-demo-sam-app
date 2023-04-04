import base64
import datetime
import json

import boto3


def jsonconverter(o):
    if isinstance(o, datetime.datetime):
        return o.__str__()


def lambda_handler(event, context):
    client = boto3.client("firehose")

    delivery_stream_name = event["DeliveryStreamName"]

    if event["Type"] == "Describe":
        return json.loads(
            json.dumps(
                client.describe_delivery_stream(
                    DeliveryStreamName=delivery_stream_name
                ),
                default=jsonconverter,
            )
        )
    else:
        return json.loads(
            json.dumps(
                client.put_record(
                    DeliveryStreamName=delivery_stream_name,
                    Record={
                        "Data": base64.b64encode(
                            json.dumps(event["Data"]).encode("ascii")
                        )
                    },
                ),
                default=jsonconverter,
            )
        )
