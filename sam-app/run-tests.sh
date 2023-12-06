#!/usr/bin/env bash

set -eu


### This first test checks that the hello endpoint can serve up 200 requests with a concurrency of 10 requests per second

ab -n 200 -c 20 $CFN_HelloWorldApi/hello

### This first test checks that the hello2 endpoint can serve up 200 requests with a concurrency of 10 requests per second

ab -n 200 -c 20 $CFN_HelloWorldApi/hello2


### The following test checks that the endpoint returns a 200 response

declare status_code
# shellcheck disable=SC2154
status_code="$(curl --silent --output /dev/null --write-out '%{http_code}' "$CFN_HelloWorldApi")"

if [[ $status_code != "200" ]]; then
  cat <<EOF > "$TEST_REPORT_DIR/result.json"
[
  {
    "uri": "test.sh",
    "name": "Acceptance test",
    "elements": [
      {
        "type": "scenario",
        "name": "API Gateway request",
        "line": 6,
        "steps": [
          {
            "keyword": "Given ",
            "name": "this step fails",
            "line": 6,
            "match": {
              "location": "test.sh:4"
            },
            "result": {
              "status": "failed",
              "error_message": " Lambda did not return HTTP status code 200",
              "duration": 1
            }
          }
        ]
      }
    ]
  }
]
EOF
exit 1
else
  cat <<EOF > "$TEST_REPORT_DIR/result.json"
[
  {
    "uri": "test.sh",
    "name": "Acceptance test",
    "elements": [
      {
        "type": "scenario",
        "name": "API Gateway request",
        "line": 6,
        "steps": [
          {
            "keyword": "Given ",
            "name": "this step fails",
            "line": 6,
            "match": {
              "location": "test.sh:4"
            },
            "result": {
              "status": "passed",
              "duration": 1
            }
          }
        ]
      }
    ]
  }
]
EOF
fi
