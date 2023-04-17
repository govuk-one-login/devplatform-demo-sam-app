# terraform-demo-app

This project contains source code and supporting files for a serverless application that you can deploy with terraform. It includes the following files and folders.

- HelloWorldFunction/src/main - Code for the application's Lambda function.
- HelloWorldFunction/src/test - Unit tests for the application code.
- terraform/- A directory that defines the application's AWS resources.

The application uses a lambda AWS resources. The resource is defined in the `lambda.tf` file in this project.

## Deploy the sample application

Dependencies needed to run the application locally:
`java`
`graddle`
`terraform`

To deploy the application from the command line please follow the steps below:

```
terraform init
terraform plan
terrafrom apply
```

## Unit tests

Tests are defined in the `HelloWorldFunction/src/test` folder in this project.

```bash
demo-package$ cd HelloWorldFunction
HelloWorldFunction$ gradle test
```