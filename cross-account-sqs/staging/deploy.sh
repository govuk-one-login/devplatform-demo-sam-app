#!/usr/bin/env bash

sam package \
  --region eu-west-2 \
  --s3-bucket artifactsource-sqsc \
  --signing-profiles Consumer=SigningProfile_8pDw5g8ciqfR \
  --output-template-file cf-template.yaml
~/development/gds/devplatform/di-devplatform-demo-sam-app/.github/scripts/write-lambda-provenance.sh
zip template.zip cf-template.yaml
aws s3 cp template.zip s3://artifactsource-sqsc --metadata "repository=test,commitsha=test"
