library(rmarkdown)

setwd('/app/analysis')

render('analysis_etl.Rmd', output_dir = "/tmp/output/")

