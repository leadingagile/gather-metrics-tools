# Using the LeadingAgile Code Analysis Tools

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

You probably need to be OFF the VPN to do these setup steps.

1. Authenticate with docker registry (currently hosted by LeadingAgile)

Using azure cli (brew install azure-cli)

```shell
az login
az acr login --name leadingagilestudios
```

2. Get the docker images

```shell
docker pull leadingagilestudios.azurecr.io/analysis/gather:0.2.0
docker pull leadingagilestudios.azurecr.io/analysis/gather-cli:0.2.0
```

## Scripts

### gather-metrics.sh

Run the `gather-cli` tool to collect metrics from a set of repositories

Requires the `leadingagilestudios.azurecr.io/analysis/gather-cli:0.2.0` image.

```
gather_metrics.sh [options]


Run the 'metrics.utility gather-multi' tool
Processes all of the repositories found in the REPOS_FOLDER to
  creates a new run of data to be recorded as RUN_NAME
  beginning at START_DATE in each of the repostories

Options:

 -n, --run-name
      Name the run of metrics collection. Defaults to the current date.

 -s, --steps
      Steps (i.e, weeks) to step back in time from the start date. Metrics are gathered at each step. Defaults to 52.

 -d, --start-date
      Start date for the gathering. Metrics collection for each repository will be started as close this this date as possible. Defaults to the current date.

 -c, --config-file
      A team configuraton file. See the Code Analysis documentation for details.
      Defaults to No File Defined.

 -r, --repos-folder
      The base folder that holds all of the repositories to be analyzed.
      Defaults to '/Users/bhowar68/projects/ford_shopbuy' (i.e. a convenient place for me).

 -o, --output-folder
      The output folder where all the collected metrics data will be written.
      See the Code Analysis documentation for information in the structure and content.
      Defaults to '/Users/bhowar68/projects/reports' (i.e. a convenient place for me).

Be sure each repository is currently on the branch you are interested in evaluating

Before using:
   (you probably need to be OFF the VPN to do this)
   Authenticate with docker registry (currently hosted by LeadingAgile)
      Using azure cli (brew install azure-cli)
         az login
         az acr login --name leadingagilestudios
   Get the docker image
      docker pull leadingagilestudios.azurecr.io/analysis/gather-cli:0.2.0


Example:

      ./gather_metrics.sh --run-name "Q4_2021" --steps 52 --start-date "2021-12-31" --repos-folder ~/projects --output-folder ~/projects/reports/
```

## report_large_methods.sh

Process the data generated from the `gather-cli` to create a json extract of the large methods, where **large** is defined as 2 standard deviations above the median of the method length.

Requires data sets collected using the `gather-metrics.sh` script.

## large_methods_csv.sh

Same as `report_large_methods.sh` except the output is in CSV format.

Requires data sets collected using the `gather-metrics.sh` script.
