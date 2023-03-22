#!/usr/bin/env bash


usage()
{
   echo
   echo "gather_tool.sh [options] tool-name [tool options]"
   echo "gather_tool.sh --tool-help tool-name"
   echo
   echo
   echo "Run the 'metrics' tool using the gather docker image"
   echo "The gather docker image provides access to the lower-level functions in the metrics code analysis tool set."
   echo "The valid Tool Names are: ${TOOL_NAMES[*]}"
   echo "Tool Options are specific to each tool. Pass '--help' as the tool options to get help for a tool."
   echo
   echo "Options:"
   echo
   echo " -h, --help"
   echo "      Show this help"
   echo
   echo " --tool-help"
   echo "      Pass '--help' to tool"
   echo
   echo " -r, --repos-folder"
   echo "      The base folder that holds all of the repositories to be analyzed."
   echo "      Defaults to the current folder."
   echo
   echo " -o, --output-folder"
   echo "      The output folder where all the collected metrics data will be written."
   echo "      See the Code Analysis documentation for information in the structure and content."
   echo "      Required. Cannot be blank."
   echo
   echo " -i, --image"
   echo "      The docker image to use."
   echo "      Defaults to '${DOCKER_IMAGE}'"
   echo "      The image MUST be the 'gather' image."
   echo
   echo "Before using:"
   echo "   (you probably need to be OFF the VPN to do this)"
   echo "   Authenticate with docker registry (currently hosted by LeadingAgile)"
   echo "      Using azure cli (brew install azure-cli)"
   echo "         az login"
   echo "         az acr login --name leadingagilestudios"
   echo "   Get the docker image"
   echo "      docker pull leadingagilestudios.azurecr.io/analysis/gather:0.3.0"
   echo
   echo
   echo "KEEP IN MIND (oddities of running in a docker image)"
   echo
   echo "* Path-based options for tools"
   echo "   The tools is run inside a docker container with two volumes mounted pointing to host folders."
   echo "   Any folder-location options passed to the tools must be based on these mounts using the container paths instead of the host paths."
   echo
   echo "   The '--output-folder' option for this script is mounted as '/opt/output/' in the container"
   echo "   The '--repos-folder' option for this script is mounted as '/opt/repos/' in the container"
   echo
   echo "   NOTE: This will lead to the Oddity that '--output-folder' and '--repo-folder' will be defined twice."
   echo "         One definition will be for this script (relative to the host folder structure) and the other"
   echo "         definition will be defined for the utility being invoked (relative to the container folder structure)."
   echo
   echo "Examples: "
   echo
   echo './gather_tool.sh --output-folder ~/projects/la/metrics_data/dev_docker/ \
                          utility frequency-subset \
                          --output-folder /opt/output \
                          --run-name 2021Annual \
                          --team-name TopTenPercent \
                          --percent 10 \
                          --team-config /opt/output/team-config.yaml'
   echo
   echo './gather_tool.sh --output-folder ~/projects/reports --repos-folder ~/projects/project_repos \
                          --tool-help utility'
   echo
   echo './gather_tool.sh --output-folder ~/projects/reports --repos-folder ~/projects/project_repos \
                          --tool-help utility frequency-subset'
   echo
}

run_a_tool()
{
   declare TOOL="$1"
   shift

   docker run -it --rm \
      -v "${REPOS_FOLDER}":/opt/repos \
      -v "${OUTPUT_FOLDER}":/opt/output \
      "${DOCKER_IMAGE}" \
      "${TOOL}" \
      "$@"
}

DEBUG=false
TOOL_NAMES=(gather statistics answers plotting utility)
DOCKER_IMAGE="leadingagilestudios.azurecr.io/analysis/gather:0.3.0"
REPOS_FOLDER="$(pwd)"
OUTPUT_FOLDER=
TOOL_HELP=false

while (( "$#" )); do
   case "${1}" in

   --help|-h|-[?])
      usage
      exit 0
      ;;

   --tool-help)
      TOOL_HELP=true
      TOOL_NAME="$2"
      shift
      shift
      break
      ;;

   --debug)
      DEBUG=true
      shift
      ;;

   -i|--image)
      DOCKER_IMAGE="$2"
      shift; shift
      ;;
   -i=*|--image=*)
      DOCKER_IMAGE="${1##*=}"
      shift
      ;;

   -r|--repos-folder)
      REPOS_FOLDER="$2"
      shift; shift
      ;;
   -r=*|--repos-folder=*)
      REPOS_FOLDER="${1##*=}"
      shift
      ;;

   -o|--output-folder)
      OUTPUT_FOLDER="$2"
      shift; shift
      ;;
   -o=*|--output-folder=*)
      OUTPUT_FOLDER="${1##*=}"
      shift
      ;;

   -*)
      echo "Invalid Option: '$1'"
      exit 1
      ;;

   # the first non-option param is the Tool Name, which is required
   # everything after that is options for the tool itself
   *)
      TOOL_NAME="$1"
      shift
      break
      ;;

   esac
done

if ${DEBUG}; then
   echo
   echo "DOCKER_IMAGE='${DOCKER_IMAGE}'"
   echo "REPOS_FOLDER='${REPOS_FOLDER}'"
   echo "OUTPUT_FOLDER='${OUTPUT_FOLDER}'"
   echo "TOOL_NAME='${TOOL_NAME}'"
   echo "Tool Options:"
   echo "   $*"
fi

if ! [[ "${TOOL_NAMES[*]}" =~ (^| )"$TOOL_NAME"( |$) ]]; then
    echo "Invalid Tool Name: '${TOOL_NAME}'"
    exit 1
fi


if ${TOOL_HELP}; then

   docker run -it --rm \
      "${DOCKER_IMAGE}" \
      "${TOOL_NAME}" \
      "$@" \
      --help

else
    if [[ -z "${REPOS_FOLDER}" ]] || [[ ! -d "${REPOS_FOLDER}" ]]; then
        echo "Folder for repositories is not defined or does not exist: '${REPOS_FOLDER}'"
        exit 1
    fi

    if [[ -z "${OUTPUT_FOLDER}" ]] || [[ ! -d "${OUTPUT_FOLDER}" ]]; then
        echo "Output folder for results is not defined or does not exist: '${OUTPUT_FOLDER}'"
        exit 1
    fi

    if [[ -z "${DOCKER_IMAGE}" ]] || [[ -z "$(docker image ls -q "${DOCKER_IMAGE}")" ]]; then
        echo "Docker image name is not defined or the image is not available from docker: '${DOCKER_IMAGE}'"
        exit 1
    fi

    run_a_tool "${TOOL_NAME}" "$@"
fi
