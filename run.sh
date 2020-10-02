#!/bin/bash
set -ex

Rscript /app/run.R

if [[ -z "${GCS_BUCKET}" ]]; then   
    echo "Not uploading Rmarkdown file"
else
    echo "Uploading ETL markdown file"
    gsutil cp /tmp/output/analysis_etl.html gs://$GCS_BUCKET/etl/analysis_etl.html
    gsutil cp /tmp/output/dashboard.html gs://$GCS_BUCKET/dashboard/dashboard.html
fi
