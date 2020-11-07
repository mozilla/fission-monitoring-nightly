#!/bin/bash
set -ex

Rscript /app/run.R

if [[ -z "${GCS_BUCKET}" ]]; then   
    echo "Not uploading analysis Rmarkdown file"
else
    echo "Uploading Analysis ETL markdown file"
    gsutil cp /tmp/output/analysis_etl.html gs://$GCS_BUCKET/etl/analysis_etl.html
fi

Rscript /app/run_dashboard.R

if [[ -z "${GCS_BUCKET}" ]]; then
  echo "Not dashboard file"
else
   echo "Uploading dashboard file"
   gsutil cp /tmp/output/dashboard.html gs://$GCS_BUCKET/dashboard/dashboard.html
fi