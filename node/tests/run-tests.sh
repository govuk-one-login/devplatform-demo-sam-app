#!/usr/bin/env bash

set -eu

declare status_code
# shellcheck disable=SC2154
status_code="$(curl --silent --output /dev/null --write-out '%{http_code}' "$CFN_ApiGatewayEndpoint")"

print("this is the status code: $status_code")
if [[ $status_code != "200" ]]
then
    print("printing then statement")
fi
