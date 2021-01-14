Code-base to generate [monitoring dashboard](https://protosaur.dev/fission-experiment-monitoring-dashboard/dashboard/dashboard.html) for ongoing [Fission Nightly "experiment"](https://experimenter.services.mozilla.com/experiments/fission-nightly/). 

# Process
Currently, the `analysis_etl.Rmd` reads data in from the initial ETL ([main](https://github.com/mozilla/bigquery-etl/tree/master/sql/moz-fx-data-shared-prod/telemetry_derived/fission_monitoring_main_v1), [crashes](https://github.com/mozilla/bigquery-etl/tree/master/sql/moz-fx-data-shared-prod/telemetry_derived/fission_monitoring_crash_v1)) for [performance/engagement/usage](https://github.com/mozilla/bigquery-etl/tree/master/sql/moz-fx-data-shared-prod/telemetry_derived/fission_monitoring_main_v1) and [stability](https://github.com/mozilla/bigquery-etl/tree/master/sql/moz-fx-data-shared-prod/telemetry_derived/fission_monitoring_crash_v1) metrics. It then analyzes (e.g., aggregates and calculates confidence intervals) the probes relevant to the experiment, generating a 2nd ETL table `moz-fx-data-shared-prod.analysis.fission_monitoring_dashboard_v1`. The markdown results of the analysis ETL are available [here](https://storage.cloud.google.com/fission-experiment-monitoring-dashboard/etl/analysis_etl.html). 

The next step renders `dashboard.Rmd`, which pulls data from the previous analysis table and generates a plethora of Vega-lite plots. The rendered `dashboard.html` is uploaded to a [GCS bucket](https://storage.cloud.google.com/fission-experiment-monitoring-dashboard/dashboard/dashboard.html), and then served by [Protosaur](https://docs.telemetry.mozilla.org/cookbooks/operational/protosaur.html). 

# Docker container

## Building
```shell script
docker build -t fission_monitoring_nightly .
```

## Running
```shell script
docker run -it -v PATH_TO_CREDENTIALS.json:/app/.credentials -e GOOGLE_APPLICATION_CREDENTIALS=/app/.credentials -e BQ_BILLING_PROJECT_ID=YOUR_BILLING_PROJECT -e BQ_INPUT_MAIN_TABLE=YOUR_BQ_INPUT_MAIN_TABLE -e BQ_INPUT_CRASH_TABLE=YOUR_BQ_INPUT_CRASH_TABLE -e BQ_OUTPUT_TABLE=YOUR_BQ_OUTPUT_TABLE fission_monitoring_nightly
```
Additional parameters:

* `-e GS_BUCKET`: Uploads `dashboard.html` to `$GCS_BUCKET/dashboard/dashboard.html`. In addition, uploads rendered ETL markdown to `$GCS_BUCKET/etl/analysis_etl.html`.
* `-e DEBUG=true`: debugging purposes (e.g., only process a couple probes to ensure ETL works as intended).
* `-e MIN_BUILD_ID`: Minimum `app_build_id` to process. Format: YYYYMMDD. This defaults to previous 10 days worth of builds. 
