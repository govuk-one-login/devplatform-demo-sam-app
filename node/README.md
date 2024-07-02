# Reference fargate app

This project contains source code and supporting files for a fargate application, and ElastiCache clusters that you can deploy with the SAM CLI. It includes the following files and folders.

- server.js - Code for the application.
- template.yaml - A template that defines the application's AWS resources.

The application uses several AWS resources, including an API Gateway API. These resources are defined in the `template.yaml` file in this project.
You can update the template to add AWS resources through the same deployment process that updates your application code.

This application also includes an example of a frontend ECS canary deployment solution, for more information and an implamentaion guide please visit: [ECS - Canary Deployments Migration Guidance](https://govukverify.atlassian.net/wiki/spaces/PLAT/pages/3821732161/ECS+-+Canary+Deployments+Migration+Guidance)

## Deploy the sample application via Github Actions

You can run the Github action with your BRANCH. The action is called "Node deploy using Environment secrets"
https://github.com/govuk-one-login/devplatform-demo-sam-app/actions/workflows/node-deploy-using-environment-secrets.yml

When the above is running, then look in AWS Cloudfromation, there is a stack called "node-app", it should have new events.
If those all worked fine, then look in "Outputs" for the API Gateway URL and test it loads.


## Deploy the sample application with the CLI

Note: This method works, but it's easier to use the GitHub Actions method above.

- Follow the steps 1-3 of [How to deploy a container to Fargate with secure pipelines][1] docs to create a VPC, a pipeline and an ECR repo.
- From the outputs of the pipeline, ECR and container-signer stacks, you would require the `GitHubArtifactSourceBucketName`, the `ContainerRepositoryUri` and the `ContainerSignerKmsKeyArn`
- Checkout [di-devplatform-upload-action-ecr][2] repository. Use the [build-tag-push-ecr.sh][3] script to package and upload the fargate app to s3

Example use of the script from the root directory of this repo:

```bash
cd node

eval $(gds aws <AWS Account Alias> -e)
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin <AWS Account ID>.dkr.ecr.eu-west-2.amazonaws.com

export ECR_REGISTRY=<AWS Account ID>.dkr.ecr.eu-west-2.amazonaws.com
export ECR_REPO_NAME=<Use the ContainerRepositoryUri output from the ECR stack>

export CONTAINER_SIGN_KMS_KEY_ARN=<Use the ContainerSignerKmsKeyArn output from the container-signer stack>
export ARTIFACT_BUCKET_NAME=<Use the GitHubArtifactSourceBucketName output from the pipeline stack>

export GITHUB_REPOSITORY=devplatform-demo-sam-app
export GITHUB_SHA="$(git rev-parse HEAD)$(date +%H%M%S)"

export WORKING_DIRECTORY=.
export TEMPLATE_FILE=template.yaml

export DOCKER_BUILD_PATH=.
export DOCKERFILE=Dockerfile

<Path to di-devplatform-upload-action-ecr repo>/scripts/build-tag-push-ecr.sh
```

### Gotchas

When running [build-tag-push-ecr.sh][3] on MacOS, the `sed` command with -i option fails. There are two workarounds:

1. Install gnu-sed and replace
```
    brew install gnu-sed
    alias sed=gsed
```
2. Manually edit the sed -i in [build-tag-push-ecr.sh][3] to:
```
    sed -i '.bak' "s|CONTAINER-IMAGE-PLACEHOLDER|$ECR_REGISTRY/$ECR_REPO_NAME:$GITHUB_SHA|" cf-template.yaml
```

[1]: https://govukverify.atlassian.net/wiki/spaces/PLAT/pages/3107258369/How+to+deploy+a+container+to+Fargate+with+secure+pipelines
[2]: https://github.com/govuk-one-login/devplatform-upload-action-ecr
[3]: https://github.com/govuk-one-login/devplatform-upload-action-ecr/blob/main/scripts/build-tag-push-ecr.sh
