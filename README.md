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
docker run -it -v PATH_TO_CREDENTIALS.json:/app/.credentials -e GOOGLE_APPLICATION_CREDENTIALS=/app/.credentials -e BQ_BILLING_PROJECT_ID=YOUR_BILLING_PROJECT -e BQ_INPUT_MAIN_TABLE=YOUR_BQ_INPUT_MAIN_TABLE -e BQ_INPUT_CRASH_TABLE=YOUR_BQ_INPUT_CRASH_TABLE -e BQ_OUTPUT_TABLE=YOUR_BQ_OUTPUT_TABLE fission_monitoring_nightly
```
Add `-e DEBUG=true` for debugging purposes (e.g., only process a couple probes to ensure ETL works as intended).
