#!/bin/bash
set -eu

# Define the URL (can be passed as an argument, default is set)
URL="${1:-https://wdolmzkkrg.execute-api.eu-west-2.amazonaws.com/healthcheck}"

# Function to log the status of the script
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

log "Starting health check and performance test..."

# Check if the URL is reachable before running the tests
if ! curl --output /dev/null --silent --head --fail --max-time 10 "$URL"; then
  log "Error: The URL $URL is not reachable"
  exit 1
fi

log "URL is reachable. Starting performance test..."

# Run the Apache Benchmark test with error handling
if ! ab -n 20000 -c 10 "$URL" | tee performance_test_results.txt; then
  log "Error: ApacheBench encountered an issue during the test."
  exit 1
fi

log "Performance test completed."

# Retrieve and print the status code after the load test
status_code="$(curl --silent --output /dev/null --write-out "%{http_code}" --max-time 10 "$URL")"
log "HTTP Status Code: $status_code"

# Check if the status code is 200 (OK)
if [ "$status_code" -eq 200 ]; then
  log "Health check passed with status code 200."
else
  log "Health check failed with status code $status_code."
  exit 1
fi

log "Script execution completed successfully."