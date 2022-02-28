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

```script
az login
az acr login --name leadingagilestudios
```

2. Get the docker images

```script
docker pull leadingagilestudios.azurecr.io/analysis/gather:0.2.0
docker pull leadingagilestudios.azurecr.io/analysis/gather-cli:0.2.0
```

## Scripts

### gather-metrics.sh

Run the `gather-cli` tool to collect metrics from a set of repositories

## report_large_methods.sh

Process the data generated from the `gather-cli` to create a json extract of the large methods, where **large** is defined as 2 standard deviations above the median of the method length.

## large_methods_csv.sh

Same as `report_large_methods.sh` except the output is in CSV format.

