#!/usr/bin/env bash

# List the items that are over the limit (mean+2*stdev) for method lines and complexity

RUN_NAME="${1:-2021_Annual}"
LANGUAGE="${2:-"javascript"}"
REPORTS_FOLDER="${3:-"$HOME/projects/reports"}"

type -t jq > /dev/null 2>&1 || { echo "needs jq. Install with 'brew install jq"; exit 1; }


get_limit()
{
    declare REPO="$1"
    declare RUN_NAME="$2"
    declare LANGUAGE="$3"
    declare METRIC_STATISTICS="$4"

    jq '.data[0].'"${METRIC_STATISTICS}"'.limit ' "${REPO}/${RUN_NAME}/statistics/${LANGUAGE}/counts_over_limit.json"
}

list_large_items()
{
    declare REPO="$1"
    declare RUN_NAME="$2"
    declare LIMIT="$3"
    declare METRIC_METRICS="$4"

    jq '[ .data[0].extracted_data[]
        | select(.'"${METRIC_METRICS}"' > '"${LIMIT}"')
        | {method_name: .method_name,
            '"${METRIC_METRICS}"': .'"${METRIC_METRICS}"',
            file: .location.file}
        ]' \
        "${REPO}/${RUN_NAME}/metrics/${LANGUAGE}/metrics_data.json"
}

list_large_metric()
{
    declare REPO="$1"
    declare RUN_NAME="$2"
    declare LANGUAGE="$3"
    declare METRIC_STATISTICS="$4"
    declare METRIC_METRICS="$5"

    declare LIMIT
    LIMIT="$(get_limit "${REPO}" "${RUN_NAME}" "${LANGUAGE}" "${METRIC_STATISTICS}" )"

    printf '"%s":' "${METRIC_METRICS}"
    printf '{'
    printf '"%s": %s,' "limit" "${LIMIT}"
    printf '"%s":' "large_items"
    list_large_items "${REPO}" "${RUN_NAME}" "${LIMIT}" "${METRIC_METRICS}"
    printf '}'
}

declare REPO_COUNT=0
printf '{ "%s":' "${RUN_NAME}"
printf '{'

for REPO in "${REPORTS_FOLDER}"/*; do
    [[ -d "${REPO}/${RUN_NAME}" ]] || continue

    (( REPO_COUNT > 0 )) && printf ','
    printf '"%s":' "$(basename "${REPO}")"
    printf '{'

    list_large_metric "${REPO}" "${RUN_NAME}" "${LANGUAGE}" "method_lines" "method_length"
    printf ','
    list_large_metric "${REPO}" "${RUN_NAME}" "${LANGUAGE}" "complexity" "cyclomatic_complexity"

    printf '}'

    ((++REPO_COUNT))
done
printf '}'
printf '}'
printf '\n'
