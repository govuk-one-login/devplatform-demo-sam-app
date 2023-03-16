data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "helloworld_lambda" {
  filename      = "../HelloWorldFunction/build/libs/HelloWorldFunction.jar"
  function_name = "helloworld_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "helloworld.App::handleRequest"

  source_code_hash = "../HelloWorldFunction/build/libs/HelloWorldFunction.jar"

  runtime = "java11"

  environment {
    variables = {
      environment = "dev"
    }
  }
}