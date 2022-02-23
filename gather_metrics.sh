#!/usr/bin/env bash

# Run the 'metrics.utility gather-multi' tool
# Processes all of the repositories found in the PROJECTS_FOLDER to
#   create a new run of data to be recorded as RUN_NAME
#   beginning at START_DATE in each of the repostories

# Be sure each repository is currently on the branch you are
#   interested in evaluating


# before using:
#   (you probably need to be OFF the VPN to do this)
# authenticate with docker registry (currently hosted by LeadingAgile)
#   Using azure cli (brew install azure-cli)
#       az login
#       az acr login --name leadingagilestudios
# get the docker image
#   docker pull leadingagilestudios.azurecr.io/analysis/gather-cli:0.2.0


RUN_NAME="${1:-"$(date -j +"%Y-%m-%d_%H-%M-%S%z")"}"
START_DATE="${2:-"$(date -j +"%Y-%m-%d")"}"
STEPS="${3:-52}"
CONFIG_FILE="$4"
PROJECTS_FOLDER="${5:-"$HOME/projects/ford_shopbuy"}"
REPORTS_FOLDER="${6:-"$HOME/projects/reports"}"

 docker run -it --rm \
    -v "${PROJECTS_FOLDER}":/opt/repos \
    -v "${REPORTS_FOLDER}":/opt/output \
    leadingagilestudios.azurecr.io/analysis/gather-cli:0.2.0 \
    -d "${START_DATE}" \
    -r "${RUN_NAME}" \
    -t "${STEPS}" \
    -c "${CONFIG_FILE}"

