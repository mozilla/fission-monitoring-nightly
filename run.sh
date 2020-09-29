#!/bin/bash
set -e

#export BUCKET=${BUCKET:-gs://moz-fx-data-bq-data-science-cdowhygelund}

Rscript /app/run.R

if [[ -z "${GCS_BUCKET}" ]]; then   
    ## Complete run if RUNFAST environment is missing
    echo "Not uploading Rmarkdown file"
else
    ## Quick Check if RUNFAST environment is passed
    echo "Uploading ETL markdown file"
    gsutil -o Credentials:gs_service_key_file=/app/.credentials cp /tmp/output/analysis_etl.html   $GCS_BUCKET/etl/analysis_etl.html
fi