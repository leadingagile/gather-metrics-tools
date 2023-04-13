function usage
{
   Write-Output ""
   Write-Output "gather_metrics.ps1 [options]"
   Write-Output ""
   Write-Output ""
   Write-Output "Run the 'metrics.utility gather-multi' tool using the gather_cli docker image"
   Write-Output "Processes all of the repositories found in the REPOS_FOLDER to"
   Write-Output "  creates a new run of data to be recorded as RUN_NAME"
   Write-Output "  beginning at START_DATE in each of the repostories"
   Write-Output ""
   Write-Output "Options:"
   Write-Output ""
   Write-Output " --help"
   Write-Output "      Show this help"
   Write-Output ""
   Write-Output " --tool-help"
   Write-Output "      Pass '--help' to tool"
   Write-Output ""
   Write-Output " --run-name"
   Write-Output "      Name the run of metrics collection."
   Write-Output "      Defaults to the current date."
   Write-Output ""
   Write-Output " --steps"
   Write-Output "      Weeks to step back in time from the start date. Metrics are gathered at each step."
   Write-Output "      Defaults to ${STEPS}."
   Write-Output ""
   Write-Output " --start-date"
   Write-Output "      Start date for the gathering."
   Write-Output "      Metrics collection for each repository will be started as close this this date as possible."
   Write-Output "      Defaults to the current date."
   Write-Output ""
   Write-Output " --config-file"
   Write-Output "      A team configuraton file. See the Code Analysis documentation for details."
   Write-Output "      Defaults to No File Defined."
   Write-Output ""
   Write-Output " --repos-folder"
   Write-Output "      The base folder that holds all of the repositories to be analyzed."
   Write-Output "      Defaults to the current folder."
   Write-Output ""
   Write-Output " --output-folder"
   Write-Output "      The output folder where all the collected metrics data will be written."
   Write-Output "      See the Code Analysis documentation for information in the structure and content."
   Write-Output "      Required. Cannot be blank."
   Write-Output ""
   Write-Output " --image"
   Write-Output "      The docker image to use."
   Write-Output "      Defaults to '${DOCKER_IMAGE}'"
   Write-Output "      The image MUST be a 'gather-cli' image."
   Write-Output ""
   Write-Output "Be sure each repository is currently on the branch you are interested in evaluating"
   Write-Output ""
   Write-Output "Before using:"
   Write-Output "   (you probably need to be OFF the VPN to do this)"
   Write-Output "   Authenticate with docker registry (currently hosted by LeadingAgile)"
   Write-Output "      Using azure cli (brew install azure-cli)"
   Write-Output "         az login"
   Write-Output "         az acr login --name leadingagilestudios"
   Write-Output "   Get the docker image"
   Write-Output "      docker pull leadingagilestudios.azurecr.io/analysis/gather-cli:0.3.1"
   Write-Output ""
   Write-Output ""
   Write-Output "Example: "
   Write-Output ""
   Write-Output '      ./gather_metrics.ps1 --run-name "Q4_2021" --weeks 52 --start-date "2021-12-31" --repos-folder ~/projects/repositories --output-folder ~/projects/reports/'
   Write-Output ""
}

$DEBUG=$false
$RUN_NAME="$(Get-Date -UFormat "%Y-%m-%d_%H-%M-%S%z")"
$START_DATE="$(Get-Date -UFormat "%Y-%m-%d")"
$STEPS=52
$CONFIG_FILE=""
$REPOS_FOLDER="$(Get-Location)"
$OUTPUT_FOLDER=""
$DOCKER_IMAGE="leadingagilestudios.azurecr.io/analysis/gather-cli:0.3.1"
$TOOL_HELP=$false

for ($i = 0; $i -lt $args.count; $i++)
{
   Switch -Regex ($args[$i])
   {
      "--help"                   { usage; exit 0 }
      "--tool-help"              { $TOOL_HELP=$true }
      "--debug"                  { $DEBUG=$true }
      "--run-name"               { $RUN_NAME=$args[$i+1]; $i++ }
      "--run-name=(.*)"          { $RUN_NAME=$matches[1] }
      "--steps"                  { $STEPS=$args[$i+1]; $i++ }
      "--steps=(.*)"             { $STEPS=$matches[1] }
      "--start-date"             { $START_DATE=$args[$i+1]; $i++ }
      "--start-date=(.*)"        { $START_DATE=$matches[1] }
      "--config-file"            { $CONFIG_FILE=$args[$i+1]; $i++ }
      "--config-file=(.*)"       { $CONFIG_FILE=$matches[1] }
      "--repos-folder"           { $REPOS_FOLDER=$args[$i+1]; $i++ }
      "--repos-folder=(.*)"      { $REPOS_FOLDER=$matches[1] }
      "--output-folder"          { $OUTPUT_FOLDER=$args[$i+1]; $i++ }
      "--output-folder=(.*)"     { $OUTPUT_FOLDER=$matches[1] }
      "--image"                  { $DOCKER_IMAGE=$args[$i+1]; $i++ }
      "--image=(.*)"             { $DOCKER_IMAGE=$matches[1] }
      default                    { Write-Output "Unknown parameter:" $args[$i]; exit 1 }
   }
}

if ($DEBUG) 
{
   Write-Output ""
   Write-Output "DOCKER_IMAGE='${DOCKER_IMAGE}'"
   Write-Output "RUN_NAME='${RUN_NAME}'"
   Write-Output "START_DATE='${START_DATE}'"
   Write-Output "STEPS='${STEPS}'"
   Write-Output "CONFIG_FILE='${CONFIG_FILE}'"
   Write-Output "REPOS_FOLDER='${REPOS_FOLDER}'"
   Write-Output "OUTPUT_FOLDER='${OUTPUT_FOLDER}'"
   Write-Output "TOOL_HELP='${TOOL_HELP}'"
}

if ($TOOL_HELP)
{
    docker run -it --rm "${DOCKER_IMAGE}" --help
    exit 0
}
else
{
   if (!$REPOS_FOLDER -or ![System.IO.Directory]::Exists($REPOS_FOLDER) )
   {
      Write-Output "Folder for repositories is not defined or does not exist: '${REPOS_FOLDER}'"
      exit 1
   }

   if (!$OUTPUT_FOLDER -or ![System.IO.Directory]::Exists($OUTPUT_FOLDER))
   {
      Write-Output "Output folder for results is not defined or does not exist: '${OUTPUT_FOLDER}'"
      exit 1
   }

   if (!$DOCKER_IMAGE -or !$(docker image ls -q "${DOCKER_IMAGE}") )
   {
      Write-Output "Docker image name is not defined or the image is not available from docker: '${DOCKER_IMAGE}'"
      exit 1
   }

   docker run -it --rm `
      -v ${REPOS_FOLDER}:/opt/repos `
      -v ${OUTPUT_FOLDER}:/opt/output `
      "${DOCKER_IMAGE}" `
      --start-date "${START_DATE}" `
      --run-name "${RUN_NAME}" `
      --steps "${STEPS}" `
      --team-config \"${CONFIG_FILE}\" `
      2>&1 | Tee-Object "${OUTPUT_FOLDER}/console.log"
}
