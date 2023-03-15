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
  name               = "iam_for_lambda_fran"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# data "archive_file" "lambda" {
#   type        = "zip"
#   source_file = "../HelloWorldFunction/src/main/java/helloworld/App.java"
#   output_path = "lambda_function_payload.zip"
# }

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "../HelloWorldFunction/build/libs/HelloWorldFunction.jar"
  function_name = "lambda_function_name_fran"
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