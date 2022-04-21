#!/usr/bin/env bash

# List the methods that are over the limit (mean+2*stdev)

RUN_PATH="${1}"
LANGUAGE="${2:-"javascript"}"

[[ -n "${RUN_PATH}" ]] || { echo "Full path to run folder required"; exit 1; }
[[ -d "${RUN_PATH}/statistics" ]] || { echo "Run Path does not appear to have metrics data"; exit 1; }
type -t jq > /dev/null 2>&1 || { echo "needs jq. Install with 'brew install jq"; exit 1; }

LIMIT_LINES="$(jq '.data[0].method_lines.limit ' "${RUN_PATH}/statistics/${LANGUAGE}/counts_over_limit.json")"

jq -r '.data[0].extracted_data[]
    | select(.method_length > '"${LIMIT_LINES}"')
    | [.method_length, .method_name, .location.file]
    | @csv
    ' \
    "${RUN_PATH}/metrics/${LANGUAGE}/metrics_data.json"

