set -eu
URL=https://da0bkvp74e.execute-api.eu-west-2.amazonaws.com/healthcheck

### This first test checks that the hello endpoint can serve up 20000 requests with a concurrency of 10 requests per second
ab -n 20000 -c 10 $URL

declare status_code
# shellcheck disable=SC2154
status_code="$(curl --silent --output /dev/null --write-out "%{http_code}" "$URL")"
echo "$status_code"