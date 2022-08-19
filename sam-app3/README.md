# sam-app3

This project contains an example container application with a ECS blue/green style deployment template.

- image/ - Contains simple hello world application with Dockerfile
- template.yaml - A template that defines the application's AWS resources and deploys updates in a blue/green manner.

The application uses several AWS resources to get a container running in ECS. These resources are defined in the `template.yaml` file in this project. You can update the template to add AWS resources through the same deployment process that updates your application code.


## Deploy the sample application

To use the SAM CLI, you need the following tools.

* SAM CLI - [Install the SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
* Docker - [Install Docker community edition](https://hub.docker.com/search/?type=edition&offering=community)

To build and deploy your application for the first time, replace `CONTAINER-IMAGE-PLACEHOLDER` and `PLACEHOLDER_VPC_STACK_NAME` in `template.yaml` with the correct values from on your AWS account.
Authenticate your shell with your AWS account and then run the below in your shell. Note, replace `<AWS_ACCOUNT_ID>` with your account ID, and replace`<ECR_REPOSITORY>` with your ECR repository name.

```bash
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.eu-west-2.amazonaws.com
docker build -t <AWS_ACCOUNT_ID>.dkr.ecr.eu-west-2.amazonaws.com/<ECR_REPOSITORY>:latest image/
docker push <AWS_ACCOUNT_ID>.dkr.ecr.eu-west-2.amazonaws.com/<ECR_REPOSITORY>:latest
sam build
sam deploy --guided
```

The first command will build the source of your application. The second command will package and deploy your application to AWS, with a series of prompts:

* **Stack Name**: The name of the stack to deploy to CloudFormation. This should be unique to your account and region, and a good starting point would be something matching your project name.
* **AWS Region**: The AWS region you want to deploy your app to.
* **Confirm changes before deploy**: If set to yes, any change sets will be shown to you before execution for manual review. If set to no, the AWS SAM CLI will automatically deploy application changes.
* **Allow SAM CLI IAM role creation**: Many AWS SAM templates, including this example, create AWS IAM roles required for the AWS Lambda function(s) included to access AWS services. By default, these are scoped down to minimum required permissions. To deploy an AWS CloudFormation stack which creates or modifies IAM roles, the `CAPABILITY_IAM` value for `capabilities` must be provided. If permission isn't provided through this prompt, to deploy this example you must explicitly pass `--capabilities CAPABILITY_IAM` to the `sam deploy` command.
* **Save arguments to samconfig.toml**: If set to yes, your choices will be saved to a configuration file inside the project, so that in the future you can just re-run `sam deploy` without parameters to deploy changes to your application.

You can find your API Gateway Endpoint URL in the output values displayed after deployment.


## Cleanup

To delete the sample application that you created, use the AWS CLI. Assuming you used your project name for the stack name, you can run the following:

```bash
aws cloudformation delete-stack --stack-name sam-app3
```

You will likely be required to empty the logging bucket before deleting the stack.

## Resources

See the [AWS SAM developer guide](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html) for an introduction to SAM specification, the SAM CLI, and serverless application concepts.

## Adding application autoscaling

### Gotchas
- Due to limitation of blue/green style deployments, the cloudformation import function can not be used to set the VPC resource Id's in the template.