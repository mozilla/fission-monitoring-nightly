library(rmarkdown)

setwd('/app')

render('analysis_etl.Rmd', output_dir = "/tmp/output/")

render('dashboard.Rmd', output_dir = 'tmp/output')