#!/usr/bin/env bash


usage()
{
   echo
   echo "gather_metrics.sh [options]"
   echo
   echo
   echo "Run the 'metrics.utility gather-multi' tool"
   echo "Processes all of the repositories found in the REPOS_FOLDER to"
   echo "  creates a new run of data to be recorded as RUN_NAME"
   echo "  beginning at START_DATE in each of the repostories"
   echo
   echo "Options:"
   echo
   echo " -n, --run-name"
   echo "      Name the run of metrics collection. Defaults to the current date."
   echo
   echo " -s, --steps"
   echo "      Steps (i.e, weeks) to step back in time from the start date. Metrics are gathered at each step. Defaults to ${STEPS}."
   echo
   echo " -d, --start-date"
   echo "      Start date for the gathering. Metrics collection for each repository will be started as close this this date as possible. Defaults to the current date."
   echo
   echo " -c, --config-file"
   echo "      A team configuraton file. See the Code Analysis documentation for details."
   echo "      Defaults to No File Defined."
   echo
   echo " -r, --repos-folder"
   echo "      The base folder that holds all of the repositories to be analyzed."
   echo "      Defaults to '${REPOS_FOLDER}' (i.e. a convenient place for me)."
   echo
   echo " -o, --output-folder"
   echo "      The output folder where all the collected metrics data will be written."
   echo "      See the Code Analysis documentation for information in the structure and content."
   echo "      Defaults to '${OUTPUT_FOLDER}' (i.e. a convenient place for me)."
   echo
   echo "Be sure each repository is currently on the branch you are interested in evaluating"
   echo
   echo "Before using:"
   echo "   (you probably need to be OFF the VPN to do this)"
   echo "   Authenticate with docker registry (currently hosted by LeadingAgile)"
   echo "      Using azure cli (brew install azure-cli)"
   echo "         az login"
   echo "         az acr login --name leadingagilestudios"
   echo "   Get the docker image"
   echo "      docker pull leadingagilestudios.azurecr.io/analysis/gather-cli:0.2.0"
   echo
   echo
   echo "Example: "
   echo
   echo '      ./gather_metrics.sh --run-name "Q4_2021" --steps 52 --start-date "2021-12-31" --repos-folder ~/projects --output-folder ~/projects/reports/'
   echo
}


RUN_NAME="$(date -j +"%Y-%m-%d_%H-%M-%S%z")"
START_DATE="$(date -j +"%Y-%m-%d")"
STEPS=52
CONFIG_FILE=
REPOS_FOLDER="$HOME/projects/ford_shopbuy"
OUTPUT_FOLDER="$HOME/projects/reports"

while (( "$#" )); do
   case "${1}" in

   --help|-h|-[?])
      echo "Unknown option: '$1'"
      usage
      exit 0
      ;;

   -n|--run-name)
      RUN_NAME="$2"
      shift; shift
      ;;
   -n=*|--run-name=*)
      RUN_NAME="${1##*=}"
      shift
      ;;

   -s|--steps)
      STEPS="$2"
      shift; shift
      ;;
   -s=*|--steps=*)
      STEPS="${1##*=}"
      shift
      ;;

   -d|--start-date)
      START_DATE="$2"
      shift; shift
      ;;
   -d=*|--start-date=*)
      START_DATE="${1##*=}"
      shift
      ;;

   -c|--config-file)
      CONFIG_FILE="$2"
      shift; shift
      ;;
   -c=*|--config-file=*)
      CONFIG_FILE="${1##*=}"
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

   *)
      echo "Unknown parameter: '$1'"
      usage
      exit 0
      ;;
   esac
done

echo "RUN_NAME='${RUN_NAME}'"
echo "START_DATE='${START_DATE}'"
echo "STEPS='${STEPS}'"
echo "CONFIG_FILE='${CONFIG_FILE}'"
echo "REPOS_FOLDER='${REPOS_FOLDER}'"
echo "OUTPUT_FOLDER='${OUTPUT_FOLDER}'"



 time docker run -it --rm \
    -v "${REPOS_FOLDER}":/opt/repos \
    -v "${OUTPUT_FOLDER}":/opt/output \
    leadingagilestudios.azurecr.io/analysis/gather-cli:0.2.0 \
    -d "${START_DATE}" \
    -r "${RUN_NAME}" \
    -t "${STEPS}" \
    -c "${CONFIG_FILE}" \
    2>&1 | tee "${OUTPUT_FOLDER}/console.log"
