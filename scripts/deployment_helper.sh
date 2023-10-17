#!/usr/bin/env bash

set -e -ou pipefail

METADATA="repository=devplatform-demo-sam-app,commitsha=local-deployment"

function login() {
  local account="$1"
  echo "login into $account"
  eval "$(gds aws "$account" -e)"
}

function sam_build() {
  local project_dir
  project_dir=$(git rev-parse --show-toplevel)
  local app_to_deploy="$1"
  echo "Going into $app_to_deploy"
  cd "$project_dir/$app_to_deploy"
  echo "Building sam app"
  sam build
}

function sam_package() {
  local src_bucket_name="$1"
  local signing_profile_name="$2"
  echo "Creating package"
  sam package \
    --s3-bucket="$src_bucket_name" \
    --output-template-file=cf-template.yaml \
    --signing-profiles HelloWorldFunction="$signing_profile_name"
  echo "Adding provenance data"
  yq '.Resources.* | select(has("Type") and .Type == "AWS::Serverless::Function") | .Properties.CodeUri' cf-template.yaml \
    | xargs -L1 -I{} aws s3 cp "{}" "{}" --metadata $METADATA
}

function fargate_package() {
  local src_bucket_name="$1"
  local container_image="$2"
  echo "Creating package"
  sam package \
      --s3-bucket="$src_bucket_name" \
      --output-template-file=cf-template.yaml
  echo "Populating placeholders in template"
  sed -i'' -e "s%CONTAINER-IMAGE-PLACEHOLDER%$container_image%" cf-template.yaml
}

function upload_to_s3() {
  local src_bucket_name="$1"
  echo "Zipping file"
  zip template.zip cf-template.yaml
  echo "Uploading to S3"
  aws s3 cp template.zip "s3://$src_bucket_name/template.zip" --metadata $METADATA
}

function deploy() {
  local account="$1"
  local app_to_deploy="$2"
  local src_bucket_name="$3"
  local signing_profile_name="$4"

  login "$account"
  build "$app_to_deploy"
  package "$src_bucket_name" "$signing_profile_name"
  upload_to_s3 "$src_bucket_name"
}

"$@"
