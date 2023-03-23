
- [Using the LeadingAgile Code Analysis Tools](#using-the-leadingagile-code-analysis-tools)
  - [Versions of Tool Scripts](#versions-of-tool-scripts)
  - [Docker Images](#docker-images)
  - [Before Using](#before-using)
  - [Detailed Container Documentation](#detailed-container-documentation)
  - [Scripts](#scripts)
    - [gather-metrics.sh](#gather-metricssh)
    - [gather_tool.sh](#gather_toolsh)
    - [report_large_items.sh](#report_large_itemssh)
    - [large_methods_csv.sh](#large_methods_csvsh)

# Using the LeadingAgile Code Analysis Tools

This is a collection of tools to demonstrate the use of the Code Analysis tool.

The main utility is the `gather_metrics.sh` script. This script wraps the invocation of the Code Analysis docker image and provides it with the parameters for the evaluation data collection.

The Code Analysis tool gathers metrics data from a collection of git repositories. This set of repositories must be in a common base folder. The Code Analysis tool iterates over each of the repositories during its data collection runs.

The Code Analysis tool creates a set of json data files for each repository for each time it is run. These data output files will be stored under a folder which you specific in the parameter set.

Some of the other scripts are intended to show examples of extracting data from the json created by the Code Analysis too.

## Versions of Tool Scripts

The current versions of these scripts assume you are using `v0.3.1` of the Code Analysis docker images. There are some command line option, behavior, and output differences between the released versions for the docker images.

If you need to work with the `v0.2.0` version of the docker images you can use the matching version of these scripts by checking out the tagged commit:

```shell
git switch 'use-image-0.2.0'
```


## Docker Images

There are two Docker images available that will cover most of the use of the tools:

* gather - provides access to the individual tools in the gather collection:
    * gather - collects metrics
    * statistics - generates statistics from the metrics
    * answers - generates the GQM Answers from the metrics and statistics
    * utility - a collection of utilities
        * gather-multi - process gather, statistics, answers, and (some) plotting for a collection of repositories
        * frequency-subset -Create a subset configuration for each of the repositories based on the file commit frequency.
* gather-cli - provide direct acces to the `utility gather-multi` tool


## Before Using

To use the Docker images, you will need to have the Docker images.

To get the Docker images, you must have [Docker Desktop](https://www.docker.com/products/docker-desktop) installed and running.

You probably need to be OFF the VPN to do these setup steps.

1. Authenticate with docker registry (currently hosted by LeadingAgile)

Using azure cli (brew install azure-cli)

```shell
az login
az acr login --name leadingagilestudios
```

2. Get the docker images

```shell
docker pull leadingagilestudios.azurecr.io/analysis/gather:0.3.1
docker pull leadingagilestudios.azurecr.io/analysis/gather-cli:0.3.1
```

## Detailed Container Documentation

To explore possible uses of the Code Analysis Docker images beyond what is provided with the scripts below, see the main documentation:

* [Gather CLI](./DockerGatherCLIReadme.pdf) covers the `gather-cli` image which wraps many of the lower-level tools to process multiple repositories. This image generally covers the most common uses
* [Gather](./DockerReadme.pdf) covers the lower-level tools that are available in the `gather` image (metrics collection, statistics generation, GQM answer generation, etc.)

## Scripts

### gather-metrics.sh

Run the `gather-cli` tool to collect metrics from a set of repositories

Requires the `leadingagilestudios.azurecr.io/analysis/gather-cli:0.3.1` image.

```
gather_metrics.sh [options]


Run the 'metrics.utility gather-multi' tool using the gather_cli docker image
Processes all of the repositories found in the REPOS_FOLDER to
  creates a new run of data to be recorded as RUN_NAME
  beginning at START_DATE in each of the repostories

Options:

 -h, --help
      Show this help

 --tool-help
      Pass '--help' to tool

 -n, --run-name
      Name the run of metrics collection.
      Defaults to the current date.

 -w, --weeks, -s, --steps
      Weeks to step back in time from the start date. Metrics are gathered at each step.
      Defaults to 52.

 -d, --start-date
      Start date for the gathering.
      Metrics collection for each repository will be started as close this this date as possible.
      Defaults to the current date.

 -c, --config-file
      A team configuraton file. See the Code Analysis documentation for details.
      Defaults to No File Defined.

 -r, --repos-folder
      The base folder that holds all of the repositories to be analyzed.
      Defaults to the current folder.

 -o, --output-folder
      The output folder where all the collected metrics data will be written.
      See the Code Analysis documentation for information in the structure and content.
      Required. Cannot be blank.

 -i, --image
      The docker image to use.
      Defaults to 'leadingagilestudios.azurecr.io/analysis/gather-cli:0.3.1'
      The image MUST be a 'gather-cli' image.

Be sure each repository is currently on the branch you are interested in evaluating

Before using:
   (you probably need to be OFF the VPN to do this)
   Authenticate with docker registry (currently hosted by LeadingAgile)
      Using azure cli (brew install azure-cli)
         az login
         az acr login --name leadingagilestudios
   Get the docker image
      docker pull leadingagilestudios.azurecr.io/analysis/gather-cli:0.3.1


Example:

      ./gather_metrics.sh --run-name "Q4_2021" --weeks 52 --start-date "2021-12-31" --repos-folder ~/projects/repositories --output-folder ~/projects/reports/
```


### gather_tool.sh

```
gather_tool.sh [options] tool-name [tool options]
gather_tool.sh --tool-help tool-name


Run the 'metrics' tool using the gather docker image
The gather docker image provides access to the lower-level functions in the metrics code analysis tool set.
The valid Tool Names are: gather statistics answers plotting utility
Tool Options are specific to each tool. Pass '--help' as the tool options to get help for a tool.

Options:

 -h, --help
      Show this help

 --tool-help
      Pass '--help' to tool

 -r, --repos-folder
      The base folder that holds all of the repositories to be analyzed.
      Defaults to the current folder.

 -o, --output-folder
      The output folder where all the collected metrics data will be written.
      See the Code Analysis documentation for information in the structure and content.
      Required. Cannot be blank.

 -i, --image
      The docker image to use.
      Defaults to 'leadingagilestudios.azurecr.io/analysis/gather:0.3.1'
      The image MUST be the 'gather' image.

Before using:
   (you probably need to be OFF the VPN to do this)
   Authenticate with docker registry (currently hosted by LeadingAgile)
      Using azure cli (brew install azure-cli)
         az login
         az acr login --name leadingagilestudios
   Get the docker image
      docker pull leadingagilestudios.azurecr.io/analysis/gather:0.3.1


KEEP IN MIND (oddities of running in a docker image)

* Path-based options for tools
   The tools is run inside a docker container with two volumes mounted pointing to host folders.
   Any folder-location options passed to the tools must be based on these mounts using the container paths instead of the host paths.

   The '--output-folder' option for this script is mounted as '/opt/output/' in the container
   The '--repos-folder' option for this script is mounted as '/opt/repos/' in the container

   NOTE: This will lead to the Oddity that '--output-folder' and '--repo-folder' will be defined twice.
         One definition will be for this script (relative to the host folder structure) and the other
         definition will be defined for the utility being invoked (relative to the container folder structure).

Examples:

./gather_tool.sh --output-folder ~/projects/la/metrics_data/dev_docker/ \
                          utility frequency-subset \
                          --output-folder /opt/output \
                          --run-name 2021Annual \
                          --team-name TopTenPercent \
                          --percent 10 \
                          --team-config /opt/output/team-config.yaml

./gather_tool.sh --output-folder ~/projects/reports --repos-folder ~/projects/project_repos \
                          --tool-help utility

./gather_tool.sh --output-folder ~/projects/reports --repos-folder ~/projects/project_repos \
                          --tool-help utility frequency-subset


```

### report_large_items.sh

Process the data generated from the `gather-cli` to create a json extract of large methods and complex methods, where **large** and **complex** are defined as 2 standard deviations above the mean of the metric values.

Example:

```shell
./report_large_items.sh 2022_Q1 'javascript' ~/projects/reports
```

Which outputs JSON that has the "large" items for each repository with the identification information and the limit used to determine "large" for each metric.

```json
{
  "2022_Q1": {
    "store_fromt_app": {
      "method_length": {
        "limit": 243.55414648132026,
        "large_items": [
          {
            "method_name": "anonymous function",
            "method_length": 597,
            "file": "dream/react-app/config/webpack.config.js"
          },
        ]
      },
      "cyclomatic_complexity": {
        "limit": 6.616198561805495,
        "large_items": [
          {
            "method_name": "anonymous function",
            "cyclomatic_complexity": 7,
            "file": "dream/react-app/config/modules.js"
          },
          {
            "method_name": "anonymous function",
            "cyclomatic_complexity": 33,
            "file": "dream/react-app/config/webpack.config.js"
          },
        ]
      }
    },
    "finance_app": {
      "method_length": {
        "limit": 217.9003233575817,
        "large_items": [
          {
            "method_name": "anonymous function",
            "method_length": 596,
            "file": "dream/react-app/config/webpack.config.js"
          },
        ]
      },
      "cyclomatic_complexity": {
        "limit": 7.362525192721681,
        "large_items": [
          {
            "method_name": "anonymous function",
            "cyclomatic_complexity": 33,
            "file": "dream/react-app/config/webpack.config.js"
          },
        ]
      }
    }
  }
}
```

Requires data sets collected using the `gather-metrics.sh` script.

### large_methods_csv.sh

Another example using `jq` to dig through the data to report large methods in a CSV format.

Requires data sets collected using the `gather-metrics.sh` script.
