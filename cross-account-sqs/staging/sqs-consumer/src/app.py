def lambda_handler(event, context):
    body = event["Records"][0]["body"]

    print(body)
