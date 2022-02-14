# Dev Platform Demo SAM application

This repository contains a simple SAM application that uses a variety of common resources to help develop
the dev platform pipelines.

## Usage

This repository contains GitHub workflows that deploy two separate artifacts by interfacing with AWS CodePipelines
defined in the [di-devplatform-demo-pipelines](https://github.com/alphagov/di-devplatform-demo-pipelines)
repository.

The GitHub workflows make use of the following secrets:

* SIGNING_PROFILE - The name of the AWS code signer profile to use
* SAM_APP_ARTIFACT_BUCKET - The name of the S3 bucket to deploy [sam-app](sam-app) to
* SAM_APP_ROLE_TO_ASSUME - The ARN of the AWS role to assume when deploying [sam-app](sam-app)
* SAM_APP2_ARTIFACT_BUCKET - The name of the S3 bucket to deploy [sam-app2](sam-app2) to
* SAM_APP2_ROLE_TO_ASSUME - The ARN of the AWS role to assume when deploying [sam-app2](sam-app2)

The values for these secrets are the Terraform outputs of the 
[di-devplatform-demo-pipelines](https://github.com/alphagov/di-devplatform-demo-pipelines) repository.

## Getting Started

Tools required:

* AWS CLI with credentials to your target AWS account
* AWS SAM CLI (`brew install aws/tap/aws-sam-cli`)
* commitlint (`npm install -g @commitlint/cli`)
* pre-commit (`brew install pre-commit && pre-commit install && pre-commit install -tprepare-commit-msg -tcommit-msg`)
* GDS CLI (`brew tap alphagov/gds && brew install gds-cli`)
