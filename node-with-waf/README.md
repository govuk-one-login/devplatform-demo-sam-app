# The node-with-waf demo app has been deprecated

## node-with-waf-fargate-app

This project contains source code and supporting files for a fargate application, and ElastiCache clusters that you can deploy with the SAM CLI. It includes the following files and folders.

- server.js - Code for the application.
- template.yaml - A template that defines the application's AWS resources.

The application uses several AWS resources, including an REST API Gateway.
These resources are defined in the `template.yaml` file in this project.
You can update the template to add AWS resources through the same deployment process that updates your application code.

## Alarm errors - API Endpoints

The app now has 3 accessible endpoints (502, 503, 504). These errors are monitored in Cloudwatch https://github.com/govuk-one-login/devplatform-deploy/blob/617756839f5a83270b169269f5aec155d325ac8e/cloudfront-monitoring-alarm/template.yaml
- ```/giveme502 ``` - will result in a 'Bad Gateway' error.
- ```/giveme503 ``` - will render the server unavailable for 60 seconds. Because of the timeout engineers who are using the app for testing will need to wait for the 60 seconds before making any subsequent calls to the app.
- ```/giveme504 ``` - will result in a 'Gateway Timeout' error. The app has a delay of 30 secons which is longer than the cloudFront timeout.

## Deploy the sample application with the CLI

- Follow the steps 1-3 of [How to deploy a container to Fargate with secure pipelines][1] docs to create a VPC, a pipeline and an ECR repo.
- From the outputs of the pipeline and ECR, copy the `GitHubArtifactSourceBucketName` and the `ContainerRepositoryUri`
- Add a tag to the `ContainerRepositoryUri` as shown in the example below
- Provision [WAFv2][3] stack. Its output `WAFv2ACLArn` is imported by node-with-waf application stack
- Use the [deployment_helper.sh][2] to package and upload the fargate app into s3

example use of the script:
```
#!/usr/bin/env bash

set -e -ou pipefail

source scripts/deployment_helper.sh

ARTIFACT_BUCKET="{GitHubArtifactSourceBucketName}"
CONTAINER_IMAGE="{ContainerRepositoryUri}:{tag}"

login "{gds_role_to_assume}"

cd {fargate_app_directory}

fargate_package $ARTIFACT_BUCKET $CONTAINER_IMAGE
upload_to_s3 $ARTIFACT_BUCKET
```

[1]: https://govukverify.atlassian.net/wiki/spaces/PLAT/pages/3107258369/How+to+deploy+a+container+to+Fargate+with+secure+pipelines
[2]: /scripts/deployment_helper.sh
[3]: ./WAFv2/template.yaml

