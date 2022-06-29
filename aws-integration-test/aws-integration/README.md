# Integration Tests

This directory consists of a set of BDD integration tests that interact directly with
AWS resources (instead of automating a UI) to demonstrate how a stack can provide tests
with the required permissions to do this and work around AWS limitations where necessary.

The integration tests are written in Python using the Behave BDD framework and packaged 
as a Docker image that can be used with the secure delivery pipelines.

## Running

To run these tests locally, first provision the pipeline and stack in [../app](../app), then:

```shell
stack_name=<name of stack used to deploy ../app>

docker build -t aws-integration-test .

eventhandlerlambdaarn=$(aws cloudformation describe-stacks \
  --stack-name $stack_name \
  --query 'Stacks[0].Outputs[?OutputKey==`EventHandlerLambdaArn`].OutputValue' \
  --output text)
eventhandlerlambdaloggroup=$(aws cloudformation describe-stacks \
  --stack-name $stack_name \
  --query 'Stacks[0].Outputs[?OutputKey==`EventHandlerLambdaLogGroup`].OutputValue' \
  --output text)
auditbucket=$(aws cloudformation describe-stacks \
  --stack-name $stack_name \
  --query 'Stacks[0].Outputs[?OutputKey==`AuditBucket`].OutputValue' \
  --output text)
recordproducerlambdaarn=$(aws cloudformation describe-stacks \
  --stack-name $stack_name \
  --query 'Stacks[0].Outputs[?OutputKey==`RecordProducerLambdaArn`].OutputValue' \
  --output text)
  
docker run -t \
  -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  -e AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN" \
  -e AWS_SECURITY_TOKEN="$AWS_SECURITY_TOKEN" \
  -e AWS_DEFAULT_REGION="eu-west-2" \
  -e TEST_REPORT_DIR="/root" \
  -e TEST_REPORT_ABSOLUTE_DIR="/root" \
  -e CFN_EventHandlerLambdaArn="$eventhandlerlambdaarn" \
  -e CFN_EventHandlerLambdaLogGroup="$eventhandlerlambdaloggroup" \
  -e CFN_AuditBucket="$auditbucket" \
  -e CFN_RecordProducerLambdaArn="$recordproducerlambdaarn" \
  aws-integration-test:latest
```
