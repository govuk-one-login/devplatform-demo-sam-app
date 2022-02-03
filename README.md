# Dev Platform Build Demo Code

This repository contains work-in-progress by the dev platform team for CI/CD pipelines for securely delivering code to production.

## Getting Started

Tools required:

* AWS CLI with credentials to your target AWS account
* AWS SAM CLI (`brew install aws/tap/aws-sam-cli`)
* Terraform
* tflint (`brew install tflint && (cd routine-pipeline-module/examples/pipeline-demo && tflint --init)`)
* pre-commit (`brew install pre-commit && pre-commit install`)

