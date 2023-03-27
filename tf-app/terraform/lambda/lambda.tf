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

resource "random_id" "id" {
  byte_length = 8
}

resource "aws_iam_role" "iam_for_lambda" {
  name                 = "iam_for_lambda-${random_id.id.hex}"
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "helloworld_lambda" {
  filename      = "../../HelloWorldFunction/build/libs/HelloWorldFunction.jar"
  function_name = "helloworld_lambda-${random_id.id.hex}"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "helloworld.App::handleRequest"

  source_code_hash = "../../HelloWorldFunction/build/libs/HelloWorldFunction.jar"

  runtime = "java11"

  environment {
    variables = {
      environment = "dev"
    }
  }
}