#!/bin/bash
set -ex

Rscript /app/run.R

if [[ -z "${GCS_BUCKET}" ]]; then   
    echo "Not uploading Rmarkdown file"
else
    echo "Uploading ETL markdown file"
    gsutil -o Credentials:gs_service_key_file=/app/.credentials cp /tmp/output/analysis_etl.html   $GCS_BUCKET/etl/analysis_etl.html
    gsutil -o Credentials:gs_service_key_file=/app/.credentials cp /tmp/output/dashboard.html   $GCS_BUCKET/dashboard/dashboard.html
fi
