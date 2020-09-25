library(rmarkdown)

setwd('/app')

#print(g$q("select client_id from `moz-fx-data-shared-prod`.telemetry.main where date(submission_timestamp)='2020-01-01' limit 10"))

render('analysis_etl.Rmd', param=list())