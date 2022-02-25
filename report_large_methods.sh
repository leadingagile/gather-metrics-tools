#!/usr/bin/env bash

# List the methods that are over the limit (mean+2*stdev)

RUN_NAME="${1:-2021_Annual}"
LANGUAGE="${2:-"javascript"}"
REPORTS_FOLDER="${3:-"$HOME/projects/reports"}"

type -t jq > /dev/null 2>&1 || { echo "needs jq. Install with 'brew install jq"; exit 1; }


list_large_methods()
{
    declare REPO="$1"
    declare RUN_NAME="$2"
    declare LIMIT_LINES="$3"

    jq '[ .data[0].extracted_data[]
        | select(.method_length > '"${LIMIT_LINES}"')
        | {method_name: .method_name,
            method_length: .method_length,
            file: .location.file}
        ]' \
        "${REPO}/${RUN_NAME}/metrics/javascript/metrics_data.json"

}

declare REPO_COUNT=0
printf '{ "%s":' "${RUN_NAME}"
printf '{'

for REPO in "${REPORTS_FOLDER}"/*; do
    [[ -d "${REPO}/${RUN_NAME}" ]] || continue

    (( REPO_COUNT > 0 )) && printf ','
    printf '"%s":' "$(basename "${REPO}")"

    declare LIMIT_LINES
    LIMIT_LINES="$(jq '.data[0].method_lines.limit ' "${REPO}/${RUN_NAME}/statistics/javascript/counts_over_limit.json")"

    printf '{'
    printf '"%s": %s,' "limit" "${LIMIT_LINES}"
    printf '"%s":' "large_methods"
    list_large_methods "${REPO}" "${RUN_NAME}" "${LIMIT_LINES}"
    printf '}'

    ((++REPO_COUNT))
done
printf '}'
printf '}'
printf '\n'
