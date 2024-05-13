set -eu
URL=https://da0bkvp74e.execute-api.eu-west-2.amazonaws.com/healthcheck

declare status_code
# shellcheck disable=SC2154
status_code="$(curl --silent --output /dev/null --write-out "%{http_code}" "$URL")"
echo "$status_code"