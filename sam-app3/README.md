# sam-app3

This project contains an example container application with a ECS canary deployment template.
It uses `TimeBasedLinear` configuration to shift traffic from one version of the deployment to the other.
It also creates demo lambda for `BeforeAllowTraffic` hooks which can be modified to add any smoke tests that run before traffic is shifted to the replacement task set 

- image/ - Contains simple hello world application with Dockerfile
- template.yaml - A template that defines the application's AWS resources and deploys updates in a blue/green manner.

The application uses several AWS resources to get a container running in ECS. These resources are defined in the `template.yaml` file in this project. You can update the template to add AWS resources through the same deployment process that updates your application code.


## Deploy the sample application

To use the SAM CLI, you need the following tools.

* SAM CLI - [Install the SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
* Docker - [Install Docker community edition](https://hub.docker.com/search/?type=edition&offering=community)

- Create a new VPC and related resources as per [here]( https://govukverify.atlassian.net/wiki/spaces/PLAT/pages/3248357398/How+to+prepare+AWS+accounts+to+verify+container+signatures) or use an existing such VPC stack.
- Create ECR repository or use an existing one
- To build the application, generate docker image as below and push to the repo
  Authenticate your shell with your AWS account and then run the below in your shell. Note, replace `<AWS_ACCOUNT_ID>` with your account ID, and replace`<ECR_REPOSITORY>` with your ECR repository name.
```bash
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.eu-west-2.amazonaws.com
docker build -t <AWS_ACCOUNT_ID>.dkr.ecr.eu-west-2.amazonaws.com/<ECR_REPOSITORY>:latest image/
docker push <AWS_ACCOUNT_ID>.dkr.ecr.eu-west-2.amazonaws.com/<ECR_REPOSITORY>:latest
```
- To deploy your application for the first time, replace `CONTAINER-IMAGE-PLACEHOLDER`, `PLACEHOLDER_VPC_SAM3_STACK_NAME` and `PLACEHOLDER_SAM3_STACK_NAME` in `template.yaml` with the correct values from your AWS account.
```bash
sam build
sam deploy --guided
```
This will package and deploy your application to AWS, with a series of prompts:

* **Stack Name**: The name of the stack to deploy to CloudFormation. This should be unique to your account and region, and a good starting point would be something matching your project name.
* **AWS Region**: The AWS region you want to deploy your app to.
* **Confirm changes before deploy**: If set to yes, any change sets will be shown to you before execution for manual review. If set to no, the AWS SAM CLI will automatically deploy application changes.
* **Allow SAM CLI IAM role creation**: Many AWS SAM templates, including this example, create AWS IAM roles required for the AWS Lambda function(s) included to access AWS services. By default, these are scoped down to minimum required permissions. To deploy an AWS CloudFormation stack which creates or modifies IAM roles, the `CAPABILITY_IAM` value for `capabilities` must be provided. If permission isn't provided through this prompt, to deploy this example you must explicitly pass `--capabilities CAPABILITY_IAM` to the `sam deploy` command.
* **Save arguments to samconfig.toml**: If set to yes, your choices will be saved to a configuration file inside the project, so that in the future you can just re-run `sam deploy` without parameters to deploy changes to your application.

You can find your API Gateway Endpoint URL in the output values displayed after deployment.

- To see canary deployment in action on CodeDeploy, add the following e.g. `/test` endpoint to the demo app, follow above steps to build/push docker image and deploy the modified ECS TaskDefinition.
  As some traffic shifts to the new instance, successful response can be seen for `/test`

```bash
@app.route("/test")
def test():
print("This is a test call")
return "Test successful!"
```

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