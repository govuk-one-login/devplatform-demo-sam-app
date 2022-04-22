#!/usr/bin/env bash

yq '.. | select(has("Type") and .Type == "AWS::Serverless::Function") | .Properties.CodeUri' cf-template.yaml \
    | xargs -L1 -I{} aws s3 cp "{}" "{}" --metadata "Repository=$GITHUB_REPOSITORY,CommitSHA=$GITHUB_SHA"
