#!/usr/bin/env bash
# Doc blocks in this file follow the http://tomdoc.org format

set -Eeuo pipefail

function apply_aws_integration_test() {
  local stack_name="$1"
  local test_role_arn="$2"
  echo "Applying aws-int-test template to stack: $stack_name ..."

  if [[ "$(basename "$(pwd)")" == "di-devplatform-demo-sam-app" ]]; then
    cd aws-integration-test/app
  elif [[ "$(basename "$(pwd)")" == "aws-int-test" ]]; then
    cd app
  elif [[ "$(basename "$(pwd)")" != "app" ]]; then
    echo "Unable to locate integration test app directory"
    exit 1
  fi

  stack_state="$(aws cloudformation describe-stacks --stack-name "$stack_name" --query "Stacks[0].StackStatus" --output text || echo "NO_STACK")"

  if [[ "$stack_state" = "ROLLBACK_COMPLETE" ]]; then
    echo "Deleting stack aws-int-test (in ROLLBACK_COMPLETE state) ..."
    aws cloudformation delete-stack --stack-name="$stack_name" \
        && aws cloudformation wait stack-delete-complete --stack-name="$stack_name"
  fi

  echo "Building the aws-int-test ..."
  ./build.sh

  echo "Packaging aws-int-test ..."
  trap "rm cf-template.yaml" EXIT
  sam package \
    --resolve-s3 \
    --output-template-file=cf-template.yaml

  metadata_repo="di-devplatform-identity-broker"
  metadata_commitsha="local-test"

  echo "Adding provenance data ..."
  yq '.Resources.* | select(has("Type") and .Type == "AWS::Serverless::Function") | .Properties.CodeUri' cf-template.yaml \
    | xargs -L1 -I{} aws s3 cp "{}" "{}" --metadata "repository=$metadata_repo,commitsha=$metadata_commitsha"

  test_role_arn_parameter=""
  if [[ -n "$test_role_arn" ]]; then
    test_role_arn_parameter="ParameterKey=TestRoleArn,ParameterValue=$test_role_arn"
  fi

  echo "Deploying aws-int-test ..."
  # shellcheck disable=SC2086
  sam deploy \
     --stack-name="$stack_name" \
     --template="cf-template.yaml" \
     --capabilities CAPABILITY_IAM \
     --parameter-overrides \
        ParameterKey=Environment,ParameterValue=demo \
        $test_role_arn_parameter \
     --tags System="Dev Platform" \
            Product="GOV.UK Sign In" \
            Environment="demo" \
            repository="$metadata_repo" \
            commitsha="$metadata_commitsha"
}

# Public: Creates/updates all infrastructure needed in the demo environment
# to build, test and deploy the aws-int-test.
function apply_all_aws_integration_test_pipeline_infrastructure() {
  set -x
  echo "Get signing profile details ..."
  signing_profile_arn="$(aws cloudformation describe-stacks \
      --stack-name "signer" \
      --query "Stacks[0].Outputs[?OutputKey=='SigningProfileArn'].OutputValue" \
      --output text)"
  signing_profile_version_arn="$(aws cloudformation describe-stacks \
      --stack-name "signer" \
      --query "Stacks[0].Outputs[?OutputKey=='SigningProfileVersionArn'].OutputValue" \
      --output text)"

  echo "Apply pipeline in demo ..."
  apply_pipeline \
      "aws-int-test" \
      "$signing_profile_arn" \
      "$signing_profile_version_arn" \
      1 \
      "demo"

  echo "Apply test image repository ..."
  test_repo_uri="$(apply_test_image_repository "aws-int-test" "demo")"

  echo "Apply pipeline in demo (with test image) ..."
  apply_pipeline \
      "aws-int-test" \
      "$signing_profile_arn" \
      "$signing_profile_version_arn" \
      0 \
      "demo" \
      "$test_repo_uri"
}

# Public: Creates/updates a testing ECR repository. Assumes the current shell
# has credentials for the correct target account.
#
# $1 - The stack name that this testing repository is targeting.
# $2 - The name of the environment this test is run in
#
# Examples
#
#   apply_test_image_repository "oidc-api" "build"
function apply_test_image_repository() {
  app_stack_name="$1"
  environment_name="$2"
  pipe_stack_name="$app_stack_name"-pipeline
  test_image_repo_stack_name="$app_stack_name-$environment_name-ecr-repository"

  export AWS_RETRY_MODE=adaptive
  export AWS_MAX_ATTEMPTS=8

  stack_state="$(aws cloudformation describe-stacks \
      --stack-name "$test_image_repo_stack_name" \
      --query "Stacks[0].StackStatus" \
      --output text \
      || echo "NO_STACK")"

  if [[ "$stack_state" = "ROLLBACK_COMPLETE" ]]; then
    aws cloudformation delete-stack \
      --stack-name="$test_image_repo_stack_name" \
      && aws cloudformation wait stack-delete-complete \
           --stack-name="$test_image_repo_stack_name"
  fi

  create_or_update="$([[ $stack_state != "NO_STACK" && $stack_state != "ROLLBACK_COMPLETE" ]] \
      && echo update \
      || echo create)"


  aws cloudformation "$create_or_update"-stack \
      --stack-name="$test_image_repo_stack_name" \
      --template-url="https://template-storage-templatebucket-1upzyw6v9cs42.s3.amazonaws.com/test-image-repository/template.yaml"  \
      --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
      --parameters \
       ParameterKey=PipelineStackName,ParameterValue="$pipe_stack_name"  \
      --tags Key=Product,Value="GOV.UK Sign In" \
             Key=System,Value="Dev Platform" \
             Key=Environment,Value="demo" >/dev/null 2>&1 \
         && aws cloudformation wait stack-"$create_or_update"-complete \
              --stack-name="$test_image_repo_stack_name"

  aws cloudformation describe-stacks \
      --stack-name "$test_image_repo_stack_name" \
      --query "Stacks[0].Outputs[?OutputKey=='TestRunnerImageEcrRepositoryUri'].OutputValue" \
      --output text
}

# Public: Creates/updates a pipeline. Assumes the current shell
# has credentials for the correct target account.
#
# $1 - The stack name the pipeline deploys into.
# $2 - The arn of the signing profile
# $3 - The version arn of the signing profile
# $4 - Whether promotion is enabled or not (1 or 0)
# $5 - Name of the pipeline's environment
# $6 - [Optional] The URI of a testing image to run in the pipeline.
# $7 - [Optional] The ARN of a promotion bucket to have as the pipe's source.
#
# Examples
#
#   apply_pipeline "oidc-api" "arn:..." "arn:..." 1 "build"
function apply_pipeline() {
  app_stack_name="$1"
  signing_profile_arn="$2"
  signing_profile_version_arn="$3"
  is_promotion_enabled="$4"
  environment="$5"

  set +u
  test_ecr_repository_uri="$([[ -z "$6" ]] && echo false || echo "$6")" # Set variable if arg provided
  artifact_source_bucket_arn="$([[ -z "$7" ]] && echo false || echo "$7")" # Set variable if arg provided
  set -u

  pipe_stack_name="$app_stack_name"-pipeline

  export AWS_RETRY_MODE=adaptive
  export AWS_MAX_ATTEMPTS=8

  stack_state="$(aws cloudformation describe-stacks \
      --stack-name "$pipe_stack_name" \
      --query "Stacks[0].StackStatus" \
      --output text \
      || echo "NO_STACK")"

  if [[ "$stack_state" = "ROLLBACK_COMPLETE" ]]; then
    aws cloudformation delete-stack \
      --stack-name="$pipe_stack_name" \
      && aws cloudformation wait stack-delete-complete \
           --stack-name="$pipe_stack_name"
  fi

  test_ecr_repository_param=""
  if [[ "$test_ecr_repository_uri" != "false" ]]; then
    test_ecr_repository_param="ParameterKey=TestImageRepositoryUri,ParameterValue=$test_ecr_repository_uri"
  fi

  if [[ "$artifact_source_bucket_arn" == "false" ]]; then
    pipeline_source_param="ParameterKey=GitHubRepositoryName,ParameterValue=devplatform-demo-sam-app"
  else
    pipeline_source_param="ParameterKey=ArtifactSourceBucketArn,ParameterValue=$artifact_source_bucket_arn"
  fi

  if [[ "$is_promotion_enabled" == 1 ]]; then
    promotion_param="ParameterKey=IncludePromotion,ParameterValue=Yes ParameterKey=AllowedAccounts,ParameterValue=597482059283"
  else
    promotion_param="ParameterKey=IncludePromotion,ParameterValue=No"
  fi

  create_or_update="$([[ $stack_state != "NO_STACK" && $stack_state != "ROLLBACK_COMPLETE" ]] \
      && echo update \
      || echo create)"

  # shellcheck disable=SC2086
  aws cloudformation "$create_or_update"-stack \
      --stack-name="$pipe_stack_name" \
      --template-url="https://template-storage-templatebucket-1upzyw6v9cs42.s3.amazonaws.com/sam-deploy-pipeline/template.yaml" \
      --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
      --parameters \
       ParameterKey=SAMStackName,ParameterValue="$app_stack_name"  \
       ParameterKey=Environment,ParameterValue="$environment" \
       ParameterKey=SigningProfileArn,ParameterValue="$signing_profile_arn"  \
       ParameterKey=SigningProfileVersionArn,ParameterValue="$signing_profile_version_arn"  \
       $promotion_param $test_ecr_repository_param "$pipeline_source_param" \
        && aws cloudformation wait stack-"$create_or_update"-complete \
              --stack-name="$pipe_stack_name" \
        || echo "No updates to pipeline stack $pipe_stack_name"
}

function sam_build() {
  local app_to_deploy="$1"
  go_into_app_dir "$app_to_deploy"
  echo "Building sam app"
  sam build
}

function sam_package() {
  local app_to_deploy="$1"
  local src_bucket_name="$2"
  local metadata="$3"

  go_into_app_dir "$app_to_deploy"

  echo "Creating package"
  sam package \
    --s3-prefix="$app_to_deploy" \
    --s3-bucket="$src_bucket_name" \
    --output-template-file=cf-template.yaml
  echo "Adding provenance data"
  yq '.Resources.* | select(has("Type") and .Type == "AWS::Serverless::Function") | .Properties.CodeUri' cf-template.yaml \
    | xargs -L1 -I{} aws s3 cp "{}" "{}" --metadata "$metadata"
}

function upload_to_s3() {
  local app_to_deploy="$1"
  local src_bucket_name="$2"
  local metadata="$3"
  go_into_app_dir "$app_to_deploy"
  echo "Zipping file"
  zip template.zip cf-template.yaml
  echo "Uploading to S3"
  aws s3 cp template.zip "s3://$src_bucket_name/template.zip" --metadata "$metadata"
}

function go_into_app_dir() {
  local project_dir
  project_dir=$(git rev-parse --show-toplevel)
  local app_to_deploy="$1"
  echo "Going into $app_to_deploy"
  cd "$project_dir/$app_to_deploy"
}

function sync_sam_app() {
  local app_to_deploy="$1"
  local src_bucket_name="$2"
  local metadata="$3"
  sam_build "$app_to_deploy"
  sam_package "$app_to_deploy" "$src_bucket_name" "$metadata"
  upload_to_s3 "$app_to_deploy" "$src_bucket_name" "$metadata"
}

"$@"
