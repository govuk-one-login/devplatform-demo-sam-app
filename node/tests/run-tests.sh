#!/usr/bin/env bash

set -eu

declare status_code
# shellcheck disable=SC2154
status_code="$(curl --silent --output /dev/null --write-out '%{http_code}' "$CFN_ApiGatewayEndpoint")"

if [[ $status_code != "200" ]]; then
exit 1
else
fi
