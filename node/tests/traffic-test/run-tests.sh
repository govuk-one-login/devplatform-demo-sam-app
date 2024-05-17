set -eu

# shellcheck disable=SC2154
URL=$CFN_ApiGatewayEndpoint/healthcheck

### This first test checks that the hello endpoint can serve up 100000 requests with a concurrency of 10 requests per second
ab -n 100000 -c 10 "$URL"

declare status_code
# shellcheck disable=SC2154
status_code="$(curl --silent --output /dev/null --write-out '%{http_code}' "$URL")"

echo "$status_code"