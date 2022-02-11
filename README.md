# Dev Platform Demo SAM application

This repository contains a simple SAM application that uses a variety of common resources to help develop
the dev platform pipelines.

## Getting Started

Tools required:

* AWS CLI with credentials to your target AWS account
* AWS SAM CLI (`brew install aws/tap/aws-sam-cli`)
* commitlint (`npm install -g @commitlint/cli`)
* pre-commit (`brew install pre-commit && pre-commit install && pre-commit install -tprepare-commit-msg -tcommit-msg`)
* GDS CLI (`brew tap alphagov/gds && brew install gds-cli`)
