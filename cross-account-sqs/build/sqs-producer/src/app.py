import os

import boto3


def lambda_handler(event, context):
    client = boto3.client("sqs")

    client.send_message(
        QueueUrl=os.environ["TEST_QUEUE_URL"], MessageBody="This is the SQSProducer"
    )
