#!/usr/bin/env bash

set -Eeuo pipefail

pyproject_dirs=$(find . -name pyproject.toml -print | grep -v .aws-sam | xargs dirname)

for pyproject in $pyproject_dirs
do
  pushd "$pyproject"
  project_name=${pyproject:2}
  echo "Running tests for $project_name"
  poetry install
  poetry run python -m pytest . -v
  echo "Exporting requirements.txt"
  poetry export -f requirements.txt --output requirements.txt
  popd
done

echo "SAM build"
sam build --use-container
