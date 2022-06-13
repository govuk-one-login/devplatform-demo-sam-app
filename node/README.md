# node-fargate-app

This project contains source code and supporting files for a fargate application, and ElastiCache clusters that you can deploy with the SAM CLI. It includes the following files and folders.

- server.js - Code for the application.
- template.yaml - A template that defines the application's AWS resources.

The application uses several AWS resources, including an API Gateway API. These resources are defined in the `template.yaml` file in this project.
You can update the template to add AWS resources through the same deployment process that updates your application code.

## Deploy the sample application with the CLI

- Follow the steps 1-3 of [How to deploy a container to Fargate with secure pipelines][1] docs to create a VPC, a pipeline and an ECR repo.
- From the outputs of the pipeline and ECR, copy the `GitHubArtifactSourceBucketName` and the `ContainerRepositoryUri`
- Add a tag to the `ContainerRepositoryUri` as shown in the example below
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