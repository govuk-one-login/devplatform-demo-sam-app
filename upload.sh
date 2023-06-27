# ! /bin/bash

set -eu

 TEMPLATE_FILE=template.yaml 
 SIGNING_PROFILE=SigningProfile_930aGH3MZI96
 GITHUB_REPOSITORY=di-devplatform-demo-sam-app 
 GITHUB_SHA=abc123
 ARTIFACT_BUCKET=plat-1659-pipeline-githubartifactsourcebucket-1j8znq41n6buj
 GIT_TAG=madeuptag
 COMMIT_MSG="my commit"

echo "Parsing resources to be signed"
RESOURCES="$(yq '.Resources.* | select(has("Type") and .Type == "AWS::Serverless::Function" or .Type == "AWS::Serverless::LayerVersion") | path | .[1]' "$TEMPLATE_FILE" | xargs)"
read -ra LIST <<< "$RESOURCES"

# Construct the signing-profiles argument list
# e.g.: (HelloWorldFunction1="signing-profile-name" HelloWorldFunction2="signing-profile-name")
PROFILES=("${LIST[@]/%/="$SIGNING_PROFILE"}")

echo "Packaging SAM app"

# if [ "${#PROFILES[@]}" -eq 0 ]
# then
  # sam package --s3-bucket="$ARTIFACT_BUCKET" --output-template-file=cf-template.yaml
# else
  sam package --s3-bucket="$ARTIFACT_BUCKET" --output-template-file=cf-template.yaml --region eu-west-2 --signing-profiles HelloWorldFunction=$SIGNING_PROFILE HelloWorldFunction2=$SIGNING_PROFILE PreTrafficHook=$SIGNING_PROFILE
# fi

echo "Writing Lambda provenance"
yq '.Resources.* | select(has("Type") and .Type == "AWS::Serverless::Function") | .Properties.CodeUri' cf-template.yaml \
    | xargs -L1 -I{} aws s3 cp "{}" "{}" --metadata "repository=$GITHUB_REPOSITORY,commitsha=$GITHUB_SHA"
echo "Writing Lambda Layer provenance"
yq '.Resources.* | select(has("Type") and .Type == "AWS::Serverless::LayerVersion") | .Properties.ContentUri' cf-template.yaml \
    | xargs -L1 -I{} aws s3 cp "{}" "{}" --metadata "repository=$GITHUB_REPOSITORY,commitsha=$GITHUB_SHA"

echo "Zipping the CloudFormation template"
zip template.zip cf-template.yaml

echo "Uploading zipped CloudFormation artifact to S3"
aws s3 cp template.zip "s3://$ARTIFACT_BUCKET/template.zip" --metadata "repository=$GITHUB_REPOSITORY,commitsha=$GITHUB_SHA,committag=$GIT_TAG,commitmessage=$COMMIT_MSG"