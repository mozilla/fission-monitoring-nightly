#!/bin/bash
set -e

export BUCKET=${BUCKET:-gs://moz-fx-data-bq-data-science-cdowhygelund}

Rscript /app/run.R

if [[ -z "${GCS_UPLOAD}" ]]; then   
    ## Complete run if RUNFAST environment is missing
    echo "Not uploading Rmarkdown file"
else
    ## Quick Check if RUNFAST environment is passed
    echo "Uploading ETL markdown file"
    gsutil -m  rsync -r -d /tmp/output/   $BUCKET/cdowhygelund/fission_monitoring_dashboard/
fi