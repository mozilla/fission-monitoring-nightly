library(rmarkdown)

setwd('/app/analysis')

render('dashboard.Rmd', output_dir = '/tmp/output/')