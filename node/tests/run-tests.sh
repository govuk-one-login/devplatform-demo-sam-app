#!/usr/bin/env bash

set -eu

declare status_code
# shellcheck disable=SC2154
status_code="$(curl --silent --output /dev/null --write-out '%{http_code}' "https://www.bbc.co.uk/")"

print("this is the status code:")
print(status_code)
if [[ $status_code != "200" ]]
then
    print("printing then statement")
    print(status_code)
fi
