# fission_monitoring_nightly

Code-base to generate monitoring dashboard for ongoing [Fission Nightly "experiment"](https://experimenter.services.mozilla.com/experiments/fission-nightly/). 

Currently, the `analysis.Rmd` reads data in from the initial ETL (< add link >), analyzes the probes relevant to the experiment, then generates a 2nd ETL `moz-fx-data-shared-prod.analysis.fission_monitoring_dashboard_v1`.

## Docker container

### Building
```shell script
docker build -t fission_monitoring_nightly .
```

### Running
```shell script
docker run -it -v PATH_TO_CREDENTIALS.json:/app/.credentials -e GOOGLE_APPLICATION_CREDENTIALS=/app/.credentials -e BQ_BILLING_PROJECT_ID=YOUR_BILLING_PROJECT fission_monitoring_nightly
```


## TOTO - parameters
* BQ_BILLING_PROJECT_ID
* BQ_INPUT_MAIN_TABLE
* BQ_INPUT_CRASH_TABLE
* BQ_OUTPUT_TABLE