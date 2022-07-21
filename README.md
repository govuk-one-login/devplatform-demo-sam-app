# Dev Platform Demo SAM application

This repository contains a simple SAM application that uses a variety of common resources to help develop
the dev platform pipelines.

## Usage

This repository contains GitHub workflows that deploy two separate artifacts by interfacing with AWS CodePipelines
defined in the [di-devplatform-demo-pipelines](https://github.com/alphagov/di-devplatform-demo-pipelines)
repository.

The GitHub workflows make use of the following secrets:

* CONTAINER_SIGN_KMS_KEY - The ARN of the KMS key signing container images for [sam-app](sam-app)
* NODE_ARTIFACT_BUCKET - The name of the S3 bucket to deploy [node](node) to
* NODE_CONTAINER_SIGN_KMS_KEY - The ARN of the KMS key signing container images for [node](node)
* NODE_ROLE_TO_ASSUME - The ARN of the AWS role to assume when deploying [node](node)
* PARAMETERS_ARTIFACT_SOURCE_BUCKET_NAME - The name of the S3 bucket to deploy [parameters](parameters) to
* PARAMETERS_GH_ACTIONS_ROLE_ARN - The ARN of the AWS role to assume when deploying [parameters](parameters)
* SIGNING_PROFILE_NAME - The name of the AWS code signer profile to use
* SAM_APP_ARTIFACT_BUCKET_NAME - The name of the S3 bucket to deploy [sam-app](sam-app) to
* SAM_APP_GH_ACTIONS_ROLE_ARN - The ARN of the AWS role to assume when deploying [sam-app](sam-app)
* SAM_APP_VALIDATE_ROLE_ARN - The ARN of the AWS role that enables validation of the [sam-app](sam-app) SAM template
* SAM_APP_ECR_REPOSITORY_BUILD - The name of the ECR repository that contains the test image for the [sam-app](sam-app) in the build environment
* SAM_APP_ECR_REPOSITORY_STAGING - The name of the ECR repository that contains the test image for the [sam-app](sam-app) in the staging environment
* SAM_APP2_ARTIFACT_BUCKET_NAME - The name of the S3 bucket to deploy [sam-app2](sam-app2) to
* SAM_APP2_GH_ACTIONS_ROLE_ARN - The ARN of the AWS role to assume when deploying [sam-app2](sam-app2)

The values for these secrets are the Terraform outputs of the
[di-devplatform-demo-pipelines](https://github.com/alphagov/di-devplatform-demo-pipelines) repository.

## Getting Started

Tools required:

* AWS CLI with credentials to your target AWS account
* AWS SAM CLI (`brew install aws/tap/aws-sam-cli`)
* commitlint (`npm install -g @commitlint/cli`)
* pre-commit (`brew install pre-commit && pre-commit install && pre-commit install -tprepare-commit-msg -tcommit-msg`)
* GDS CLI (`brew tap alphagov/gds && brew install gds-cli`)
