# Sample stack for Integration Tests

This directory contains a sample stack for showing how to provide integration tests
with the permissions they need to interact with AWS resources as part of the test.

![The demo stack](../demo.png "Demo Stack")

## Deploying

### Via GitHub Actions

First deploy a pipeline:

```shell
../../helpers.sh apply_all_aws_integration_test_pipeline_infrastructure
```

The commit code into GitHub. The pipeline will update the deployed stack.

### Locally

After the pipeline is provisioned, the test container can be pushed.
See [../aws-integration](../aws-integration).

Finally, the stack can be deployed:

```shell
../../helpers.sh apply_aws_integration_test <stack-name> <test-role-arn>
```